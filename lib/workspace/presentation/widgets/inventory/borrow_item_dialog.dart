import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 借用物品对话框
class BorrowItemDialog extends StatefulWidget {
  final Item item;
  final int userId;
  
  const BorrowItemDialog({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  State<BorrowItemDialog> createState() => _BorrowItemDialogState();
}

class _BorrowItemDialogState extends State<BorrowItemDialog> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _projectController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('借用物品：${widget.item.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 物品基本信息
              _buildItemInfo(),
              const SizedBox(height: 16),
              
              // 使用项目
              TextFormField(
                controller: _projectController,
                decoration: const InputDecoration(
                  labelText: '使用项目 *',
                  hintText: '请输入使用项目',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入使用项目';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 申请原因
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: '申请原因 *',
                  hintText: '请输入申请原因',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入申请原因';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('借用'),
        ),
      ],
    );
  }
  
  // 构建物品基本信息
  Widget _buildItemInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('物品ID', widget.item.id),
          _infoRow('物品名称', widget.item.name),
          _infoRow('类别', widget.item.category),
          _infoRow('状态', widget.item.status.displayName),
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
  
  // 提交表单
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建借用数据
      final data = {
        'materialId': widget.item.id,
        'userId': widget.userId,
        'isValuable': widget.item.isValuable,
        'usageProject': _projectController.text.trim(),
        'approvalReason': _reasonController.text.trim(),
      };
      
      // 返回数据
      Navigator.of(context).pop(data);
    }
  }
}
