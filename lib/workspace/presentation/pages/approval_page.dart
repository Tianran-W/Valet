import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valet/api/core/api_service.dart';
import 'package:valet/workspace/application/approval_service.dart';
import 'package:valet/workspace/models/approval_model.dart';
import 'package:valet/workspace/presentation/widgets/approval/approval_widgets.dart';

/// 请求审批页面
class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> with SingleTickerProviderStateMixin {
  // 标签控制器
  late TabController _tabController;
  final List<String> _tabs = ['待我审批', '我发起的'];
  
  // 服务实例
  late ApprovalService _approvalService;
  
  // 审批数据
  List<Approval> _approvals = [];
  List<Approval> _myApplications = [];
  
  // 状态管理
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";
  
  // 用户ID（实际应用中应该从用户认证服务获取）
  final int _currentUserId = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // 初始化服务
    _initializeService();
    
    // 加载真实数据
    _loadApprovalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // 初始化服务
  void _initializeService() {
    try {
      // 从环境变量读取后端URL
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      
      // 创建API服务实例
      final apiService = ApiService.create(baseUrl: backendUrl);
      _approvalService = ApprovalService(apiService);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "初始化服务失败: $e";
      });
    }
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
      
      // 使用示例数据作为我发起的申请
      final sampleApplications = _generateSampleApplications();
      
      setState(() {
        _approvals = pendingApprovals;
        _myApplications = sampleApplications;
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

  // 生成示例申请数据
  List<Approval> _generateSampleApplications() {
    return [
      Approval(
        id: '1001',
        materialId: 'M001',
        materialName: '办公椅',
        applicantId: '1',
        applicantName: '张三',
        reason: '由于项目紧急，需要申请今晚加班到22:00完成开发任务',
        status: ApprovalStatus.pending,
        currentApprover: '李四',
      ),
      Approval(
        id: '1002',
        materialId: 'M002', 
        materialName: '年假',
        applicantId: '1',
        applicantName: '张三',
        reason: '申请12月20日-12月25日年假，共5天',
        status: ApprovalStatus.approved,
        approveTime: DateTime.now().subtract(const Duration(hours: 12)).toString(),
        currentApprover: '王五',
      ),
      Approval(
        id: '1003',
        materialId: 'M003',
        materialName: '办公用品',
        applicantId: '1', 
        applicantName: '张三',
        reason: '申请采购开发团队办公椅10张，预算8000元',
        status: ApprovalStatus.rejected,
        rejectReason: '预算超支，请重新评估需求',
        currentApprover: '赵六',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: '搜索审批',
                      onPressed: _isLoading ? null : _showSearchDialog,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _showCreateApprovalDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('发起审批'),
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
            
            // 标签页切换
            TabBar(
              controller: _tabController,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            
            const SizedBox(height: 16),
            
            // 标签页内容
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
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPendingApprovals(),
                      _buildMyApplications(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 统计卡片
  Widget _buildStatCards() {
    return Row(
      children: [
        ApprovalStatCard(
          title: '待审批',
          value: _approvals.length.toString(),
          icon: Icons.pending_actions,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        ApprovalStatCard(
          title: '我发起的',
          value: _myApplications.length.toString(),
          icon: Icons.send,
          color: Colors.purple,
        ),
      ],
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

  // 我发起的申请列表
  Widget _buildMyApplications() {
    return _myApplications.isEmpty
        ? const Center(child: Text('暂无发起的申请'))
        : Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _myApplications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _myApplications[index];
                return MyApplicationTile(
                  application: approval,
                  onTap: _showMyApplicationDetailDialog,
                  onWithdraw: _showWithdrawDialog,
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
              remark: remark,
            );
            
            // 重新加载数据
            await _loadApprovalData();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已${isApprove ? '通过' : '驳回'}审批'),
                  backgroundColor: isApprove ? Colors.green : Colors.red,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
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

  // 显示我的申请详情对话框
  void _showMyApplicationDetailDialog(Approval application) {
    showDialog(
      context: context,
      builder: (context) => ApprovalDetailDialog(
        approval: application,
        title: '申请详情',
      ),
    );
  }

  // 显示发起审批对话框
  void _showCreateApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateApprovalDialog(
        onSubmit: (approval) async {
          // 处理提交逻辑
          try {
            await _approvalService.submitApproval(approval);
            
            // 重新加载数据
            await _loadApprovalData();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('审批申请已提交'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('提交申请失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // 显示撤回申请对话框
  void _showWithdrawDialog(Approval approval) {
    showDialog(
      context: context,
      builder: (context) => WithdrawApprovalDialog(
        approval: approval,
        onWithdraw: (approval) async {
          // 处理撤回逻辑
          try {
            await _approvalService.withdrawApproval(
              approvalId: approval.id,
              userId: _currentUserId,
            );
            
            // 重新加载数据
            await _loadApprovalData();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('申请已撤回'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('撤回申请失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // 显示搜索对话框
  void _showSearchDialog() async {
    try {
      // 获取所有审批数据用于搜索
      final allApprovals = await _approvalService.getAllApprovals(_currentUserId);
      
      if (allApprovals.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('暂无审批数据可搜索')),
          );
        }
        return;
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ApprovalSearchDialog(
            approvals: allApprovals,
            onSelect: (approval) {
              // 根据审批类型决定显示哪种详情对话框
              if (_myApplications.any((item) => item.id == approval.id)) {
                _showMyApplicationDetailDialog(approval);
              } else {
                _showApprovalDetailDialog(approval);
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取搜索数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
