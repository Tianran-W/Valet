import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';

/// 权限检查组件
class AdminOnlyPage extends StatelessWidget {
  final String pageName;
  
  const AdminOnlyPage({
    super.key,
    required this.pageName,
  });
  
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    
    // 检查用户权限，只有管理员才能看到此页面
    if (!(authService.currentUser?.isAdmin ?? false)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_accounts,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '权限不足',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '只有管理员才能访问$pageName功能',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return Center(child: Text('$pageName页面'));
  }
}

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminOnlyPage(pageName: '采购管理');
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminOnlyPage(pageName: '系统设置');
  }
}
