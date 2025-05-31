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
        category: '机械',
        quantity: 2,
        status: InventoryStatus.inStock,
        isValuable: true, // 贵重物品
        serialNumber: 'SN20240315-3DP001', // 添加SN码
      ),
      Item(
        id: 'MECH-002',
        name: 'CNC机床',
        category: '机械',
        quantity: 1,
        status: InventoryStatus.maintenance,
        isValuable: true, // 贵重物品
        serialNumber: 'SN20230517-CNC002', // 添加SN码
      ),
      Item(
        id: 'MECH-003',
        name: '车床',
        category: '机械',
        quantity: 1,
        status: InventoryStatus.onLoan,
        borrowedBy: '张三',
        isValuable: true, // 贵重物品
        serialNumber: 'SN20230128-LTH003', // 添加SN码
      ),
      
      // 电控类物品示例
      Item(
        id: 'ELEC-001',
        name: 'Arduino开发板',
        category: '电控',
        quantity: 10,
        status: InventoryStatus.inStock,
      ),
      Item(
        id: 'ELEC-002',
        name: 'STM32开发板',
        category: '电控',
        quantity: 5,
        status: InventoryStatus.inStock,
      ),
      Item(
        id: 'ELEC-003',
        name: 'FPGA开发板',
        category: '电控',
        quantity: 2,
        status: InventoryStatus.onLoan,
        borrowedBy: '李四',
      ),
      
      // 视觉类物品示例
      Item(
        id: 'VIS-001',
        name: '高速摄像机',
        category: '视觉',
        quantity: 1,
        status: InventoryStatus.inStock,
        isValuable: true, // 贵重物品
        serialNumber: 'SN20240420-HSC001', // 添加SN码
      ),
      Item(
        id: 'VIS-002',
        name: '深度相机',
        category: '视觉',
        quantity: 2,
        status: InventoryStatus.maintenance,
        isValuable: true, // 贵重物品
        serialNumber: 'SN20230822-DPC002', // 添加SN码
      ),
      Item(
        id: 'VIS-003',
        name: '工业相机',
        category: '视觉',
        quantity: 1,
        status: InventoryStatus.scrapped,
      ),
      
      // 硬件类物品示例
      Item(
        id: 'HW-001',
        name: '示波器',
        category: '硬件',
        quantity: 3,
        status: InventoryStatus.inStock,
      ),
      Item(
        id: 'HW-002',
        name: '万用表',
        category: '硬件',
        quantity: 8,
        status: InventoryStatus.inStock,
      ),
      Item(
        id: 'HW-003',
        name: '电烙铁',
        category: '硬件',
        quantity: 5,
        status: InventoryStatus.onLoan,
        borrowedBy: '王五',
      ),
    ];
  }
}
