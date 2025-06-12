import 'package:get_it/get_it.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/service/api/api_service.dart';
import 'package:valet/workspace/application/approval_service.dart';
import 'package:valet/workspace/application/inventory_service.dart';

/// 依赖解析器
/// 负责注册和初始化应用所需的所有服务
class DepsResolver {
  /// 初始化并注册所有核心服务
  static Future<void> resolve(GetIt getIt) async {
    logger.info('开始初始化依赖注入容器', tag: 'DepsResolver');

    try {
      await registerApiService(getIt);

      registerApplicationServices(getIt);

      logger.info('依赖注入容器初始化成功', tag: 'DepsResolver');
    } catch (e, s) {
      logger.fatal('依赖注入容器初始化失败', tag: 'DepsResolver', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// 注册API服务
  static Future<void> registerApiService(GetIt getIt) async {
    // 注册ApiService为单例
    final baseUrl = getIt.get<String>(instanceName: 'baseUrl');
    final authToken = await getIt.getAsync<String>(instanceName: 'authToken');
    getIt.registerLazySingleton<ApiService>(
      () => ApiService.create(
        baseUrl: baseUrl,
        headers: {},
        authToken: authToken,
      ),
    );
  }

  /// 注册应用服务层
  static void registerApplicationServices(GetIt getIt) {
    // 注册审批服务
    getIt.registerFactory<ApprovalService>(
      () => ApprovalService(getIt<ApiService>()),
    );

    // 注册库存服务
    getIt.registerFactory<InventoryService>(
      () => InventoryService(getIt<ApiService>()),
    );

    // 可以继续注册其他服务...
  }
}
