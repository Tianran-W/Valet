import 'api_client.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 工作空间 API 类，处理工作空间相关的 API 请求
class WorkspaceApi {
  final ApiClient _apiClient;

  /// 构造函数
  WorkspaceApi(this._apiClient);
  
  /// 获取所有物品类别
  Future<List<Category>> getCategories() async {
    final List<dynamic> response = await _apiClient.get('/admin/materialsCategories');
    return response.map((json) => Category.fromJson(json)).toList();
  }

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

  /// 添加新物品
  /// [name]: 物品名称
  /// [category]: 物品分类
  /// [quantity]: 物品数量
  /// [isValuable]: 是否贵重
  /// [serialNumber]: SN码（可选）
  /// [usageLimit]: 使用期限（可选）
  Future<bool> addItem({
    required String name,
    required int category,
    required int quantity,
    required bool isValuable,
    String? serialNumber,
    int? usageLimit,
  }) async {
    final Map<String, dynamic> body = {
      'materialName': name,
      'categoryId': category,
      'quantity': quantity,
      'isExpensive': isValuable ? 1 : 0,
      'status': '在库可借',
      if (serialNumber != null) 'snCode': serialNumber,
      if (usageLimit != null) 'usageLimit': usageLimit,
    };
    
    await _apiClient.post('/admin/addNewMaterials', body: body);
    return true;
  }

  /// 借用物品
  /// [materialId]: 物品ID
  /// [userId]: 用户ID
  /// [isValuable]: 是否贵重
  /// [usageProject]: 使用项目
  /// [approvalReason]: 借用原因
  Future<bool> borrowItem({
    required int materialId,
    required int userId,
    required bool isValuable,
    required String usageProject,
    required String approvalReason,
  }) async {
    final Map<String, dynamic> body = {
      'materialId': materialId,
      'userId': userId,
      'isExpensive': isValuable ? 1 : 0,
      'usageProject': usageProject,
      'approvalReason': approvalReason,
    };
    
    await _apiClient.post('/addNewBorrow', body: body);
    return true;
  }
  
  /// 获取指定用户的借用记录
  /// [userId]: 用户ID
  Future<List<int>> getBorrowingsByUserId(int userId) async {
    final Map<String, dynamic> body = {
      'userId': userId,
    };
    
    final List<dynamic> response = await _apiClient.post('/findBorrowingByUserId', body: body);
    
    // 返回该用户借用的物品ID列表
    return response.map<int>((item) => item['materialId'] as int).toList();
  }
}
