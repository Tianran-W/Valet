import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/presentation/widgets/image_upload_widget.dart';

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
  
  // 图片相关
  List<RecordImage> _uploadedImages = [];
  final int _tempRecordId = DateTime.now().millisecondsSinceEpoch; // 临时记录ID
  
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
      content: SizedBox(
        width: double.maxFinite,
        height: 600, // 增加高度以容纳图片上传组件
        child: Form(
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
                const SizedBox(height: 16),
                
                // 图片上传组件
                Text(
                  '相关图片（可选）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ImageUploadWidget(
                    recordType: RecordType.borrow,
                    recordId: _tempRecordId, // 使用临时ID，稍后会替换
                    onImagesChanged: (images) {
                      setState(() {
                        _uploadedImages = images;
                      });
                    },
                    maxImages: 5,
                  ),
                ),
              ],
            ),
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
          child: Text(_uploadedImages.isEmpty ? '借用' : '借用 (${_uploadedImages.length}张图片)'),
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
        // 添加图片相关信息
        'uploadedImages': _uploadedImages,
        'tempRecordId': _tempRecordId,
      };
      
      // 返回数据
      Navigator.of(context).pop(data);
    }
  }
}
