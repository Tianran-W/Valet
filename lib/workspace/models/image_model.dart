// 图片管理相关的数据模型

/// 记录类型枚举
enum RecordType {
  borrow('borrow', '借用'),
  returnItem('return', '归还'),
  scrap('scrap', '报废');

  final String value;
  final String label;
  const RecordType(this.value, this.label);

  /// 从字符串转换为枚举值
  static RecordType fromString(String value) {
    return switch (value) {
      'borrow' => RecordType.borrow,
      'return' => RecordType.returnItem,
      'scrap' => RecordType.scrap,
      _ => RecordType.borrow,
    };
  }
}

/// 图片信息模型
class RecordImage {
  final int imageId;
  final RecordType recordType;
  final int recordId;
  final String imagePath;
  final DateTime uploadTime;

  const RecordImage({
    required this.imageId,
    required this.recordType,
    required this.recordId,
    required this.imagePath,
    required this.uploadTime,
  });

  /// 从JSON映射创建RecordImage实例
  factory RecordImage.fromJson(Map<String, dynamic> json) {
    return RecordImage(
      imageId: json['imageId'] is int ? json['imageId'] : int.tryParse(json['imageId']?.toString() ?? '0') ?? 0,
      recordType: RecordType.fromString(json['recordType']?.toString() ?? 'borrow'),
      recordId: json['recordId'] is int ? json['recordId'] : int.tryParse(json['recordId']?.toString() ?? '0') ?? 0,
      imagePath: json['imagePath']?.toString() ?? '',
      uploadTime: json['uploadTime'] != null 
        ? DateTime.tryParse(json['uploadTime']?.toString() ?? '') ?? DateTime.now()
        : DateTime.now(),
    );
  }

  /// 将RecordImage实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'recordType': recordType.value,
      'recordId': recordId,
      'imagePath': imagePath,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }
}

/// 图片上传响应模型
class ImageUploadResponse {
  final int imageId;
  final String imagePath;

  const ImageUploadResponse({
    required this.imageId,
    required this.imagePath,
  });

  /// 从JSON映射创建ImageUploadResponse实例
  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      imageId: json['imageId'] is int ? json['imageId'] : int.tryParse(json['imageId']?.toString() ?? '0') ?? 0,
      imagePath: json['imagePath']?.toString() ?? '',
    );
  }

  /// 将ImageUploadResponse实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'imagePath': imagePath,
    };
  }
}
