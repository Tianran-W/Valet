import 'package:valet/service/logger_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/workspace/models/image_model.dart';

import 'api_client.dart';

/// 工作空间 API 类，处理工作空间相关的 API 请求
class WorkspaceApi {
  final ApiClient _apiClient;

  /// 构造函数
  WorkspaceApi(this._apiClient);
  
  // =================== 物资相关 API ===================
  
  /// 获取所有物品类别
  Future<List<Category>> getCategories() async {
    final List<dynamic> response = await _apiClient.get('/admin/materialsCategories');
    return response.map((json) => Category.fromJson(json)).toList();
  }
  
  /// 添加新物品类别
  /// [name]: 类别名称
  Future<bool> addCategory({
    required String name,
  }) async {
    final Map<String, dynamic> body = {
      'categoryName': name,
    };
    
    await _apiClient.post('/admin/materialsNewCategories', body: body);
    return true;
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
      'materialId': materialId,
      'userId': userId,
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

  /// 获取库存预警
  Future<List<MaterialAlert>> getInventoryWarnings() async {
    final List<dynamic> response = await _apiClient.get('/admin/materialAlerts');
    return response.map((json) => MaterialAlert.fromJson(json)).toList();
  }
  
  /// 获取物资归还提醒
  Future<List<ReturnReminder>> getReturnReminders() async {
    final List<dynamic> response = await _apiClient.get('/returnReminders');
    return response.map((json) => ReturnReminder.fromJson(json)).toList();
  }

  /// 获取推荐物资列表
  /// [projectType]: 项目类型
  /// [participantCount]: 参与人数
  Future<List<RecommendedMaterial>> getRecommendedMaterials({
    required String projectType,
    required int participantCount,
  }) async {
    final Map<String, dynamic> body = {
      'projectType': projectType,
      'participantCount': participantCount,
    };
    
    final List<dynamic> response = await _apiClient.post('/recommendMaterials', body: body);
    return response.map((json) => RecommendedMaterial.fromJson(json)).toList();
  }

  /// 物资报废
    /// 物资报废
  /// [materialId]: 物资ID
  /// [reason]: 报废原因
  Future<bool> scrapMaterial({
    required int materialId,
    required String reason,
  }) async {
    final Map<String, dynamic> body = {
      'materialId': materialId,
      'reason': reason,
    };
    
    await _apiClient.post('/material/scrap', body: body);
    return true;
  }
  
  // =================== 图片管理相关 API ===================

  /// 上传图片
  /// [filePath]: 图片文件路径
  /// [recordType]: 记录类型
  /// [recordId]: 记录ID
  Future<ImageUploadResponse> uploadImage({
    required String filePath,
    required RecordType recordType,
    required int recordId,
  }) async {
    try {
      logger.info('上传图片: $filePath, recordType: ${recordType.value}, recordId: $recordId');
      
      final response = await _apiClient.uploadFile(
        '/uploadImage',
        filePath: filePath,
        fieldName: 'file',
        additionalFields: {
          'recordType': recordType.value,
          'recordId': recordId.toString(),
        },
      );
      
      return ImageUploadResponse.fromJson(response);
    } catch (e) {
      logger.error('上传图片失败: $e');
      throw Exception('上传图片失败: $e');
    }
  }

  /// 获取记录关联的图片列表
  /// [recordType]: 记录类型
  /// [recordId]: 记录ID
  Future<List<RecordImage>> getRecordImages({
    required RecordType recordType,
    required int materialId,
  }) async {
    try {
      logger.info('获取记录图片: recordType: ${recordType.value}, materialId: $materialId');

      final List<dynamic> response = await _apiClient.get('/images/material/$materialId/${recordType.value}');
      return response.map((json) => RecordImage.fromJson(json)).toList();
    } catch (e) {
      logger.error('获取记录图片失败: $e');
      throw Exception('获取记录图片失败: $e');
    }
  }

  /// 删除图片
  /// [imageId]: 图片ID
  Future<bool> deleteImage(int imageId) async {
    try {
      logger.info('删除图片: $imageId');
      
      await _apiClient.delete('/images/$imageId');
      return true;
    } catch (e) {
      logger.error('删除图片失败: $e');
      throw Exception('删除图片失败: $e');
    }
  }

  /// 获取图片URL
  /// [imageId]: 图片ID
  String getImageUrl(int imageId) {
    return '${_apiClient.baseUrl}/images/$imageId';
  }

  // =================== 审批相关 API ===================

  /// 获取待审批列表
  /// [userId]: 当前用户ID
  Future<List<Approval>> getPendingApprovals(int userId) async {
    final List<dynamic> response = await _apiClient.get('/admin/getApprovalRecord');
    return response.map((json) => Approval.fromMap(json)).toList();
  }

  /// 审批处理（通过或驳回）
  /// [approvalId]: 审批ID
  /// [isApprove]: 是否通过
  /// [remark]: 审批备注
  /// [userId]: 审批人ID
  /// [materialId]: 物资ID
  /// [approvalReason]: 审批原因
  Future<bool> processApproval({
    required int approvalId,
    required bool isApprove,
    required int userId,
    required int materialId,
    required String approvalReason,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'approvalId': approvalId, 
        'userId': userId,
        'materialId': materialId,
        'approvalResult': isApprove,
        'approvalReason': approvalReason,
      };
      await _apiClient.post('/admin/ApprovalResult', body: body);
      return true;
    } catch (e) {
      logger.error('处理审批失败: $e');
      throw Exception('处理审批失败: $e');
    }
  }
}
