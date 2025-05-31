// 物品示例代码
import 'inventory_model.dart';

/// 创建一些示例物品
class ItemExamples {
  /// 获取所有示例物品
  static List<Item> getAllItems() {
    return [
      // 机械类物品示例
      Item(
        id: 'MECH-001',
        name: '3D打印机',
        category: ProductCategory.mechanical,
        price: 2500.0,
        quantity: 2,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'MECH-002',
        name: 'CNC机床',
        category: ProductCategory.mechanical,
        price: 12000.0,
        quantity: 1,
        status: InventoryStatus.maintenance,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'MECH-003',
        name: '车床',
        category: ProductCategory.mechanical,
        price: 5000.0,
        quantity: 1,
        status: InventoryStatus.onLoan,
        lastUpdate: DateTime.now().toIso8601String(),
        borrowedBy: '张三',
      ),
      
      // 电控类物品示例
      Item(
        id: 'ELEC-001',
        name: 'Arduino开发板',
        category: ProductCategory.electronics,
        price: 150.0,
        quantity: 10,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'ELEC-002',
        name: 'STM32开发板',
        category: ProductCategory.electronics,
        price: 250.0,
        quantity: 5,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'ELEC-003',
        name: 'FPGA开发板',
        category: ProductCategory.electronics,
        price: 1200.0,
        quantity: 2,
        status: InventoryStatus.onLoan,
        lastUpdate: DateTime.now().toIso8601String(),
        borrowedBy: '李四',
      ),
      
      // 视觉类物品示例
      Item(
        id: 'VIS-001',
        name: '高速摄像机',
        category: ProductCategory.vision,
        price: 8000.0,
        quantity: 1,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'VIS-002',
        name: '深度相机',
        category: ProductCategory.vision,
        price: 3500.0,
        quantity: 2,
        status: InventoryStatus.maintenance,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'VIS-003',
        name: '工业相机',
        category: ProductCategory.vision,
        price: 5000.0,
        quantity: 1,
        status: InventoryStatus.scrapped,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      
      // 硬件类物品示例
      Item(
        id: 'HW-001',
        name: '示波器',
        category: ProductCategory.hardware,
        price: 4000.0,
        quantity: 3,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'HW-002',
        name: '万用表',
        category: ProductCategory.hardware,
        price: 200.0,
        quantity: 8,
        status: InventoryStatus.inStock,
        lastUpdate: DateTime.now().toIso8601String(),
      ),
      Item(
        id: 'HW-003',
        name: '电烙铁',
        category: ProductCategory.hardware,
        price: 350.0,
        quantity: 5,
        status: InventoryStatus.onLoan,
        lastUpdate: DateTime.now().toIso8601String(),
        borrowedBy: '王五',
      ),
    ];
  }
}
