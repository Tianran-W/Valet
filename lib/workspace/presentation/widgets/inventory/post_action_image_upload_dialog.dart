import 'package:flutter/material.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/presentation/widgets/image_upload_widget.dart';

/// 操作后图片上传对话框
class PostActionImageUploadDialog extends StatefulWidget {
  final String actionTitle; // 操作标题：如"借用成功"
  final String actionDescription; // 操作描述
  final RecordType recordType;
  final int recordId;
  final VoidCallback? onCompleted;

  const PostActionImageUploadDialog({
    super.key,
    required this.actionTitle,
    required this.actionDescription,
    required this.recordType,
    required this.recordId,
    this.onCompleted,
  });

  @override
  State<PostActionImageUploadDialog> createState() => _PostActionImageUploadDialogState();
}

class _PostActionImageUploadDialogState extends State<PostActionImageUploadDialog> {
  List<RecordImage> _uploadedImages = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.actionTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 操作成功提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.actionDescription,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 图片上传提示
            Text(
              '您可以上传相关图片（可选）:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            // 图片上传组件
            Expanded(
              child: ImageUploadWidget(
                recordType: widget.recordType,
                recordId: widget.recordId,
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
      actions: [
        if (_uploadedImages.isEmpty)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCompleted?.call();
            },
            child: const Text('跳过'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCompleted?.call();
          },
          child: Text(_uploadedImages.isEmpty ? '完成' : '完成 (${_uploadedImages.length}张图片)'),
        ),
      ],
    );
  }
}
