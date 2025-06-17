import 'package:valet/service/api/user_api.dart';
import 'package:valet/user/models/hr_user_model.dart';
import 'package:valet/service/logger_service.dart';

/// 人力资源服务类
class HRService {
  final UserApi _userApi;

  HRService(this._userApi);

  /// 获取全部用户
  Future<List<HRUser>> getAllUsers() async {
    try {
      logger.info('开始获取全部用户', tag: 'HRService');
      
      final response = await _userApi.getAllUsers();
      
      if (response == null) {
        logger.warning('获取用户列表返回空数据', tag: 'HRService');
        return [];
      }

      final users = response.map((userData) => HRUser.fromJson(userData)).toList();
      
      logger.info('成功获取 ${users.length} 个用户', tag: 'HRService');
      
      return users;
    } catch (e) {
      logger.error('获取全部用户失败: $e', tag: 'HRService');
      rethrow;
    }
  }

  /// 按部门分组用户
  Map<String, List<HRUser>> groupUsersByDepartment(List<HRUser> users) {
    final Map<String, List<HRUser>> groupedUsers = {};
    
    for (final user in users) {
      final department = user.displayDepartment;
      if (!groupedUsers.containsKey(department)) {
        groupedUsers[department] = [];
      }
      groupedUsers[department]!.add(user);
    }
    
    return groupedUsers;
  }

  /// 获取管理员用户列表
  List<HRUser> getAdminUsers(List<HRUser> users) {
    return users.where((user) => user.isAdmin).toList();
  }

  /// 获取普通用户列表
  List<HRUser> getNormalUsers(List<HRUser> users) {
    return users.where((user) => !user.isAdmin).toList();
  }
}
