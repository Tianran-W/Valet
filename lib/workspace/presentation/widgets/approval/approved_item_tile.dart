import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 已审批项目卡片
class ApprovedItemTile extends StatelessWidget {
  final Approval approval;
  final Function(Approval) onTap;

  const ApprovedItemTile({
    super.key,
    required this.approval,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool approved = approval.status == ApprovalStatus.approved;
    
    return ListTile(
      title: Text(approval.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '借用申请',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '申请人: ${approval.applicant}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 8),
              Text(
                '部门: ${approval.department}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '申请时间: ${approval.submitTime}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            '审批时间: ${approval.approveTime}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          if (!approved && approval.rejectReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '驳回原因: ${approval.rejectReason}',
                style: TextStyle(fontSize: 13, color: Colors.red.shade700),
              ),
            ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: approved ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          approval.status.name,
          style: TextStyle(
            color: approved ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => onTap(approval),
    );
  }
}
