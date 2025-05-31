import 'package:valet/api/core/api_service.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/api/core/logger_service.dart';

/// 审批服务类，处理与审批相关的业务逻辑
class ApprovalService {
  final ApiService _apiService;
  static const String _tag = 'ApprovalService';

  /// 构造函数
  ApprovalService(this._apiService);

  /// 获取待审批列表
  /// [userId]: 当前用户ID
  Future<List<Approval>> getPendingApprovals(int userId) async {
    try {
      logger.info('正在获取待审批列表, userId=$userId', tag: _tag);
      
      final result = await _apiService.workspaceApi.getPendingApprovals(userId);
      
      logger.debug('成功获取待审批列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取待审批列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取待审批列表失败: $e');
    }
  }

  /// 获取已审批列表  
  /// [userId]: 当前用户ID
  Future<List<Approval>> getApprovedItems(int userId) async {
    try {
      logger.info('正在获取已审批列表, userId=$userId', tag: _tag);
      
      final result = await _apiService.workspaceApi.getApprovedItems(userId);
      
      logger.debug('成功获取已审批列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取已审批列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取已审批列表失败: $e');
    }
  }

  /// 获取我发起的审批申请
  /// [userId]: 当前用户ID  
  Future<List<Approval>> getMyApplications(int userId) async {
    try {
      logger.info('正在获取我的申请列表, userId=$userId', tag: _tag);
      
      final result = await _apiService.workspaceApi.getMyApplications(userId);
      
      logger.debug('成功获取我的申请列表, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取我的申请列表失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取我的申请列表失败: $e');
    }
  }

  /// 提交新的审批申请
  /// [approval]: 审批申请对象
  Future<Approval> submitApproval(Approval approval) async {
    try {
      logger.info('正在提交审批申请: ${approval.materialName}', tag: _tag);
      logger.debug('审批申请详情: id=${approval.id}, 类型=物资借用申请', tag: _tag);
      
      final result = await _apiService.workspaceApi.submitApproval(approval);
      
      logger.debug('成功提交审批申请: ${approval.materialName}', tag: _tag);
      return result;
    } catch (e) {
      logger.error('提交审批申请失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('提交审批申请失败: $e');
    }
  }

  /// 审批处理（通过或驳回）
  /// [approvalId]: 审批ID
  /// [isApprove]: 是否通过
  /// [remark]: 审批备注
  /// [userId]: 审批人ID
  Future<Approval> processApproval({
    required String approvalId,
    required bool isApprove,
    required int userId,
    String? remark,
  }) async {
    try {
      logger.info('正在处理审批: $approvalId, 结果: ${isApprove ? '通过' : '驳回'}', tag: _tag);
      logger.debug('审批处理参数: userId=$userId, remark=$remark', tag: _tag);
      
      final result = await _apiService.workspaceApi.processApproval(
        approvalId: approvalId,
        isApprove: isApprove,
        userId: userId,
        remark: remark,
      );
      
      logger.debug('成功处理审批: $approvalId', tag: _tag);
      return result;
    } catch (e) {
      logger.error('处理审批失败', tag: _tag, error: e, stackTrace: StackTrace.current);
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
      logger.info('正在撤回审批申请: $approvalId', tag: _tag);
      logger.debug('撤回参数: userId=$userId', tag: _tag);
      
      final result = await _apiService.workspaceApi.withdrawApproval(
        approvalId: approvalId,
        userId: userId,
      );
      
      logger.debug('成功撤回审批申请: $approvalId', tag: _tag);
      return result;
    } catch (e) {
      logger.error('撤回审批申请失败', tag: _tag, error: e, stackTrace: StackTrace.current);
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
      logger.info('正在搜索审批申请: $query', tag: _tag);
      
      final result = await _apiService.workspaceApi.searchApprovals(
        query: query,
        userId: userId,
      );
      
      logger.debug('搜索审批申请完成, 共${result.length}条记录', tag: _tag);
      return result;
    } catch (e) {
      logger.error('搜索审批申请失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('搜索审批申请失败: $e');
    }
  }

  /// 获取所有审批数据（用于搜索）
  /// [userId]: 当前用户ID
  Future<List<Approval>> getAllApprovals(int userId) async {
    try {
      logger.info('正在获取所有审批数据用于搜索', tag: _tag);
      
      // 并行获取三个列表
      final futures = await Future.wait([
        getPendingApprovals(userId),
        getApprovedItems(userId),
        getMyApplications(userId),
      ]);
      
      final allApprovals = <Approval>[
        ...futures[0],
        ...futures[1], 
        ...futures[2],
      ];
      
      logger.debug('成功获取所有审批数据, 共${allApprovals.length}条记录', tag: _tag);
      return allApprovals;
    } catch (e) {
      logger.error('获取所有审批数据失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取所有审批数据失败: $e');
    }
  }
}
