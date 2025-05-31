import 'package:valet/api/core/api_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/api/core/logger_service.dart';

/// 库存服务类，处理与库存相关的业务逻辑
class InventoryService {
  final ApiService _apiService;
  static const String _tag = 'InventoryService';

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
      logger.info('正在获取物品列表, 过滤条件: category=$category, status=$status', tag: _tag);
      
      final result = await _apiService.workspaceApi.getItemList(
        category: category,
        status: status,
      );
      
      logger.debug('成功获取物品列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      // 处理异常
      logger.error('获取物品列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取物品列表失败: $e');
    }
  }
}
