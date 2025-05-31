import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 发起审批对话框
class CreateApprovalDialog extends StatefulWidget {
  final Function(Approval) onSubmit;

  const CreateApprovalDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CreateApprovalDialog> createState() => _CreateApprovalDialogState();
}

class _CreateApprovalDialogState extends State<CreateApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialIdController = TextEditingController();
  final _materialNameController = TextEditingController();
  final _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _materialIdController.dispose();
    _materialNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发起新审批'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 物资ID
              TextFormField(
                controller: _materialIdController,
                decoration: const InputDecoration(
                  labelText: '物资ID *',
                  hintText: '请输入物资ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物资ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 物资名称
              TextFormField(
                controller: _materialNameController,
                decoration: const InputDecoration(
                  labelText: '物资名称 *',
                  hintText: '请输入物资名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物资名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 申请原因
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '申请原因 *',
                  hintText: '请输入申请原因',
                  alignLabelWithHint: true,
                ),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('提交'),
        ),
      ],
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 创建审批ID
      final now = DateTime.now();
      final id = 'AP${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      
      // 创建审批对象
      final approval = Approval(
        id: id,
        materialId: _materialIdController.text.trim(),
        materialName: _materialNameController.text.trim(),
        applicantId: '1', // 实际应用中应该从用户认证服务获取
        applicantName: '当前用户', // 实际应用中应该从用户认证服务获取
        reason: _reasonController.text.trim(),
        status: ApprovalStatus.pending,
        currentApprover: '张经理', // 假设默认审批人
      );
      
      // 调用回调函数
      widget.onSubmit(approval);
      
      // 关闭对话框
      Navigator.pop(context);
    }
  }
}
