import 'api_client.dart';
import 'workspace_api.dart';
import 'user_api.dart';
import 'battery_api.dart';

/// API 服务类，整合所有 API 服务
class ApiService {
  late final ApiClient _apiClient;

  /// 获取工作空间 API 实例
  WorkspaceApi get workspaceApi => WorkspaceApi(_apiClient);

  /// 获取用户 API 实例
  UserApi get userApi => UserApi(_apiClient);

  /// 获取电池 API 实例
  BatteryApi get batteryApi => BatteryApi(_apiClient);

  /// 私有构造函数
  ApiService._({
    required String baseUrl,
    Map<String, String>? headers,
  }) {
    final defaultHeaders = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      ...?headers,
    };

    _apiClient = ApiClient(baseUrl: baseUrl, defaultHeaders: defaultHeaders);
  }

  /// 创建 ApiService 实例
  static ApiService create({
    required String baseUrl,
    Map<String, String>? headers,
  }) {
    return ApiService._(
      baseUrl: baseUrl,
      headers: headers,
    );
  }

  /// 清除Session（登出时调用）
  void clearSession() {
    _apiClient.clearCookies();
  }
}
