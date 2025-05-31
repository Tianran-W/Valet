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

/// 物品模型类
class Item {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final InventoryStatus status;
  final String? borrowedBy;
  final bool isValuable;
  final String? serialNumber;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
    this.borrowedBy,
    this.isValuable = false,
    this.serialNumber,
  });
  
  /// 从JSON映射创建Item实例
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      status: InventoryStatus.fromString(json['status'] as String),
      borrowedBy: json['borrowed_by'] as String?,
      isValuable: json['is_valuable'] as bool? ?? false,
      serialNumber: json['serial_number'] as String?,
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
      if (borrowedBy != null) 'borrowed_by': borrowedBy,
      if (serialNumber != null) 'serial_number': serialNumber,
    };
  }
}
