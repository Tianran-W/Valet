import 'package:flutter/material.dart';

/// 人力资源用户模型类 - 用于人力资源页面展示用户信息
class HRUser {
  final int userId;
  final String username;
  final String email;
  final String department;
  final String roleName;

  const HRUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.department,
    required this.roleName,
  });

  factory HRUser.fromJson(Map<String, dynamic> json) {
    // 处理可能的字段名变体
    final userId = json['userId'] ?? json['id'] ?? 0;
    final username = json['username'] ?? '';
    final email = json['email'] ?? '';
    
    // 处理部门字段 - 可能为null、空字符串或缺失
    String department = json['department'] ?? '';
    if (department.isEmpty) {
      department = '未分配部门';
    }
    
    // 处理角色字段 - 兼容多种可能的字段名
    final roleName = json['role_name'] ?? json['roleName'] ?? 'user';
    
    return HRUser(
      userId: userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
      username: username,
      email: email,
      department: department,
      roleName: roleName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'department': department,
      'role_name': roleName,
    };
  }

  /// 获取角色显示名称
  String get roleDisplayName {
    switch (roleName) {
      case 'admin':
        return '管理员';
      case 'user':
        return '普通用户';
      default:
        return '未知角色';
    }
  }

  /// 检查是否为管理员
  bool get isAdmin => roleName == 'admin';

  /// 获取显示用的部门名称
  String get displayDepartment {
    if (department.isEmpty || department == '未分配部门') {
      return '未分配部门';
    }
    return department;
  }

  /// 获取角色颜色
  Color get roleColor {
    return isAdmin ? Colors.red : Colors.blue;
  }
}
