import 'package:flutter/material.dart';
import '../../../models/inventory_model.dart';
import 'status_tag.dart';

/// 库存物品列表项组件
class InventoryItemTile extends StatelessWidget {
  final Item item;
  final Function(Item) onTap;
  final Function(Item) onEdit;
  final Function(Item) onMoreActions;

  const InventoryItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onMoreActions,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(item),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(item.id.substring(1)),
      ),
      title: Text(item.name),
      subtitle: Text('${item.category.displayName} | ¥${item.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 库存状态标签
          StatusTagWidget(
            status: item.status.displayName,
            quantity: item.quantity.toString(),
          ),
          const SizedBox(width: 16),
          
          // 操作按钮
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => onEdit(item),
            tooltip: '编辑',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => onMoreActions(item),
            tooltip: '更多操作',
          ),
        ],
      ),
    );
  }
}
