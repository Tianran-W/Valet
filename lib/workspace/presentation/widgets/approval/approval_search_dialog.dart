import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 审批搜索对话框
class ApprovalSearchDialog extends StatefulWidget {
  final List<Approval> approvals;
  final Function(Approval) onSelect;

  const ApprovalSearchDialog({
    super.key,
    required this.approvals,
    required this.onSelect,
  });

  @override
  State<ApprovalSearchDialog> createState() => _ApprovalSearchDialogState();
}

class _ApprovalSearchDialogState extends State<ApprovalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Approval> _filteredApprovals = [];
  
  @override
  void initState() {
    super.initState();
    _filteredApprovals = List.from(widget.approvals);
    _searchController.addListener(_filterApprovals);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterApprovals);
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterApprovals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApprovals = List.from(widget.approvals);
      } else {
        _filteredApprovals = widget.approvals.where((approval) {
          return approval.materialName.toLowerCase().contains(query) ||
                 approval.materialId.toLowerCase().contains(query) ||
                 approval.applicantName.toLowerCase().contains(query) ||
                 approval.reason.toLowerCase().contains(query) ||
                 approval.id.toLowerCase().contains(query);
        }).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '搜索审批申请',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '搜索',
                hintText: '输入关键词搜索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: _filteredApprovals.isEmpty
                    ? const Center(child: Text('没有找到匹配的审批申请'))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredApprovals.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final approval = _filteredApprovals[index];
                          return ListTile(
                            title: Text('${approval.materialName} (ID: ${approval.materialId})'),
                            subtitle: Text('${approval.id} - 申请人: ${approval.applicantName}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(approval.status).withAlpha(51),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                approval.status.name,
                                style: TextStyle(
                                  color: _getStatusColor(approval.status),
                                ),
                              ),
                            ),
                            onTap: () {
                              widget.onSelect(approval);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.pending:
        return Colors.blue;
    }
  }
}
