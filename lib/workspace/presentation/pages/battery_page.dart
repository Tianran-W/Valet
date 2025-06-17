import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/workspace/application/battery_service.dart';
import 'package:valet/workspace/models/battery_model.dart';
import 'package:valet/workspace/presentation/widgets/battery/battery.dart';
import 'package:valet/workspace/presentation/pages/battery_detail_page.dart';

/// 电池管理页面
class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  late BatteryService _batteryService;
  late AuthService _authService;

  // 数据状态
  List<Battery> _batteries = [];
  List<Battery> _filteredBatteries = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  // 过滤和搜索状态
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String? _statusFilter;
  BatteryStatusColor? _healthFilter;
  BatterySortField _sortField = BatterySortField.modelName;
  bool _sortAscending = true;

  // 状态选项
  final List<String> _statusOptions = ['在库可借', '已借出', '已报废'];

  @override
  void initState() {
    super.initState();
    _batteryService = getIt<BatteryService>();
    _authService = getIt<AuthService>();
    _loadBatteries();
  }

  /// 加载电池数据
  Future<void> _loadBatteries() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });

    try {
      final batteries = await _batteryService.getAllBatteries();
      setState(() {
        _batteries = batteries;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取电池列表失败: $_errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              onPressed: _loadBatteries,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  /// 应用过滤条件
  void _applyFilters() {
    var filtered = List<Battery>.from(_batteries);

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      filtered = _batteryService.searchBatteries(filtered, _searchQuery);
    }

    // 状态过滤
    if (_statusFilter != null) {
      filtered = _batteryService.filterBatteriesByStatus(filtered, _statusFilter);
    }

    // 健康度过滤
    if (_healthFilter != null) {
      filtered = _batteryService.filterBatteriesByHealth(filtered, _healthFilter);
    }

    // 排序
    filtered = _batteryService.sortBatteries(filtered, _sortField, _sortAscending);

    setState(() {
      _filteredBatteries = filtered;
    });
  }

  /// 显示新增电池对话框
  Future<void> _showAddBatteryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBatteryDialog(),
    );

    if (result != null && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在添加电池...')),
        );

        await _batteryService.addBattery(
          modelName: result['modelName'],
          snCode: result['snCode'],
          lifespanCycles: result['lifespanCycles'],
          isExpensive: result['isExpensive'] ?? false,
        );

        if (mounted) {
          _loadBatteries();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('电池添加成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加电池失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 显示电池详情
  void _showBatteryDetail(Battery battery) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BatteryDetailPage(battery: battery),
      ),
    );
  }

  /// 显示提交状态对话框
  Future<void> _showSubmitStatusDialog(Battery battery) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SubmitBatteryStatusDialog(battery: battery),
    );

    if (result != null && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在提交电池状态...')),
        );

        await _batteryService.submitBatteryStatus(
          materialId: result['materialId'],
          batteryLevel: result['batteryLevel'],
          batteryHealth: result['batteryHealth'],
        );

        if (mounted) {
          _loadBatteries();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('电池状态提交成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('提交电池状态失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 显示编辑电池对话框
  Future<void> _showEditBatteryDialog(Battery battery) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditBatteryDialog(battery: battery),
    );

    if (result != null && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在更新电池信息...')),
        );

        await _batteryService.updateBattery(
          materialId: battery.materialId,
          modelName: result['modelName'],
          lifespanCycles: result['lifespanCycles'],
        );

        if (mounted) {
          _loadBatteries();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('电池信息更新成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新电池信息失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 删除电池
  Future<void> _deleteBattery(Battery battery) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除电池 "${battery.modelName} (${battery.snCode})" 吗？\n\n此操作将标记电池为已报废状态，无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在删除电池...')),
        );

        await _batteryService.deleteBattery(battery.materialId);

        if (mounted) {
          _loadBatteries();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('电池删除成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除电池失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  '电池管理',
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
                      onPressed: _isLoading ? null : _loadBatteries,
                    ),
                    if (_authService.currentUser?.isAdmin ?? false) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _showAddBatteryDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('添加电池'),
                      ),
                    ],
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
                      onPressed: _loadBatteries,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),

            // 统计卡片
            BatteryStats(batteries: _batteries),
            const SizedBox(height: 24),

            // 搜索和过滤区域
            BatteryFilters(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
              statusFilter: _statusFilter,
              statusOptions: _statusOptions,
              onStatusChanged: (value) {
                setState(() {
                  _statusFilter = value;
                });
                _applyFilters();
              },
              healthFilter: _healthFilter,
              onHealthChanged: (value) {
                setState(() {
                  _healthFilter = value;
                });
                _applyFilters();
              },
              sortField: _sortField,
              sortAscending: _sortAscending,
              onSortChanged: (field, ascending) {
                setState(() {
                  _sortField = field;
                  _sortAscending = ascending;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),

            // 列表标题
            Row(
              children: [
                Text(
                  '电池列表',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filteredBatteries.length}/${_batteries.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 电池列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('加载失败: $_errorMessage'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadBatteries,
                                icon: const Icon(Icons.refresh),
                                label: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : BatteryList(
                          batteries: _filteredBatteries,
                          onBatteryTap: _showBatteryDetail,
                          onSubmitStatus: _showSubmitStatusDialog,
                          onEditBattery: _showEditBatteryDialog,
                          onDeleteBattery: _deleteBattery,
                          currentUser: _authService.currentUser,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
