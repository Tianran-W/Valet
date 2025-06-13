import 'package:valet/service/logger_service.dart';
import 'package:valet/user/models/user_model.dart';

/// 认证服务类，处理用户登录、登出等认证相关功能
class AuthService {
  static const String _tag = 'AuthService';
  
  User? _currentUser;
  bool _isLoggedIn = false;

  /// 获取当前登录用户
  User? get currentUser => _currentUser;

  /// 获取登录状态
  bool get isLoggedIn => _isLoggedIn;

  /// 用户登录
  /// [username] 用户名
  /// [password] 密码
  Future<bool> login(String username, String password) async {
    try {
      logger.info('用户登录请求: $username', tag: _tag);
      
      // 简单的模拟登录验证
      // 在实际应用中，这里应该调用API进行认证
      if (_isValidCredentials(username, password)) {
        _currentUser = User(
          id: '1',
          username: username,
          email: '$username@example.com',
          avatarUrl: null,
        );
        _isLoggedIn = true;
        
        logger.info('用户登录成功: $username', tag: _tag);
        return true;
      } else {
        logger.warning('用户登录失败：用户名或密码错误', tag: _tag);
        return false;
      }
    } catch (e) {
      logger.error('用户登录过程中发生错误', tag: _tag, error: e);
      return false;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      logger.info('用户登出: ${_currentUser?.username}', tag: _tag);
      _currentUser = null;
      _isLoggedIn = false;
      logger.info('用户登出成功', tag: _tag);
    } catch (e) {
      logger.error('用户登出过程中发生错误', tag: _tag, error: e);
    }
  }

  /// 检查用户登录状态
  Future<bool> checkAuthStatus() async {
    try {
      // 在实际应用中，这里可以检查token有效性
      // 现在只是简单返回当前状态
      logger.debug('检查用户认证状态: $_isLoggedIn', tag: _tag);
      return _isLoggedIn;
    } catch (e) {
      logger.error('检查认证状态时发生错误', tag: _tag, error: e);
      return false;
    }
  }

  /// 验证登录凭据（模拟）
  /// 在实际应用中，这里应该调用后端API进行验证
  bool _isValidCredentials(String username, String password) {
    // 简单的演示用账号
    const validCredentials = {
      'admin': 'admin123',
      'manager': 'manager123',
      'user': 'user123',
    };

    return validCredentials[username] == password;
  }

  /// 获取有效的演示账号列表（仅用于开发和演示）
  List<Map<String, String>> getValidDemoAccounts() {
    return [
      {'username': 'admin', 'password': 'admin123', 'role': '管理员'},
      {'username': 'manager', 'password': 'manager123', 'role': '经理'},
      {'username': 'user', 'password': 'user123', 'role': '用户'},
    ];
  }
}
