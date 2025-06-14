import 'package:valet/service/logger_service.dart';
import 'package:valet/user/models/user_model.dart';
import 'package:valet/service/api/api_service.dart';

/// 认证服务类，处理用户登录、登出等认证相关功能
class AuthService {
  final ApiService _apiService;
  static const String _tag = 'AuthService';
  
  User? _currentUser;
  bool _isLoggedIn = false;

  /// 获取当前登录用户
  User? get currentUser => _currentUser;

  /// 获取登录状态
  bool get isLoggedIn => _isLoggedIn;

  /// 构造函数
  AuthService(this._apiService);

  /// 用户登录
  /// [username] 用户名
  /// [password] 密码
  Future<bool> login(String username, String password) async {
    try {
      logger.info('用户登录请求: $username', tag: _tag);
      
      // 调用登录API
      final response = await _apiService.userApi.login(username, password);
      
      // 处理登录响应
      if (response != null && response['success'] == true) {
        // 从响应中提取用户信息
        _currentUser = User(
          id: response['userId']?.toString() ?? '1',
          username: username,
          email: response['email']?.toString() ?? '$username@example.com',
          avatarUrl: response['avatarUrl']?.toString(),
        );
        
        _isLoggedIn = true;
        logger.info('用户登录成功: $username', tag: _tag);
        return true;
      } else {
        logger.warning('用户登录失败：服务器响应为空或登录失败', tag: _tag);
        return false;
      }
    } catch (e) {
      logger.error('用户登录失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('用户登录失败: $e');
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      logger.info('用户登出: ${_currentUser?.username}', tag: _tag);
      
      // 调用logout API来清除服务器端的session
      try {
        await _apiService.userApi.logout();
        logger.debug('成功调用logout API', tag: _tag);
      } catch (e) {
        logger.warning('调用logout API失败: $e', tag: _tag);
      }
      
      // 清除本地状态
      _currentUser = null;
      _isLoggedIn = false;
      
      // 清除客户端的Session数据（Cookies）
      _apiService.clearSession();
      
      logger.info('用户登出成功', tag: _tag);
    } catch (e) {
      logger.error('用户登出过程中发生错误', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('用户登出失败: $e');
    }
  }

  /// 检查用户登录状态
  Future<bool> checkAuthStatus() async {
    try {
      logger.debug('检查用户认证状态开始', tag: _tag);
      
      // 如果有本地用户信息，尝试验证Session状态
      if (_currentUser != null) {
        try {
          // 调用API验证Session有效性
          final response = await _apiService.userApi.checkAuthStatus();
          if (response != null && response['isAuthenticated'] == true) {
            logger.debug('Session验证成功', tag: _tag);
            _isLoggedIn = true;
            return true;
          }
        } catch (e) {
          logger.warning('Session验证失败: $e', tag: _tag);
          // 清除无效的认证状态
          _currentUser = null;
          _isLoggedIn = false;
          _apiService.clearSession();
        }
      }
      
      // 返回当前登录状态
      logger.debug('检查用户认证状态完成: $_isLoggedIn', tag: _tag);
      return _isLoggedIn;
    } catch (e) {
      logger.error('检查认证状态时发生错误', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('检查认证状态失败: $e');
    }
  }
}
