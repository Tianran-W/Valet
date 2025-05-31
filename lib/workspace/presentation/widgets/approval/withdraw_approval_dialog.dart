import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 撤回申请对话框
class WithdrawApprovalDialog extends StatefulWidget {
  final Approval approval;
  final Function(Approval) onWithdraw;

  const WithdrawApprovalDialog({
    super.key,
    required this.approval,
    required this.onWithdraw,
  });

  @override
  State<WithdrawApprovalDialog> createState() => _WithdrawApprovalDialogState();
}

class _WithdrawApprovalDialogState extends State<WithdrawApprovalDialog> {
  final TextEditingController _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('撤回申请'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('申请编号: ${widget.approval.id}'),
          const SizedBox(height: 8),
          Text('物资名称: ${widget.approval.materialName}'),
          const SizedBox(height: 8),
          Text('申请原因: ${widget.approval.reason}'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: '撤回原因',
              border: OutlineInputBorder(),
              hintText: '请输入撤回原因（可选）',
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
          onPressed: () {
            widget.onWithdraw(widget.approval);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text('确认撤回'),
        ),
      ],
    );
  }
}
