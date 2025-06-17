import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/workspace/application/approval_service.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/workspace/presentation/widgets/approval/approval.dart';

/// 请求审批页面
class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  // 服务实例
  late ApprovalService _approvalService;
  late AuthService _authService;
  
  // 审批数据
  List<Approval> _approvals = [];
  
  // 状态管理
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";
  
  // 用户ID（实际应用中应该从用户认证服务获取）
  final int _currentUserId = 1;

  @override
  void initState() {
    super.initState();
    
    // 初始化服务
    _approvalService = getIt<ApprovalService>();
    _authService = getIt<AuthService>();
    
    // 加载真实数据
    _loadApprovalData();
  }
  
  // 从API加载审批数据
  Future<void> _loadApprovalData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });
    
    try {
      // 加载待审批列表
      final pendingApprovals = await _approvalService.getPendingApprovals(_currentUserId);
      
      setState(() {
        _approvals = pendingApprovals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: _loadApprovalData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查用户权限，只有管理员才能看到审批页面
    if (!(_authService.currentUser?.isAdmin ?? false)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_accounts,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '权限不足',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '只有管理员才能访问审批功能',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '请求审批',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                      tooltip: '刷新数据',
                      onPressed: _isLoading ? null : () {
                        _loadApprovalData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('正在刷新数据...')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 错误信息显示
            if (_hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadApprovalData,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            
            // 统计卡片
            _buildStatCards(),
            
            const SizedBox(height: 24),
            
            // 审批列表
            Expanded(
              child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在加载审批数据...'),
                      ],
                    ),
                  )
                : _buildPendingApprovals(),
            ),
          ],
        ),
      ),
    );
  }

  // 统计卡片
  Widget _buildStatCards() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withAlpha(51),
                radius: 16,
                child: Icon(
                  Icons.pending_actions, 
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '待审批',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _approvals.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 待我审批列表
  Widget _buildPendingApprovals() {
    return _approvals.isEmpty
        ? const Center(child: Text('暂无待审批项目'))
        : Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _approvals.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _approvals[index];
                return PendingApprovalTile(
                  approval: approval,
                  onApproveReject: _showApprovalDialog,
                  onTap: _showApprovalDetailDialog,
                );
              },
            ),
          );
  }

  // 显示审批对话框
  void _showApprovalDialog(Approval approval, bool isApprove) {
    showDialog(
      context: context,
      builder: (context) => ApprovalActionDialog(
        approval: approval,
        isApprove: isApprove,
        onSubmit: (approval, isApprove, remark) async {
          // 处理审批逻辑
          try {
            await _approvalService.processApproval(
              approvalId: approval.id,
              isApprove: isApprove,
              userId: _currentUserId,
              materialId: int.parse(approval.materialId),
              approvalReason: approval.reason,
            );
            
            // 重新加载数据
            await _loadApprovalData();
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已${isApprove ? '通过' : '驳回'}审批'),
                  backgroundColor: isApprove ? Colors.green : Colors.red,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('审批处理失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // 显示审批详情对话框
  void _showApprovalDetailDialog(Approval approval) {
    showDialog(
      context: context,
      builder: (context) => ApprovalDetailDialog(
        approval: approval,
        title: '审批详情',
      ),
    );
  }
}
