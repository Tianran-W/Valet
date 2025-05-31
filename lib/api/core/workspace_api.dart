import 'api_client.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 工作空间 API 类，处理工作空间相关的 API 请求
class WorkspaceApi {
  final ApiClient _apiClient;

  /// 构造函数
  WorkspaceApi(this._apiClient);

  /// 获取所有物品
  /// [category]: 物品分类
  /// [status]: 物品状态
  Future<List<Item>> getItemList({
    String? category,
    String? status,
  }) async {
    final List<dynamic> response = await _apiClient.get('/getAllMaterial');
    return response.map((json) => Item.fromJson(json)).toList();
  }
}
