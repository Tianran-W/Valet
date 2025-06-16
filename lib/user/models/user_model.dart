/// 用户角色枚举
enum UserRole {
  admin('admin', '管理员'),
  user('user', '普通用户');

  const UserRole(this.value, this.displayName);
  final String value;
  final String displayName;

  /// 从字符串值创建角色枚举
  static UserRole fromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user; // 默认为普通用户
    }
  }
}

/// 用户模型类
class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final UserRole role;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.role = UserRole.user, // 默认为普通用户
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: UserRole.fromString(json['role']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.value,
    };
  }

  /// 检查用户是否为管理员
  bool get isAdmin => role == UserRole.admin;

  /// 检查用户是否为普通用户
  bool get isUser => role == UserRole.user;
}
