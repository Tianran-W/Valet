import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/service/api/api_service.dart';
import 'package:valet/service/api/user_api.dart';
import 'package:valet/user/user.dart';
import 'package:valet/workspace/application/approval_service.dart';
import 'package:valet/workspace/application/inventory_service.dart';
import 'package:valet/workspace/application/image_service.dart';
import 'package:valet/workspace/application/battery_service.dart';

/// 依赖解析器
/// 负责注册和初始化应用所需的所有服务
class DepsResolver {
  /// 初始化并注册所有核心服务
  static Future<void> resolve(GetIt getIt) async {
    logger.info('开始初始化依赖注入容器', tag: 'DepsResolver');

    try {
      await registerApiService(getIt);
      await registerAuthService(getIt);
      await registerApplicationServices(getIt);

      logger.info('依赖注入容器初始化成功', tag: 'DepsResolver');
    } catch (e, s) {
      logger.fatal('依赖注入容器初始化失败', tag: 'DepsResolver', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// 注册API服务
  static Future<void> registerApiService(GetIt getIt) async {
    final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
    if (backendUrl.isEmpty) {
      logger.error('BACKEND_URL 环境变量未配置', tag: 'DepsResolver');
      throw Exception('BACKEND_URL 环境变量未配置');
    }
    
    logger.info('API服务配置: baseUrl=$backendUrl', tag: 'DepsResolver');
    
    // 注册ApiService为单例
    getIt.registerLazySingleton<ApiService>(
      () => ApiService.create(
        baseUrl: backendUrl,
        headers: {},
      ),
    );
    
    // 注册UserApi为单例
    getIt.registerLazySingleton<UserApi>(
      () => getIt<ApiService>().userApi,
    );
  }

  /// 注册用户认证服务
  static Future<void> registerAuthService(GetIt getIt) async {
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(getIt<ApiService>()),
    );
  }

  /// 注册应用层服务
  static Future<void> registerApplicationServices(GetIt getIt) async {
    getIt.registerLazySingleton<InventoryService>(
      () => InventoryService(getIt<ApiService>()),
    );
    getIt.registerLazySingleton<ApprovalService>(
      () => ApprovalService(getIt<ApiService>()),
    );
    getIt.registerLazySingleton<ImageService>(
      () => ImageService(getIt<ApiService>()),
    );
    getIt.registerLazySingleton<BatteryService>(
      () => BatteryService(getIt<ApiService>()),
    );
  }
}
