import 'package:valet/service/api/api_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/service/logger_service.dart';

/// 库存服务类，处理与库存相关的业务逻辑
class InventoryService {
  final ApiService _apiService;
  static const String _tag = 'InventoryService';

  /// 构造函数
  InventoryService(this._apiService);

  /// 获取物品类别列表
  Future<List<Category>> getCategories() async {
    try {
      logger.info('正在获取物品类别列表', tag: _tag);
      final result = await _apiService.workspaceApi.getCategories();
      logger.debug('成功获取物品类别列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取物品类别列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取物品类别列表失败: $e');
    }
  }
  
  /// 添加新物品类别
  /// [name]: 类别名称
  Future<void> addCategory({
    required String name,
  }) async {
    try {
      logger.info('正在添加新物品类别: $name', tag: _tag);
      
      await _apiService.workspaceApi.addCategory(
        name: name,
      );
      
      logger.debug('成功添加新物品类别: $name', tag: _tag);
    } catch (e) {
      logger.error('添加物品类别失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('添加物品类别失败: $e');
    }
  }

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
  
  /// 添加新物品
  /// [name]: 物品名称
  /// [category]: 物品分类
  /// [quantity]: 物品数量
  /// [isValuable]: 是否贵重
  /// [serialNumber]: SN码（可选）
  /// [usageLimit]: 使用期限（可选）
  Future<void> addItem({
    required String name,
    required int category,
    required int quantity,
    required bool isValuable,
    String? serialNumber,
    int? usageLimit,
  }) async {
    try {
      logger.info('正在添加新物品: $name', tag: _tag);
      
      await _apiService.workspaceApi.addItem(
        name: name,
        category: category,
        quantity: quantity,
        isValuable: isValuable,
        serialNumber: serialNumber,
        usageLimit: usageLimit,
      );
      
      logger.debug('成功添加新物品: $name', tag: _tag);
    } catch (e) {
      logger.error('添加物品失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('添加物品失败: $e');
    }
  }
  
  /// 借用物品
  /// [materialId]: 物品ID
  /// [userId]: 用户ID
  /// [isValuable]: 是否贵重
  /// [usageProject]: 使用项目
  /// [approvalReason]: 借用原因
  Future<void> borrowItem({
    required int materialId,
    required int userId,
    required bool isValuable,
    required String usageProject,
    required String approvalReason,
  }) async {
    try {
      logger.info('正在借用物品: $materialId, 项目: $usageProject', tag: _tag);
      logger.debug('借用参数: userId=$userId, isValuable=$isValuable, approvalReason=$approvalReason', tag: _tag);
      await _apiService.workspaceApi.borrowItem(
        materialId: materialId,
        userId: userId,
        isValuable: isValuable,
        usageProject: usageProject,
        approvalReason: approvalReason,
      );
      
      logger.debug('成功借用物品: $materialId', tag: _tag);
    } catch (e) {
      logger.error('借用物品失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('借用物品失败: $e');
    }
  }
  
  /// 获取用户借用的物品ID列表
  /// [userId]: 用户ID
  Future<List<int>> getUserBorrowings(int userId) async {
    try {
      logger.info('正在获取用户借用记录: userId=$userId', tag: _tag);
      
      final result = await _apiService.workspaceApi.getBorrowingsByUserId(userId);
      
      logger.debug('成功获取用户借用记录, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取用户借用记录失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取用户借用记录失败: $e');
    }
  }

  /// 获取库存预警列表
  Future<List<MaterialAlert>> getInventoryWarnings() async {
    try {
      logger.info('正在获取库存预警列表', tag: _tag);
      
      final result = await _apiService.workspaceApi.getInventoryWarnings();
      
      logger.debug('成功获取库存预警列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取库存预警列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取库存预警列表失败: $e');
    }
  }

  /// 获取物资归还提醒列表
  Future<List<ReturnReminder>> getReturnReminders() async {
    try {
      logger.info('正在获取物资归还提醒列表', tag: _tag);
      
      final result = await _apiService.workspaceApi.getReturnReminders();
      
      logger.debug('成功获取物资归还提醒列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取物资归还提醒列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取物资归还提醒列表失败: $e');
    }
  }

  /// 归还物品
  /// [materialId]: 物品ID
  /// [userId]: 用户ID
  Future<void> returnItem({
    required int materialId,
    required int userId,
  }) async {
    try {
      logger.info('正在归还物品: $materialId', tag: _tag);
      logger.debug('归还参数: userId=$userId', tag: _tag);
      
      await _apiService.workspaceApi.returnItem(
        materialId: materialId,
        userId: userId,
      );
      
      logger.debug('成功归还物品: $materialId', tag: _tag);
    } catch (e) {
      logger.error('归还物品失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('归还物品失败: $e');
    }
  }

  /// 获取推荐物资列表
  /// [projectType]: 项目类型
  /// [participantCount]: 参与人数
  Future<List<RecommendedMaterial>> getRecommendedMaterials({
    required String projectType,
    required int participantCount,
  }) async {
    try {
      logger.info('正在获取推荐物资列表: projectType=$projectType, participantCount=$participantCount', tag: _tag);
      
      final result = await _apiService.workspaceApi.getRecommendedMaterials(
        projectType: projectType,
        participantCount: participantCount,
      );
      
      logger.debug('成功获取推荐物资列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取推荐物资列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取推荐物资列表失败: $e');
    }
  }
}
