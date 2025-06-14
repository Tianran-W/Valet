import 'package:valet/service/logger_service.dart';
import 'package:valet/user/models/user_model.dart';
import 'api_client.dart';

/// 用户 API 类，处理用户相关的 API 请求
class UserApi {
  final ApiClient _apiClient;

  /// 构造函数
  UserApi(this._apiClient);

  /// 用户登录
  /// [username] 用户名
  /// [password] 密码
  /// 返回包含用户信息和token的Map，如果登录失败返回null
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final Map<String, dynamic> loginData = {
      'username': username,
      'password': password,
    };
    
    final response = await _apiClient.post('/login', body: loginData);
    return response;
  }

  /// 用户登出
  Future<void> logout() async {
    await _apiClient.post('/logout');
  }

  /// 检查认证状态
  /// 返回认证检查的响应，如果失败返回null
  Future<Map<String, dynamic>?> checkAuthStatus() async {
    final response = await _apiClient.get('/auth/check');
    return response;
  }

  /// 获取用户信息
  /// [userId] 用户ID
  Future<User?> getUserInfo(String userId) async {
    try {
      final response = await _apiClient.get('/user/$userId');
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.error('获取用户信息失败: $e');
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 更新用户信息
  /// [user] 用户信息
  Future<bool> updateUserInfo(User user) async {
    try {
      await _apiClient.put('/user/${user.id}', body: user.toJson());
      return true;
    } catch (e) {
      logger.error('更新用户信息失败: $e');
      throw Exception('更新用户信息失败: $e');
    }
  }
}
