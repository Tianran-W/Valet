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
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _reasonController = TextEditingController();
  
  bool _isUrgent = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
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
              // 审批标题
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '审批标题 *',
                  hintText: '请输入审批标题',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入审批标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 所属部门
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: '所属部门 *',
                  hintText: '请输入所属部门',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入所属部门';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 申请理由
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '申请理由 *',
                  hintText: '请输入申请理由',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入申请理由';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 加急选项
              SwitchListTile(
                title: const Text('加急审批'),
                subtitle: const Text('加急审批将优先处理'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
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
      
      // 创建提交时间
      final submitTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      // 创建审批对象
      final approval = Approval(
        id: id,
        title: _titleController.text.trim(),
        applicant: '当前用户', // 实际应用中应该从用户认证服务获取
        department: _departmentController.text.trim(),
        submitTime: submitTime,
        status: ApprovalStatus.processing,
        urgent: _isUrgent,
        currentApprover: '张经理', // 假设默认审批人
      );
      
      // 调用回调函数
      widget.onSubmit(approval);
      
      // 关闭对话框
      Navigator.pop(context);
    }
  }
}
