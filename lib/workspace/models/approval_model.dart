/// 审批类型
enum ApprovalType {
  purchase('采购'),
  repair('维修'),
  funding('经费'),
  leave('请假'),
  travel('出差');

  final String name;
  const ApprovalType(this.name);
}

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
  final ApprovalType type;
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
    required this.type,
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
      type: _getTypeFromString(map['type']),
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
      'type': type.name,
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

  // 辅助方法：从字符串获取类型枚举
  static ApprovalType _getTypeFromString(String typeStr) {
    switch (typeStr) {
      case '采购':
        return ApprovalType.purchase;
      case '维修':
        return ApprovalType.repair;
      case '经费':
        return ApprovalType.funding;
      case '请假':
        return ApprovalType.leave;
      case '出差':
        return ApprovalType.travel;
      default:
        return ApprovalType.purchase;
    }
  }
}

/// 示例数据
class ApprovalSampleData {
  // 待审批数据
  static List<Approval> getPendingApprovals() {
    return [
      Approval(
        id: 'AP2025060101',
        title: '设备采购申请',
        applicant: '张三',
        department: '研发部',
        submitTime: '2025-06-01 08:30',
        status: ApprovalStatus.pending,
        type: ApprovalType.purchase,
        urgent: true,
      ),
      Approval(
        id: 'AP2025060102',
        title: '实验室设备维修',
        applicant: '李四',
        department: '实验室',
        submitTime: '2025-05-31 16:45',
        status: ApprovalStatus.pending,
        type: ApprovalType.repair,
      ),
      Approval(
        id: 'AP2025060103',
        title: '研发经费追加申请',
        applicant: '王五',
        department: '研发部',
        submitTime: '2025-05-31 14:20',
        status: ApprovalStatus.pending,
        type: ApprovalType.funding,
        urgent: true,
      ),
      Approval(
        id: 'AP2025060104',
        title: '测试设备更换申请',
        applicant: '赵六',
        department: '测试部',
        submitTime: '2025-05-30 09:15',
        status: ApprovalStatus.pending,
        type: ApprovalType.purchase,
      ),
    ];
  }

  // 已审批数据
  static List<Approval> getApprovedItems() {
    return [
      Approval(
        id: 'AP2025052001',
        title: '服务器升级申请',
        applicant: '张三',
        department: '运维部',
        submitTime: '2025-05-20 10:30',
        approveTime: '2025-05-20 14:22',
        status: ApprovalStatus.approved,
        type: ApprovalType.purchase,
      ),
      Approval(
        id: 'AP2025051502',
        title: '办公设备更新',
        applicant: '李四',
        department: '行政部',
        submitTime: '2025-05-15 11:45',
        approveTime: '2025-05-16 09:30',
        status: ApprovalStatus.rejected,
        type: ApprovalType.purchase,
        rejectReason: '预算超限，请调整后重新提交',
      ),
    ];
  }

  // 我发起的申请
  static List<Approval> getMyApplications() {
    return [
      Approval(
        id: 'AP2025052501',
        title: '科研项目设备采购',
        submitTime: '2025-05-25 14:30',
        status: ApprovalStatus.processing,
        currentApprover: '李总监',
        type: ApprovalType.purchase,
      ),
      Approval(
        id: 'AP2025051001',
        title: '实验室耗材补充',
        submitTime: '2025-05-10 09:15',
        status: ApprovalStatus.approved,
        approveTime: '2025-05-12 11:30',
        type: ApprovalType.purchase,
      ),
    ];
  }
}
