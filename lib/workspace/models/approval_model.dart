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
  final ApprovalStatus status;
  final String? approveTime;
  final String? rejectReason;
  final String? currentApprover;

  Approval({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.applicantId,
    required this.applicantName,
    required this.reason,
    required this.status,
    this.approveTime,
    this.rejectReason,
    this.currentApprover,
  });

  // 从Map构建对象
  factory Approval.fromMap(Map<String, dynamic> map) {
    return Approval(
      id: map['id']?.toString() ?? map['pending']?.toString() ?? '',
      materialId: map['materialId']?.toString() ?? '',
      materialName: map['materialName']?.toString() ?? '',
      applicantId: map['userId']?.toString() ?? map['applicantId']?.toString() ?? '',
      applicantName: map['username']?.toString() ?? map['applicantName']?.toString() ?? '',
      reason: map['approvalReason']?.toString() ?? map['reason']?.toString() ?? '',
      status: _getStatusFromString(map['approvalStatus']?.toString() ?? ''),
      approveTime: map['approveTime']?.toString(),
      rejectReason: map['rejectReason']?.toString(),
      currentApprover: map['currentApprover']?.toString(),
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
      'approveTime': approveTime,
      'status': status.name,
      'rejectReason': rejectReason,
      'currentApprover': currentApprover,
    };
  }

  // 辅助方法：从字符串获取状态枚举
  static ApprovalStatus _getStatusFromString(String? statusStr) {
    if (statusStr == null || statusStr.isEmpty) {
      return ApprovalStatus.pending;
    }
    
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