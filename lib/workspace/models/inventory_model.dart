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

/// 物品类别枚举
enum ProductCategory {
  all('全部'),
  mechanical('机械'),
  electronics('电控'),
  vision('视觉'),
  hardware('硬件');

  final String label;
  const ProductCategory(this.label);

  /// 从字符串转换为枚举值
  static ProductCategory fromString(String category) {
    return switch (category) {
      '机械' => ProductCategory.mechanical,
      '电控' => ProductCategory.electronics,
      '视觉' => ProductCategory.vision,
      '硬件' => ProductCategory.hardware,
      _ => ProductCategory.all,
    };
  }

  /// 将枚举值转换为显示文本
  String get displayName => label;
}

/// 物品模型类
class Item {
  final String id;
  final String name;
  final ProductCategory category;
  final double price;
  final int quantity;
  final InventoryStatus status;
  final String lastUpdate;
  final String? borrowedBy; // 借用人信息，仅当状态为已借出时有值

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.status,
    required this.lastUpdate,
    this.borrowedBy,
  });
  
  /// 从JSON映射创建Item实例
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ProductCategory.fromString(json['category'] as String),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      status: InventoryStatus.fromString(json['status'] as String),
      lastUpdate: json['last_update'] as String,
      borrowedBy: json['borrowed_by'] as String?,
    );
  }
  
  /// 将Item实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.displayName,
      'price': price,
      'quantity': quantity,
      'status': status.displayName,
      'last_update': lastUpdate,
      if (borrowedBy != null) 'borrowed_by': borrowedBy,
    };
  }
}
