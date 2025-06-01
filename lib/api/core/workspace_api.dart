import 'package:valet/api/core/logger_service.dart';

import 'api_client.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/approval_model.dart';

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
  
  /// 归还物品
  /// [materialId]: 物品ID
  /// [userId]: 用户ID
  Future<bool> returnItem({
    required int materialId,
    required int userId,
  }) async {
    logger.info('归还物品: materialId=$materialId, userId=$userId');
    final Map<String, dynamic> body = {
      'material_id': materialId,
      'user_id': userId,
    };
    
    await _apiClient.post('/return', body: body);
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

  // =================== 审批相关 API ===================

  /// 获取待审批列表
  /// [userId]: 当前用户ID
  Future<List<Approval>> getPendingApprovals(int userId) async {
    final List<dynamic> response = await _apiClient.get('/admin/getApprovalRecord');
    return response.map((json) => Approval.fromMap(json)).toList();
  }

  /// 获取已审批列表  
  /// [userId]: 当前用户ID
  Future<List<Approval>> getApprovedItems(int userId) async {
    final List<dynamic> response = await _apiClient.get('/approval/approved/$userId');
    return response.map((json) => Approval.fromMap(json)).toList();
  }

  /// 获取我发起的审批申请
  /// [userId]: 当前用户ID  
  Future<List<Approval>> getMyApplications(int userId) async {
    try {
      final List<dynamic> response = await _apiClient.get('/approval/my-applications/$userId');
      return response.map((json) => Approval.fromMap(json)).toList();
    } catch (e) {
      logger.error('获取我的申请列表失败: $e');
      throw Exception('获取我的申请列表失败: $e');
    }
  }

  /// 提交新的审批申请
  /// [approval]: 审批申请对象
  Future<Approval> submitApproval(Approval approval) async {
    try {
      final Map<String, dynamic> body = approval.toMap();
      final Map<String, dynamic> response = await _apiClient.post('/approval/submit', body: body);
      return Approval.fromMap(response);
    } catch (e) {
      logger.error('提交审批申请失败: $e');
      throw Exception('提交审批申请失败: $e');
    }
  }

  /// 审批处理（通过或驳回）
  /// [approvalId]: 审批ID
  /// [isApprove]: 是否通过
  /// [remark]: 审批备注
  /// [userId]: 审批人ID
  /// [materialId]: 物资ID
  /// [approvalReason]: 审批原因
  Future<bool> processApproval({
    required String approvalId,
    required bool isApprove,
    required int userId,
    required int materialId,
    required String approvalReason,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'approval_id': approvalId,
        'user_id': userId,
        'material_id': materialId,
        'approval_result': isApprove,
        'approval_reason': approvalReason,
      };
      await _apiClient.post('/admin/ApprovalResult', body: body);
      return true;
    } catch (e) {
      logger.error('处理审批失败: $e');
      throw Exception('处理审批失败: $e');
    }
  }

  /// 撤回审批申请
  /// [approvalId]: 审批ID
  /// [userId]: 申请人ID
  Future<bool> withdrawApproval({
    required String approvalId,
    required int userId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'approvalId': approvalId,
        'userId': userId,
      };
      await _apiClient.post('/approval/withdraw', body: body);
      return true;
    } catch (e) {
      logger.error('撤回审批申请失败: $e');
      throw Exception('撤回审批申请失败: $e');
    }
  }

  /// 搜索审批申请
  /// [query]: 搜索关键词
  /// [userId]: 当前用户ID
  Future<List<Approval>> searchApprovals({
    required String query,
    required int userId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'query': query,
        'userId': userId,
      };
      final List<dynamic> response = await _apiClient.post('/approval/search', body: body);
      return response.map((json) => Approval.fromMap(json)).toList();
    } catch (e) {
      logger.error('搜索审批申请失败: $e');
      throw Exception('搜索审批申请失败: $e');
    }
  }
}
