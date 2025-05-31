/// 审批状态
enum ApprovalStatus {
  pending('待审批'),
  approved('已通过'),
  rejected('已驳回'),
  processing('审批中');

  final String name;
  const ApprovalStatus(this.name);
}

/// 审批单数据模型
class Approval {
  final String id;
  final String title;
  final String? applicant;
  final String? department;
  final String submitTime;
  final String? approveTime;
  final ApprovalStatus status;
  final bool? urgent;
  final String? rejectReason;
  final String? currentApprover;

  Approval({
    required this.id,
    required this.title,
    this.applicant,
    this.department,
    required this.submitTime,
    this.approveTime,
    required this.status,
    this.urgent = false,
    this.rejectReason,
    this.currentApprover,
  });

  // 从Map构建对象
  factory Approval.fromMap(Map<String, dynamic> map) {
    return Approval(
      id: map['id'],
      title: map['title'],
      applicant: map['applicant'],
      department: map['department'],
      submitTime: map['submitTime'],
      approveTime: map['approveTime'],
      status: _getStatusFromString(map['status']),
      urgent: map['urgent'] ?? false,
      rejectReason: map['rejectReason'],
      currentApprover: map['currentApprover'],
    );
  }

  // 将对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'applicant': applicant,
      'department': department,
      'submitTime': submitTime,
      'approveTime': approveTime,
      'status': status.name,
      'urgent': urgent,
      'rejectReason': rejectReason,
      'currentApprover': currentApprover,
    };
  }

  // 辅助方法：从字符串获取状态枚举
  static ApprovalStatus _getStatusFromString(String statusStr) {
    switch (statusStr) {
      case '待审批':
        return ApprovalStatus.pending;
      case '已通过':
        return ApprovalStatus.approved;
      case '已驳回':
        return ApprovalStatus.rejected;
      case '审批中':
        return ApprovalStatus.processing;
      default:
        return ApprovalStatus.pending;
    }
  }
}