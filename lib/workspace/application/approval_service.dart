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
      logger.info('正在处理审批: $approvalId, 结果: ${isApprove ? '通过' : '驳回'}', tag: _tag);
      logger.debug('审批处理参数: userId=$userId, materialId=$materialId, approvalReason=$approvalReason', tag: _tag);
      logger.debug('审批id: $approvalId', tag: _tag);
      
      final result = await _apiService.workspaceApi.processApproval(
        approvalId: approvalId,
        isApprove: isApprove,
        userId: userId,
        materialId: materialId,
        approvalReason: approvalReason,
      );
      
      logger.debug('成功处理审批: $approvalId', tag: _tag);
      return result;
    } catch (e) {
      logger.error('处理审批失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('处理审批失败: $e');
    }
  }
}
