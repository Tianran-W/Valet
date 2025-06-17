import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/presentation/widgets/image_upload_widget.dart';

/// 物资报废对话框
class ScrapItemDialog extends StatefulWidget {
  final Item item;
  
  const ScrapItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<ScrapItemDialog> createState() => _ScrapItemDialogState();
}

class _ScrapItemDialogState extends State<ScrapItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  // 图片相关
  List<RecordImage> _uploadedImages = [];
  final int _tempRecordId = DateTime.now().millisecondsSinceEpoch; // 临时记录ID

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('物资报废：${widget.item.name}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 物品基本信息
                _buildItemInfo(context),
                
                const SizedBox(height: 24),
                
                // 警告提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '警告：物资报废后将无法恢复，请确认操作！',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 报废原因
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: '报废原因 *',
                    hintText: '请详细说明物资报废的原因',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入报废原因';
                    }
                    if (value.trim().length < 5) {
                      return '报废原因至少需要5个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 图片上传组件
                Text(
                  '报废凭证图片（可选）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '建议上传报废物资的现状照片作为凭证',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ImageUploadWidget(
                    recordType: RecordType.scrap,
                    materialId: widget.item.id, // 使用物品的实际ID
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
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(_uploadedImages.isEmpty ? '确认报废' : '确认报废 (${_uploadedImages.length}张图片)'),
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
          _infoRow('物品ID', widget.item.id),
          _infoRow('物品名称', widget.item.name),
          _infoRow('类别', widget.item.category),
          _infoRow('状态', widget.item.status.displayName),
          if (widget.item.serialNumber != null && widget.item.serialNumber!.isNotEmpty)
            _infoRow('SN码', widget.item.serialNumber!),
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
      // 构建报废数据
      final data = {
        'materialId': widget.item.id,
        'reason': _reasonController.text.trim(),
        // 添加图片相关信息
        'uploadedImages': _uploadedImages,
        'tempRecordId': _tempRecordId,
      };
      
      // 返回数据
      Navigator.of(context).pop(data);
    }
  }
}
