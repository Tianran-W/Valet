import '../core/api_client.dart';

/// 用户 API 类，处理用户相关的 API 请求
class UserApi {
  final ApiClient _apiClient;

  /// 构造函数
  UserApi(this._apiClient);

  /// 获取用户信息
  /// [userId]: 用户 ID
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    return await _apiClient.get('/users/$userId');
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiClient.get('/users/me');
  }

  /// 用户登录
  /// [email]: 用户邮箱
  /// [password]: 用户密码
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  /// 用户注册
  /// [name]: 用户名称
  /// [email]: 用户邮箱
  /// [password]: 用户密码
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  /// 更新用户信息
  /// [userId]: 用户 ID
  /// [userData]: 要更新的用户数据
  Future<Map<String, dynamic>> updateUserInfo(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    return await _apiClient.put(
      '/users/$userId',
      body: userData,
    );
  }

  /// 更改用户密码
  /// [oldPassword]: 旧密码
  /// [newPassword]: 新密码
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _apiClient.post(
      '/users/change-password',
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  /// 用户登出
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}
