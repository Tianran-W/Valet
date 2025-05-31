import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/workspace/presentation/widgets/approval/detail_row.dart';

/// 审批详情对话框
class ApprovalDetailDialog extends StatelessWidget {
  final Approval approval;
  final String title;

  const ApprovalDetailDialog({
    super.key,
    required this.approval,
    this.title = '审批详情',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DetailRowWidget(label: '申请编号', value: approval.id),
            DetailRowWidget(label: '申请标题', value: approval.title),
            if (approval.applicant != null)
              DetailRowWidget(label: '申请人', value: approval.applicant),
            if (approval.department != null)
              DetailRowWidget(label: '所属部门', value: approval.department),
            DetailRowWidget(label: '申请类型', value: approval.type.name),
            DetailRowWidget(label: '提交时间', value: approval.submitTime),
            if (approval.status == ApprovalStatus.approved || approval.status == ApprovalStatus.rejected)
              DetailRowWidget(label: '审批时间', value: approval.approveTime),
            DetailRowWidget(label: '审批状态', value: approval.status.name),
            if (approval.status == ApprovalStatus.rejected && approval.rejectReason != null)
              DetailRowWidget(label: '驳回原因', value: approval.rejectReason),
            if (approval.urgent == true)
              DetailRowWidget(label: '紧急程度', value: '加急'),
            if (approval.status == ApprovalStatus.processing && approval.currentApprover != null)
              DetailRowWidget(label: '当前审批人', value: approval.currentApprover),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
