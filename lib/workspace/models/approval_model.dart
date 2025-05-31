/// 审批状态
enum ApprovalStatus {
  pending('待审批'),
  approved('通过'),
  rejected('拒绝');

  final String name;
  const ApprovalStatus(this.name);
}

/// 审批单数据模型
class Approval {
  final String id;
  final String materialId;
  final String materialName;
  final String applicantId;
  final String applicantName;
  final String reason;
  final String submitTime;
  final String? approveTime;
  final ApprovalStatus status;
  final String? rejectReason;
  final String? currentApprover;

  Approval({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.applicantId,
    required this.applicantName,
    required this.reason,
    required this.submitTime,
    this.approveTime,
    required this.status,
    this.rejectReason,
    this.currentApprover,
  });

  // 从Map构建对象
  factory Approval.fromMap(Map<String, dynamic> map) {
    return Approval(
      id: map['id'],
      materialId: map['materialId'],
      materialName: map['materialName'],
      applicantId: map['applicantId'],
      applicantName: map['applicantName'],
      reason: map['reason'],
      submitTime: map['submitTime'],
      approveTime: map['approveTime'],
      status: _getStatusFromString(map['status']),
      rejectReason: map['rejectReason'],
      currentApprover: map['currentApprover'],
    );
  }

  // 将对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialId': materialId,
      'materialName': materialName,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'reason': reason,
      'submitTime': submitTime,
      'approveTime': approveTime,
      'status': status.name,
      'rejectReason': rejectReason,
      'currentApprover': currentApprover,
    };
  }

  // 辅助方法：从字符串获取状态枚举
  static ApprovalStatus _getStatusFromString(String statusStr) {
    switch (statusStr) {
      case '待审批':
        return ApprovalStatus.pending;
      case '通过':
        return ApprovalStatus.approved;
      case '拒绝':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }
}