import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:valet/workspace/presentation/widgets/drawer.dart';
import 'package:valet/workspace/presentation/pages/approval_page.dart';
import 'package:valet/workspace/presentation/pages/dashboard_page.dart';
import 'package:valet/workspace/presentation/pages/inventory_page.dart';
import 'package:valet/workspace/presentation/pages/battery_page.dart';
import 'package:valet/workspace/presentation/pages/module_pages.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/user/presentation/pages/login_page.dart';
import 'package:valet/user/presentation/pages/user_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
  }

  static final List<Widget> _pages = [
    const DashboardPage(),
    const InventoryPage(),
    const BatteryPage(),
    const ApprovalPage(),
    const PurchasePage(),
    const HRPage(),
    const SettingsPage(),
  ];

  // 菜单项数据结构
  final List<DrawerMenuItem> _allDrawerMenuItems = [
    DrawerMenuItem(title: '仪表盘', icon: Icons.dashboard, requiresAdmin: false),
    DrawerMenuItem(title: '库存管理', icon: Icons.inventory, requiresAdmin: false),
    DrawerMenuItem(title: '电池管理', icon: Icons.battery_6_bar, requiresAdmin: false),
    DrawerMenuItem(title: '请求审批', icon: Icons.approval, requiresAdmin: true), // 只有管理员能看到
    DrawerMenuItem(title: '采购管理', icon: Icons.shopping_cart, requiresAdmin: true), // 只有管理员能看到
    DrawerMenuItem(title: '人力资源', icon: Icons.people, requiresAdmin: true), // 只有管理员能看到
    DrawerMenuItem(title: '系统设置', icon: Icons.settings, requiresAdmin: true), // 只有管理员能看到
  ];

  /// 根据用户角色获取可见的菜单项
  List<DrawerMenuItem> get _visibleDrawerMenuItems {
    final isAdmin = _authService.currentUser?.isAdmin ?? false;
    if (isAdmin) {
      return _allDrawerMenuItems; // 管理员可以看到所有菜单
    } else {
      return _allDrawerMenuItems.where((item) => !item.requiresAdmin).toList(); // 普通用户只能看到不需要管理员权限的菜单
    }
  }

  /// 根据用户角色获取可见的页面
  List<Widget> get _visiblePages {
    final isAdmin = _authService.currentUser?.isAdmin ?? false;
    if (isAdmin) {
      return _pages; // 管理员可以访问所有页面
    } else {
      // 普通用户可以访问前三个页面（仪表盘、库存管理、电池管理）
      return [
        const DashboardPage(),
        const InventoryPage(),
        const BatteryPage(),
      ];
    }
  }

  void _onItemTapped(int index) {
    // 确保索引在可见页面范围内
    final visiblePages = _visiblePages;
    if (index < visiblePages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// 显示用户菜单
  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  (_authService.currentUser?.username ?? '用户').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(_authService.currentUser?.username ?? '用户'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_authService.currentUser?.email ?? ''),
                  Text(
                    _authService.currentUser?.role.displayName ?? '用户',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('用户设置'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserSettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('登出'),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 处理登出
  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          // 通知图标
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {
              // 显示通知面板
            },
          ),
          // 用户配置
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
            ),
            onPressed: _showUserMenu,
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      (_authService.currentUser?.username ?? '用户').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _authService.currentUser?.username ?? '科研设备管理',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    _authService.currentUser?.role.displayName ?? '用户',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // 用 map 生成菜单项
            ..._visibleDrawerMenuItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              // 在第3项后插入分割线（仪表盘、库存管理、电池管理后）
              if (idx == 3 && _authService.currentUser?.isAdmin == true) {
                return Column(
                  children: [
                    const Divider(),
                    DrawerListTile(
                      selected: _selectedIndex == idx,
                      icon: item.icon,
                      title: item.title,
                      onTap: () {
                        _onItemTapped(idx);
                        Navigator.pop(context);
                      },
                      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
                    ),
                  ],
                );
              }
              return DrawerListTile(
                selected: _selectedIndex == idx,
                icon: item.icon,
                title: item.title,
                onTap: () {
                  _onItemTapped(idx);
                  Navigator.pop(context);
                },
                selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
              );
            }),
          ],
        ),
      ),
      body: _visiblePages[_selectedIndex],
    );
  }
}
