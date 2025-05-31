import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'inventory_item_tile.dart';

/// 库存物品列表组件
class InventoryItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onItemTap;
  final Function(Item) onItemBorrow;
  final Function(Item) onItemReturn;
  final Function(Item) onItemMoreActions;

  const InventoryItemList({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onItemBorrow,
    required this.onItemReturn,
    required this.onItemMoreActions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: items.isEmpty
          ? const Center(child: Text('没有找到匹配的物资'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return InventoryItemTile(
                  item: item,
                  onTap: onItemTap,
                  onBorrow: onItemBorrow,
                  onReturn: onItemReturn,
                  onMoreActions: onItemMoreActions,
                );
              },
            ),
    );
  }
}
