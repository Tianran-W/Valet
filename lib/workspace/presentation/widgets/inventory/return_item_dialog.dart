import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/presentation/widgets/image_upload_widget.dart';

/// 归还物品对话框
class ReturnItemDialog extends StatefulWidget {
  final Item item;
  final int userId;
  
  const ReturnItemDialog({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  State<ReturnItemDialog> createState() => _ReturnItemDialogState();
}

class _ReturnItemDialogState extends State<ReturnItemDialog> {
  // 图片相关
  List<RecordImage> _uploadedImages = [];
  final int _tempRecordId = DateTime.now().millisecondsSinceEpoch; // 临时记录ID

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('归还物品：${widget.item.name}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              
              // 图片上传组件
              Text(
                '归还状态图片（可选）',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '建议上传归还时的物品状态照片',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ImageUploadWidget(
                  recordType: RecordType.returnItem,
                  recordId: _tempRecordId,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            // 构建归还数据
            final data = {
              'materialId': widget.item.id,
              'userId': widget.userId,
              // 添加图片相关信息
              'uploadedImages': _uploadedImages,
              'tempRecordId': _tempRecordId,
            };
            
            // 返回数据
            Navigator.of(context).pop(data);
          },
          child: Text(_uploadedImages.isEmpty ? '确认归还' : '确认归还 (${_uploadedImages.length}张图片)'),
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
