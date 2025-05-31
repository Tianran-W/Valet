import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 审批操作对话框
class ApprovalActionDialog extends StatefulWidget {
  final Approval approval;
  final bool isApprove;
  final Function(Approval, bool, String?) onSubmit;

  const ApprovalActionDialog({
    super.key,
    required this.approval,
    required this.isApprove,
    required this.onSubmit,
  });

  @override
  State<ApprovalActionDialog> createState() => _ApprovalActionDialogState();
}

class _ApprovalActionDialogState extends State<ApprovalActionDialog> {
  final TextEditingController _remarkController = TextEditingController();
  
  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.isApprove ? '通过' : '驳回'}审批申请'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('申请编号: ${widget.approval.id}'),
          const SizedBox(height: 8),
          Text('物资名称: ${widget.approval.materialName}'),
          const SizedBox(height: 8),
          Text('申请人: ${widget.approval.applicantName}'),
          const SizedBox(height: 8),
          Text('申请原因: ${widget.approval.reason}'),
          const SizedBox(height: 16),
          TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              labelText: widget.isApprove ? '批注（可选）' : '驳回原因 *',
              border: const OutlineInputBorder(),
              hintText: widget.isApprove ? '请输入批注' : '请输入驳回原因',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isApprove ? '通过' : '驳回'),
        ),
      ],
    );
  }
  
  void _submit() {
    if (!widget.isApprove && _remarkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入驳回原因')),
      );
      return;
    }
    
    // 调用回调函数
    widget.onSubmit(
      widget.approval, 
      widget.isApprove, 
      _remarkController.text.isNotEmpty ? _remarkController.text : null
    );
    
    Navigator.pop(context);
  }
}
