import 'api_client.dart';
import 'workspace_api.dart';

/// API 服务类，整合所有 API 服务
class ApiService {
  late final ApiClient _apiClient;

  /// 获取工作空间 API 实例
  WorkspaceApi get workspaceApi => WorkspaceApi(_apiClient);

  /// 私有构造函数
  ApiService._({
    required String baseUrl,
    Map<String, String>? headers,
    String? authToken,
  }) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
      ...?headers,
    };

    _apiClient = ApiClient(baseUrl: baseUrl, defaultHeaders: defaultHeaders);
  }

  /// 创建 ApiService 实例
  static ApiService create({
    required String baseUrl,
    Map<String, String>? headers,
    String? authToken,
  }) {
    return ApiService._(
      baseUrl: baseUrl,
      headers: headers,
      authToken: authToken,
    );
  }

  /// 更新认证令牌
  void updateAuthToken(String token) {
    _apiClient.defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// 清除认证令牌
  void clearAuthToken() {
    _apiClient.defaultHeaders.remove('Authorization');
  }
}
