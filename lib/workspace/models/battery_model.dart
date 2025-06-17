// 电池相关数据模型
//
// 定义电池基本信息、状态历史和相关的数据传输对象

/// 电池基本信息模型
class Battery {
  final int materialId;
  final String modelName;
  final String snCode;
  final String status;
  final int lifespanCycles;
  final int currentCycles;

  const Battery({
    required this.materialId,
    required this.modelName,
    required this.snCode,
    required this.status,
    required this.lifespanCycles,
    required this.currentCycles,
  });

  /// 从JSON映射创建Battery实例
  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      materialId: json['materialId'] is int ? json['materialId'] : int.tryParse(json['materialId']?.toString() ?? '0') ?? 0,
      modelName: json['modelName']?.toString() ?? '',
      snCode: json['snCode']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lifespanCycles: json['lifespanCycles'] is int ? json['lifespanCycles'] : int.tryParse(json['lifespanCycles']?.toString() ?? '0') ?? 0,
      currentCycles: json['currentCycles'] is int ? json['currentCycles'] : int.tryParse(json['currentCycles']?.toString() ?? '0') ?? 0,
    );
  }

  /// 将Battery实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'modelName': modelName,
      'snCode': snCode,
      'status': status,
      'lifespanCycles': lifespanCycles,
      'currentCycles': currentCycles,
    };
  }

  /// 计算电池健康度百分比
  double get healthPercentage {
    if (lifespanCycles <= 0) return 100.0;
    return ((lifespanCycles - currentCycles) / lifespanCycles * 100).clamp(0.0, 100.0);
  }

  /// 获取电池状态颜色
  BatteryStatusColor get statusColor {
    final health = healthPercentage;
    if (health >= 80) return BatteryStatusColor.excellent;
    if (health >= 60) return BatteryStatusColor.good;
    if (health >= 40) return BatteryStatusColor.fair;
    if (health >= 20) return BatteryStatusColor.poor;
    return BatteryStatusColor.critical;
  }

  /// 获取电池状态文本
  String get statusText {
    final health = healthPercentage;
    if (health >= 80) return '优秀';
    if (health >= 60) return '良好';
    if (health >= 40) return '一般';
    if (health >= 20) return '较差';
    return '极差';
  }

  /// 是否需要更换
  bool get needsReplacement => healthPercentage < 20;

  /// 复制对象并更新某些字段
  Battery copyWith({
    int? materialId,
    String? modelName,
    String? snCode,
    String? status,
    int? lifespanCycles,
    int? currentCycles,
  }) {
    return Battery(
      materialId: materialId ?? this.materialId,
      modelName: modelName ?? this.modelName,
      snCode: snCode ?? this.snCode,
      status: status ?? this.status,
      lifespanCycles: lifespanCycles ?? this.lifespanCycles,
      currentCycles: currentCycles ?? this.currentCycles,
    );
  }
}

/// 电池状态历史记录模型
class BatteryStatusHistory {
  final String recordTime;
  final int batteryLevel;
  final String batteryHealth;

  const BatteryStatusHistory({
    required this.recordTime,
    required this.batteryLevel,
    required this.batteryHealth,
  });

  /// 从JSON映射创建BatteryStatusHistory实例
  factory BatteryStatusHistory.fromJson(Map<String, dynamic> json) {
    return BatteryStatusHistory(
      recordTime: json['recordTime']?.toString() ?? '',
      batteryLevel: json['batteryLevel'] is int ? json['batteryLevel'] : int.tryParse(json['batteryLevel']?.toString() ?? '0') ?? 0,
      batteryHealth: json['batteryHealth']?.toString() ?? '',
    );
  }

  /// 将BatteryStatusHistory实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'recordTime': recordTime,
      'batteryLevel': batteryLevel,
      'batteryHealth': batteryHealth,
    };
  }
}

/// 电池状态提交模型
class BatteryStatusSubmit {
  final int materialId;
  final int batteryLevel;
  final String batteryHealth;

  const BatteryStatusSubmit({
    required this.materialId,
    required this.batteryLevel,
    required this.batteryHealth,
  });

  /// 将BatteryStatusSubmit实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'batteryLevel': batteryLevel,
      'batteryHealth': batteryHealth,
    };
  }
}

/// 新增电池模型
class AddBatteryRequest {
  final String modelName;
  final String snCode;
  final int lifespanCycles;
  final int isExpensive;

  const AddBatteryRequest({
    required this.modelName,
    required this.snCode,
    required this.lifespanCycles,
    this.isExpensive = 0,
  });

  /// 将AddBatteryRequest实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'snCode': snCode,
      'lifespanCycles': lifespanCycles,
      'isExpensive': isExpensive,
    };
  }
}

/// 更新电池信息模型
class UpdateBatteryRequest {
  final String? modelName;
  final int? lifespanCycles;

  const UpdateBatteryRequest({
    this.modelName,
    this.lifespanCycles,
  });

  /// 将UpdateBatteryRequest实例转换为JSON映射
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (modelName != null) data['modelName'] = modelName;
    if (lifespanCycles != null) data['lifespanCycles'] = lifespanCycles;
    return data;
  }
}

/// 电池状态颜色枚举
enum BatteryStatusColor {
  excellent, // 优秀 (80-100%)
  good,      // 良好 (60-80%)
  fair,      // 一般 (40-60%)
  poor,      // 较差 (20-40%)
  critical,  // 极差 (0-20%)
}

/// 电池健康状态枚举
enum BatteryHealthStatus {
  excellent('优秀'),
  good('良好'),
  fair('一般'),
  poor('较差'),
  critical('极差');

  const BatteryHealthStatus(this.displayName);
  final String displayName;
}
