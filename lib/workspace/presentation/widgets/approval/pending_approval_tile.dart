import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 待审批项目卡片
class PendingApprovalTile extends StatelessWidget {
  final Approval approval;
  final Function(Approval, bool) onApproveReject;
  final Function(Approval) onTap;

  const PendingApprovalTile({
    super.key,
    required this.approval,
    required this.onApproveReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text('${approval.materialName} (ID: ${approval.materialId})'),
          const SizedBox(width: 8),
        ],
      ),
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
                  '物资借用申请',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '申请人: ${approval.applicantName}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '申请原因: ${approval.reason}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => onApproveReject(approval, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(60, 36),
            ),
            child: const Text('通过'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => onApproveReject(approval, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(60, 36),
            ),
            child: const Text('驳回'),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => onTap(approval),
    );
  }
}
