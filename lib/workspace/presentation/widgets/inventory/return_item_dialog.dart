import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 归还物品对话框
class ReturnItemDialog extends StatelessWidget {
  final Item item;
  final int userId;
  
  const ReturnItemDialog({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('归还物品：${item.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 物品基本信息
            _buildItemInfo(context),
            
            const SizedBox(height: 24),
            const Text(
              '确认要归还此物品吗？',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            // 构建归还数据
            final data = {
              'materialId': item.id,
              'userId': userId,
            };
            
            // 返回数据
            Navigator.of(context).pop(data);
          },
          child: const Text('确认归还'),
        ),
      ],
    );
  }
  
  // 构建物品基本信息
  Widget _buildItemInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('物品ID', item.id),
          _infoRow('物品名称', item.name),
          _infoRow('类别', item.category),
          _infoRow('状态', item.status.displayName),
        ],
      ),
    );
  }
  
  // 显示信息行
  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }
}
