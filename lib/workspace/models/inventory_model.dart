// 库存管理相关的数据模型

/// 商品库存状态枚举
enum InventoryStatus {
  normal('正常'),
  low('低库存'),
  outOfStock('缺货');

  final String label;
  const InventoryStatus(this.label);

  /// 从字符串转换为枚举值
  static InventoryStatus fromString(String status) {
    return switch (status) {
      '正常' => InventoryStatus.normal,
      '低库存' => InventoryStatus.low,
      '缺货' => InventoryStatus.outOfStock,
      _ => InventoryStatus.normal,
    };
  }

  /// 将枚举值转换为显示文本
  String get displayName => label;
}

/// 商品类别枚举
enum ProductCategory {
  all('全部'),
  electronics('电子产品'),
  office('办公用品'),
  daily('生活用品'),
  food('食品'),
  clothing('服装');

  final String label;
  const ProductCategory(this.label);

  /// 从字符串转换为枚举值
  static ProductCategory fromString(String category) {
    return switch (category) {
      '电子产品' => ProductCategory.electronics,
      '办公用品' => ProductCategory.office,
      '生活用品' => ProductCategory.daily,
      '食品' => ProductCategory.food,
      '服装' => ProductCategory.clothing,
      _ => ProductCategory.all,
    };
  }

  /// 将枚举值转换为显示文本
  String get displayName => label;
}

/// 商品模型类
class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final double price;
  final int stock;
  final InventoryStatus status;
  final String lastUpdate;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
    required this.lastUpdate,
  });

  /// 从Map构造Product对象
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ProductCategory.fromString(map['category'] as String),
      price: map['price'] as double,
      stock: map['stock'] as int,
      status: InventoryStatus.fromString(map['status'] as String),
      lastUpdate: map['lastUpdate'] as String,
    );
  }

  /// 将Product对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.displayName,
      'price': price,
      'stock': stock,
      'status': status.displayName,
      'lastUpdate': lastUpdate,
    };
  }

  /// 创建Product对象的副本，可以选择性地覆盖某些属性
  Product copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    double? price,
    int? stock,
    InventoryStatus? status,
    String? lastUpdate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  /// 根据库存量更新状态
  Product updateStatusBasedOnStock() {
    InventoryStatus newStatus;
    if (stock <= 0) {
      newStatus = InventoryStatus.outOfStock;
    } else if (stock <= 5) {
      newStatus = InventoryStatus.low;
    } else {
      newStatus = InventoryStatus.normal;
    }
    
    return copyWith(status: newStatus);
  }
}
