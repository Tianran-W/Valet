import 'package:valet/api/core/api_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 库存服务类，处理与库存相关的业务逻辑
class InventoryService {
  final ApiService _apiService;

  /// 构造函数
  InventoryService(this._apiService);

  /// 获取物品列表
  /// [category]: 物品分类过滤条件
  /// [status]: 物品状态过滤条件
  Future<List<Item>> getInventoryItems({
    String? category,
    String? status,
  }) async {
    try {
      // 调用API获取物品列表
      return await _apiService.workspaceApi.getItemList(
        category: category,
        status: status,
      );
    } catch (e) {
      // 处理异常
      print('获取物品列表失败: $e');
      throw Exception('获取物品列表失败: $e');
    }
  }
}
