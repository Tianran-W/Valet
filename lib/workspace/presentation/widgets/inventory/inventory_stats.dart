import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/presentation/widgets/stat_card.dart';

/// 库存统计组件
class InventoryStats extends StatelessWidget {
  final List<Item> items;

  const InventoryStats({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCardWidget(
          title: '物品总数',
          value: '${items.length}',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        StatCardWidget(
          title: '已借出',
          value: '${items.where((item) => item.status == InventoryStatus.onLoan).length}',
          icon: Icons.person,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        StatCardWidget(
          title: '维修中',
          value: '${items.where((item) => item.status == InventoryStatus.maintenance).length}',
          icon: Icons.build,
          color: Colors.orange,
        ),
        const SizedBox(width: 16),
        StatCardWidget(
          title: '已报废',
          value: '${items.where((item) => item.status == InventoryStatus.scrapped).length}',
          icon: Icons.delete_outline,
          color: Colors.red,
        ),
      ],
    );
  }
}
