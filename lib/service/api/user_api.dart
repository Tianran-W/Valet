import 'package:valet/service/logger_service.dart';
import 'api_client.dart';

/// 用户 API 类，处理用户相关的 API 请求
class UserApi {
  final ApiClient _apiClient;

  /// 构造函数
  UserApi(this._apiClient);

  /// 用户登录
  /// [username] 用户名
  /// [password] 密码
  /// 返回包含用户信息的Map，如果登录失败返回null
  /// Session认证会在Cookie中自动设置session信息
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      logger.info('开始登录请求: username=$username', tag: 'UserApi');
      
      final Map<String, dynamic> loginData = {
        'username': username,
        'password': password,
      };
      
      logger.info('登录数据: $loginData', tag: 'UserApi');
      
      final response = await _apiClient.post('/login', body: loginData);
      
      logger.info('登录响应: $response', tag: 'UserApi');
      
      // 验证响应格式，确保与Python代码期望的格式一致
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response != null) {
        // 如果响应不是Map类型，尝试转换
        logger.warning('登录响应格式异常，尝试转换: ${response.runtimeType}', tag: 'UserApi');
        return {'data': response};
      } else {
        logger.warning('登录响应为空', tag: 'UserApi');
        return null;
      }
    } catch (e) {
      logger.error('登录请求失败: $e', tag: 'UserApi');
      rethrow;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    await _apiClient.post('/logout');
  }

  /// 检查认证状态
  /// 返回认证检查的响应，Session认证通过Cookie验证
  Future<Map<String, dynamic>?> checkAuthStatus() async {
    final response = await _apiClient.get('/auth/check');
    return response;
  }

  /// 获取用户角色
  /// 返回用户角色信息
  Future<Map<String, dynamic>?> getUserRole() async {
    try {
      final response = await _apiClient.get('/user/role');
      return response;
    } catch (e) {
      logger.error('获取用户角色失败: $e');
      throw Exception('获取用户角色失败: $e');
    }
  }

  /// 用户注册
  /// [username] 用户名
  /// [password] 密码
  /// [email] 邮箱
  /// 返回注册结果，成功返回用户信息，失败返回null
  Future<Map<String, dynamic>?> register(String username, String password, String email) async {
    try {
      final Map<String, dynamic> registerData = {
        'username': username,
        'password': password,
        'email': email,
      };
      
      final response = await _apiClient.post('/register', body: registerData);
      return response;
    } catch (e) {
      logger.error('用户注册失败: $e');
      throw Exception('用户注册失败: $e');
    }
  }

  /// 修改密码
  /// [oldPassword] 原密码
  /// [newPassword] 新密码
  /// 返回修改结果
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final Map<String, dynamic> changePasswordData = {
        'currentPassword': oldPassword,
        'newPassword': newPassword,
      };
      
      await _apiClient.put('/user/password', body: changePasswordData);
      return true;
    } catch (e) {
      logger.error('修改密码失败: $e');
      throw Exception('修改密码失败: $e');
    }
  }

  /// 获取全部用户（管理员接口）
  /// 返回用户列表
  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      logger.info('开始获取全部用户列表', tag: 'UserApi');
      
      final response = await _apiClient.get('/admin/users');
      
      logger.info('获取用户列表响应: $response', tag: 'UserApi');
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map<String, dynamic> && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        logger.warning('用户列表响应格式异常: ${response.runtimeType}', tag: 'UserApi');
        return [];
      }
    } catch (e) {
      logger.error('获取全部用户失败: $e', tag: 'UserApi');
      throw Exception('获取全部用户失败: $e');
    }
  }
}
