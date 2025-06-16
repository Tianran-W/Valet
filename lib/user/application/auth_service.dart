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
      if (response != null && 
          (response['success'] == true || 
           response['message'] == '登录成功' || 
           response['userId'] != null)) {
        // 从响应中提取用户信息
        _currentUser = User(
          id: response['userId']?.toString() ?? '1',
          username: response['username']?.toString() ?? username,
          email: response['email']?.toString() ?? '$username@example.com',
          avatarUrl: response['avatarUrl']?.toString(),
          role: UserRole.fromString(response['role']?.toString()),
        );
        
        _isLoggedIn = true;
        logger.info('用户登录成功: $username', tag: _tag);
        return true;
      } else {
        logger.warning('用户登录失败：服务器响应为空或登录失败', tag: _tag);
        logger.info('响应详情: $response', tag: _tag);
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
            
            // 获取并更新用户角色信息
            await _updateUserRole();
            
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
      return false;
    }
  }

  /// 用户注册
  /// [username] 用户名
  /// [password] 密码
  /// [email] 邮箱
  Future<bool> register(String username, String password, String email) async {
    try {
      logger.info('用户注册请求: $username', tag: _tag);
      
      // 调用注册API
      final response = await _apiService.userApi.register(username, password, email);
      
      // 处理注册响应
      if (response != null && response['success'] == true) {
        logger.info('用户注册成功: $username', tag: _tag);
        return true;
      } else {
        logger.warning('用户注册失败：服务器响应为空或注册失败', tag: _tag);
        return false;
      }
    } catch (e) {
      logger.error('用户注册失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('用户注册失败: $e');
    }
  }

  /// 修改密码
  /// [oldPassword] 原密码
  /// [newPassword] 新密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) {
        throw Exception('用户未登录');
      }
      
      logger.info('用户修改密码请求: ${_currentUser!.username}', tag: _tag);
      
      // 调用修改密码API
      final success = await _apiService.userApi.changePassword(
        oldPassword, 
        newPassword
      );
      
      if (success) {
        logger.info('用户修改密码成功: ${_currentUser!.username}', tag: _tag);
        return true;
      } else {
        logger.warning('用户修改密码失败', tag: _tag);
        return false;
      }
    } catch (e) {
      logger.error('修改密码失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('修改密码失败: $e');
    }
  }

  /// 更新用户角色信息
  Future<void> _updateUserRole() async {
    try {
      if (_currentUser == null) return;
      
      final response = await _apiService.userApi.getUserRole();
      if (response != null && response['role'] != null) {
        final newRole = UserRole.fromString(response['role'].toString());
        
        // 如果角色发生变化，更新用户信息
        if (_currentUser!.role != newRole) {
          _currentUser = User(
            id: _currentUser!.id,
            username: _currentUser!.username,
            email: _currentUser!.email,
            avatarUrl: _currentUser!.avatarUrl,
            role: newRole,
          );
          logger.info('用户角色已更新: ${newRole.displayName}', tag: _tag);
        }
      }
    } catch (e) {
      logger.warning('更新用户角色失败: $e', tag: _tag);
      // 不抛出异常，因为这是可选的更新操作
    }
  }

  /// 获取用户角色
  Future<UserRole?> getUserRole() async {
    try {
      if (_currentUser == null) {
        throw Exception('用户未登录');
      }
      
      final response = await _apiService.userApi.getUserRole();
      if (response != null && response['role'] != null) {
        final role = UserRole.fromString(response['role'].toString());
        
        // 更新本地用户角色信息
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          email: _currentUser!.email,
          avatarUrl: _currentUser!.avatarUrl,
          role: role,
        );
        
        return role;
      }
      
      return _currentUser?.role;
    } catch (e) {
      logger.error('获取用户角色失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取用户角色失败: $e');
    }
  }
}
