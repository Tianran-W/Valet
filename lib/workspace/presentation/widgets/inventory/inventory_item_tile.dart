import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'status_tag.dart';

/// 库存物品列表项组件
class InventoryItemTile extends StatelessWidget {
  final Item item;
  final Function(Item) onTap;
  final Function(Item) onBorrow;
  final Function(Item) onReturn;
  final Function(Item) onMoreActions;

  const InventoryItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBorrow,
    required this.onReturn,
    required this.onMoreActions,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(item),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(item.id.toString()),
      ),
      title: Row(
        children: [
          Text(item.name),
          if (item.isValuable) 
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Tooltip(
                message: '贵重物品',
                child: Icon(
                  Icons.stars, 
                  size: 16, 
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        item.serialNumber != null && item.serialNumber!.isNotEmpty
        ? '${item.category} | ${item.serialNumber}'
        : item.category,
      ),
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
            icon: const Icon(Icons.send),
            onPressed: () => onBorrow(item),
            tooltip: '借用',
          ),
          IconButton(
            icon: const Icon(Icons.assignment_return),
            onPressed: () => onReturn(item),
            tooltip: '归还',
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
