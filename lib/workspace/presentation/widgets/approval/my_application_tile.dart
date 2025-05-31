import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 我发起的申请卡片
class MyApplicationTile extends StatelessWidget {
  final Approval application;
  final Function(Approval) onTap;
  final Function(Approval)? onWithdraw;

  const MyApplicationTile({
    super.key,
    required this.application,
    required this.onTap,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final bool pending = application.status == ApprovalStatus.pending;
    final bool approved = application.status == ApprovalStatus.approved;
    
    return ListTile(
      title: Text('${application.materialName} (ID: ${application.materialId})'),
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
                '申请时间: ${application.submitTime}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '申请原因: ${application.reason}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          if (pending)
            Text(
              '当前审批人: ${application.currentApprover}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          if (approved)
            Text(
              '审批通过时间: ${application.approveTime}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: approved 
                  ? Colors.green.shade100 
                  : pending 
                      ? Colors.orange.shade100 
                      : Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              application.status.name,
              style: TextStyle(
                color: approved 
                    ? Colors.green.shade700 
                    : pending 
                        ? Colors.orange.shade700 
                        : Colors.red.shade700,
              ),
            ),
          ),
          if (pending && onWithdraw != null)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
              tooltip: '撤回申请',
              onPressed: () => onWithdraw!(application),
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => onTap(application),
    );
  }
}
