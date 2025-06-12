import 'package:flutter/material.dart';
import 'package:valet/workspace/presentation/widgets/drawer_widgets.dart';
import 'package:valet/workspace/presentation/pages/approval_page.dart';
import 'package:valet/workspace/presentation/pages/dashboard_page.dart';
import 'package:valet/workspace/presentation/pages/inventory_page.dart';
import 'package:valet/workspace/presentation/pages/module_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const DashboardPage(),
    const InventoryPage(),
    const ApprovalPage(),
    const PurchasePage(),
    const HRPage(),
    const SettingsPage(),
  ];

  // 菜单项数据结构
  final List<DrawerMenuItem> _drawerMenuItems = [
    DrawerMenuItem(title: '仪表盘', icon: Icons.dashboard),
    DrawerMenuItem(title: '库存管理', icon: Icons.inventory),
    DrawerMenuItem(title: '请求审批', icon: Icons.approval),
    DrawerMenuItem(title: '采购管理', icon: Icons.shopping_cart),
    DrawerMenuItem(title: '人力资源', icon: Icons.people),
    DrawerMenuItem(title: '系统设置', icon: Icons.settings),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            onPressed: () {
              // 显示用户配置菜单
            },
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '科研设备管理',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '管理员',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // 用 map 生成菜单项
            ..._drawerMenuItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              // 在第7项后插入分割线
              if (idx == 7) {
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
      body: _pages[_selectedIndex],
    );
  }
}
