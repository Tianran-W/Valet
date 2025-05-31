// 库存管理相关的数据模型

/// 物品使用状态枚举
enum InventoryStatus {
  inStock('在库可借'),
  onLoan('已借出'),
  maintenance('维修中'),
  scrapped('已报废');

  final String label;
  const InventoryStatus(this.label);

  /// 从字符串转换为枚举值
  static InventoryStatus fromString(String status) {
    return switch (status) {
      '在库可借' => InventoryStatus.inStock,
      '已借出' => InventoryStatus.onLoan,
      '维修中' => InventoryStatus.maintenance,
      '已报废' => InventoryStatus.scrapped,
      _ => InventoryStatus.inStock,
    };
  }

  /// 将枚举值转换为显示文本
  String get displayName => label;
}

/// 物品类别模型
class Category {
  final int id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  /// 从JSON映射创建Category实例
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoryId'] is int ? json['categoryId'] : 0,
      name: json['categoryName']?.toString() ?? '',
    );
  }

  /// 将Category实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// 物品模型类
class Item {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final InventoryStatus status;
  final bool isValuable;
  final String? serialNumber;
  final int? usageLimit; 

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
    this.isValuable = false,
    this.serialNumber,
    this.usageLimit, 
  });
  
  /// 从JSON映射创建Item实例
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['materialId'] is int ? json['materialId'] : int.tryParse(json['materialId']?.toString() ?? '0') ?? 0,
      name: json['materialName']?.toString() ?? '',
      category: json['categoryName']?.toString() ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : 0,
      status: InventoryStatus.fromString(json['status']?.toString() ?? ''),
      isValuable: json['isExpensive'] == 1 || json['isExpensive'] == true,
      serialNumber: json['snCode']?.toString(),
      usageLimit: json['usageLimit'] is int ? json['usageLimit'] : null,
    );
  }
  
  /// 将Item实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'status': status.displayName,
      'is_valuable': isValuable,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (usageLimit != null) 'usage_limit': usageLimit,
    };
  }
}
