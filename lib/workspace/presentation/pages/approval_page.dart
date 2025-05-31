import 'package:flutter/material.dart';
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
  final List<String> _tabs = ['待我审批', '我已审批', '我发起的'];
  
  // 审批数据
  List<Approval> _approvals = [];
  List<Approval> _approvedItems = [];
  List<Approval> _myApplications = [];
  
  // 过滤数据
  List<Approval> _filteredApprovals = [];
  List<Approval> _filteredApprovedItems = [];
  List<Approval> _filteredMyApplications = [];
  List<ApprovalType> _selectedTypes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // 默认选择所有类型
    _selectedTypes = List.from(ApprovalType.values);
    
    // 加载示例数据
    _loadSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // 加载示例数据
  void _loadSampleData() {
    _approvals = ApprovalSampleData.getPendingApprovals();
    _approvedItems = ApprovalSampleData.getApprovedItems();
    _myApplications = ApprovalSampleData.getMyApplications();
    
    // 应用过滤器
    _applyFilters();
  }
  
  // 应用过滤器
  void _applyFilters() {
    setState(() {
      _filteredApprovals = _approvals.where(
        (approval) => _selectedTypes.contains(approval.type)
      ).toList();
      
      _filteredApprovedItems = _approvedItems.where(
        (approval) => _selectedTypes.contains(approval.type)
      ).toList();
      
      _filteredMyApplications = _myApplications.where(
        (approval) => _selectedTypes.contains(approval.type)
      ).toList();
    });
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
                      icon: const Icon(Icons.refresh),
                      tooltip: '刷新数据',
                      onPressed: () {
                        setState(() {
                          _loadSampleData();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据已刷新')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: '搜索审批',
                      onPressed: _showSearchDialog,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _showCreateApprovalDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('发起审批'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
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
            
            // 过滤器
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ApprovalFilterWidget(
                selectedTypes: _selectedTypes,
                onFilterChanged: (types) {
                  setState(() {
                    _selectedTypes = types;
                    _applyFilters();
                  });
                },
              ),
            ),
            
            // 标签页内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingApprovals(),
                  _buildApprovedItems(),
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
          value: '${_filteredApprovals.length}/${_approvals.length}',
          icon: Icons.pending_actions,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        ApprovalStatCard(
          title: '已审批',
          value: '${_filteredApprovedItems.length}/${_approvedItems.length}',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        ApprovalStatCard(
          title: '我发起的',
          value: '${_filteredMyApplications.length}/${_myApplications.length}',
          icon: Icons.send,
          color: Colors.purple,
        ),
      ],
    );
  }

  // 待我审批列表
  Widget _buildPendingApprovals() {
    return _filteredApprovals.isEmpty
        ? const Center(child: Text('暂无待审批项目'))
        : Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _filteredApprovals.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _filteredApprovals[index];
                return PendingApprovalTile(
                  approval: approval,
                  onApproveReject: _showApprovalDialog,
                  onTap: _showApprovalDetailDialog,
                );
              },
            ),
          );
  }

  // 已审批列表
  Widget _buildApprovedItems() {
    return _filteredApprovedItems.isEmpty
        ? const Center(child: Text('暂无已审批项目'))
        : Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _filteredApprovedItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _filteredApprovedItems[index];
                return ApprovedItemTile(
                  approval: approval,
                  onTap: _showApprovalDetailDialog,
                );
              },
            ),
          );
  }

  // 我发起的申请列表
  Widget _buildMyApplications() {
    return _filteredMyApplications.isEmpty
        ? const Center(child: Text('暂无发起的申请'))
        : Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _filteredMyApplications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _filteredMyApplications[index];
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
        onSubmit: (approval, isApprove, remark) {
          // 处理审批逻辑
          setState(() {
            _approvals.remove(approval);
            
            // 创建新的审批数据
            Approval newApproval = Approval(
              id: approval.id,
              title: approval.title,
              applicant: approval.applicant,
              department: approval.department,
              submitTime: approval.submitTime,
              approveTime: '2025-06-01 ${DateTime.now().hour}:${DateTime.now().minute}',
              status: isApprove ? ApprovalStatus.approved : ApprovalStatus.rejected,
              type: approval.type,
              urgent: approval.urgent,
              rejectReason: (!isApprove && remark != null) ? remark : null,
            );
            
            // 添加到已审批列表
            _approvedItems.insert(0, newApproval);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已${isApprove ? '通过' : '驳回'}审批'),
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
          );
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
        onSubmit: (approval) {
          // 处理提交逻辑
          setState(() {
            // 添加到我的申请列表
            _myApplications.insert(0, approval);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('审批申请已提交'),
              backgroundColor: Colors.blue,
            ),
          );
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
        onWithdraw: (approval) {
          // 处理撤回逻辑
          setState(() {
            _myApplications.remove(approval);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('申请已撤回'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  // 显示搜索对话框
  void _showSearchDialog() {
    // 合并所有类型的审批
    final List<Approval> allApprovals = [
      ..._approvals,
      ..._approvedItems,
      ..._myApplications,
    ];
    
    if (allApprovals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无审批数据可搜索')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => ApprovalSearchDialog(
        approvals: allApprovals,
        onSelect: (approval) {
          // 根据审批类型决定显示哪种详情对话框
          if (_myApplications.contains(approval)) {
            _showMyApplicationDetailDialog(approval);
          } else {
            _showApprovalDetailDialog(approval);
          }
        },
      ),
    );
  }

}
