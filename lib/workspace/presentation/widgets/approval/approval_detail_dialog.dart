import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/workspace/presentation/widgets/detail_row.dart';

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
            DetailRowWidget(label: '物资ID', value: approval.materialId),
            DetailRowWidget(label: '物资名称', value: approval.materialName),
            DetailRowWidget(label: '申请用户ID', value: approval.applicantId),
            DetailRowWidget(label: '申请用户名', value: approval.applicantName),
            DetailRowWidget(label: '申请原因', value: approval.reason),
            DetailRowWidget(label: '申请类型', value: '物资借用申请'),
            if (approval.status == ApprovalStatus.approved || approval.status == ApprovalStatus.rejected)
              DetailRowWidget(label: '审批时间', value: approval.approveTime),
            DetailRowWidget(label: '审批状态', value: approval.status.name),
            if (approval.status == ApprovalStatus.rejected && approval.rejectReason != null)
              DetailRowWidget(label: '驳回原因', value: approval.rejectReason),
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
