import 'package:flutter/material.dart';

// Drawer菜单项数据结构
class DrawerMenuItem {
  final String title;
  final IconData icon;
  final bool requiresAdmin; // 是否需要管理员权限
  
  const DrawerMenuItem({
    required this.title, 
    required this.icon, 
    this.requiresAdmin = false, // 默认不需要管理员权限
  });
}

// Drawer菜单项小部件
class DrawerListTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color selectedTileColor;

  const DrawerListTile({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.selectedTileColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: selectedTileColor,
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
