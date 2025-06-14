import 'package:valet/service/logger_service.dart';
import 'package:valet/user/models/user_model.dart';
import 'package:valet/service/api/api_service.dart';

/// 认证服务类，处理用户登录、登出等认证相关功能
class AuthService {
  final ApiService _apiService;
  static const String _tag = 'AuthService';
  
  User? _currentUser;
  bool _isLoggedIn = false;
  String? _authToken;

  /// 获取当前登录用户
  User? get currentUser => _currentUser;

  /// 获取登录状态
  bool get isLoggedIn => _isLoggedIn;

  /// 获取认证token
  String? get authToken => _authToken;

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
      if (response != null) {
        // 从响应中提取用户信息和token
        // 这里需要根据实际API响应格式调整
        _currentUser = User(
          id: response['userId']?.toString() ?? '1',
          username: username,
          email: response['email']?.toString() ?? '$username@example.com',
          avatarUrl: response['avatarUrl']?.toString(),
        );
        
        // 保存认证token（如果API返回）
        _authToken = response['token']?.toString();
        if (_authToken != null) {
          // 更新API服务的认证头
          _apiService.updateAuthToken(_authToken!);
        }
        
        _isLoggedIn = true;
        logger.info('用户登录成功: $username', tag: _tag);
        return true;
      } else {
        logger.warning('用户登录失败：服务器响应为空', tag: _tag);
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
      
      // 如果有认证token，可以调用logout API
      if (_authToken != null) {
        try {
          await _apiService.userApi.logout();
          logger.debug('成功调用logout API', tag: _tag);
        } catch (e) {
          logger.warning('调用logout API失败: $e', tag: _tag);
        }
      }
      
      // 清除本地状态
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
      
      // 清除API服务的认证头
      _apiService.clearAuthToken();
      
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
      
      // 如果有本地token，尝试验证
      if (_authToken != null && _currentUser != null) {
        try {
          // 调用API验证token有效性
          final response = await _apiService.userApi.checkAuthStatus();
          if (response != null) {
            logger.debug('Token验证成功', tag: _tag);
            return true;
          }
        } catch (e) {
          logger.warning('Token验证失败: $e', tag: _tag);
          // 清除无效的认证状态
          _currentUser = null;
          _isLoggedIn = false;
          _authToken = null;
          _apiService.clearAuthToken();
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
