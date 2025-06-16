import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/user/presentation/pages/change_password_page.dart';
import 'package:valet/user/presentation/pages/login_page.dart';

/// 用户设置页面
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
  }

  /// 处理登出
  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 用户信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user?.avatarUrl != null 
                          ? NetworkImage(user!.avatarUrl!) 
                          : null,
                        child: user?.avatarUrl == null 
                          ? Text(
                              user?.username.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 24),
                            )
                          : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? '未知用户',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user?.isAdmin == true ? Colors.red.shade100 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: user?.isAdmin == true ? Colors.red.shade300 : Colors.blue.shade300,
                                ),
                              ),
                              child: Text(
                                user?.role.displayName ?? '用户',
                                style: TextStyle(
                                  color: user?.isAdmin == true ? Colors.red.shade700 : Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 设置选项
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('修改密码'),
                  subtitle: const Text('更改您的登录密码'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于'),
                  subtitle: const Text('科研设备管理系统 v1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: '科研设备管理系统',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text('一个用于管理科研设备的移动应用程序'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 登出按钮
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                '退出登录',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认退出'),
                    content: const Text('确定要退出登录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleLogout();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
