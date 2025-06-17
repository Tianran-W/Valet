import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/workspace/application/battery_service.dart';
import 'package:valet/workspace/models/battery_model.dart';
import 'package:valet/workspace/presentation/widgets/battery/battery_components.dart';

/// 电池详情页面
class BatteryDetailPage extends StatefulWidget {
  final Battery battery;

  const BatteryDetailPage({
    super.key,
    required this.battery,
  });

  @override
  State<BatteryDetailPage> createState() => _BatteryDetailPageState();
}

class _BatteryDetailPageState extends State<BatteryDetailPage> {
  late BatteryService _batteryService;
  Battery? _battery;
  List<BatteryStatusHistory> _statusHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _batteryService = getIt<BatteryService>();
    _battery = widget.battery;
    _loadBatteryDetail();
    _loadStatusHistory();
  }

  /// 加载电池详情
  Future<void> _loadBatteryDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final battery = await _batteryService.getBatteryDetail(widget.battery.materialId);
      setState(() {
        _battery = battery;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载电池详情失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 加载状态历史
  Future<void> _loadStatusHistory() async {
    try {
      final history = await _batteryService.getBatteryHistory(widget.battery.materialId);
      setState(() {
        _statusHistory = history;
      });
    } catch (e) {
      // 状态历史加载失败不影响主界面显示
      debugPrint('加载状态历史失败: $e');
    }
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    await Future.wait([
      _loadBatteryDetail(),
      _loadStatusHistory(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_battery == null || _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('电池详情'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_battery!.modelName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 电池基本信息卡片
              _buildBasicInfoCard(),
              const SizedBox(height: 16),

              // 健康度卡片
              _buildHealthCard(),
              const SizedBox(height: 16),

              // 使用统计卡片
              _buildUsageStatsCard(),
              const SizedBox(height: 16),

              // 状态历史卡片
              _buildStatusHistoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '基本信息',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('物资ID', _battery!.materialId.toString()),
            _buildInfoRow('电池型号', _battery!.modelName),
            _buildInfoRow('SN码', _battery!.snCode),
            _buildInfoRow('当前状态', _battery!.status),
          ],
        ),
      ),
    );
  }

  /// 构建健康度卡片
  Widget _buildHealthCard() {
    final healthColor = _getHealthColor(_battery!.statusColor);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: healthColor),
                const SizedBox(width: 8),
                Text(
                  '健康状态',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 健康度进度环
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _battery!.healthPercentage / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_battery!.healthPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: healthColor,
                            ),
                          ),
                          Text(
                            _battery!.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_battery!.needsReplacement)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '此电池健康度过低，建议尽快更换',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建使用统计卡片
  Widget _buildUsageStatsCard() {
    final usagePercentage = _battery!.lifespanCycles > 0 
        ? (_battery!.currentCycles / _battery!.lifespanCycles * 100)
        : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '使用统计',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('设计寿命', '${_battery!.lifespanCycles} 充电周期'),
            _buildInfoRow('已使用', '${_battery!.currentCycles} 充电周期'),
            _buildInfoRow('剩余寿命', '${_battery!.lifespanCycles - _battery!.currentCycles} 充电周期'),
            
            const SizedBox(height: 12),
            Text(
              '使用进度',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: usagePercentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercentage > 80 ? Colors.red : 
                usagePercentage > 60 ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${usagePercentage.toStringAsFixed(1)}% 已使用',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态历史卡片
  Widget _buildStatusHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '状态历史',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${_statusHistory.length} 条记录',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_statusHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        '暂无状态历史记录',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _statusHistory.map((history) => _buildHistoryItem(history)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建历史记录项
  Widget _buildHistoryItem(BatteryStatusHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          BatteryHealthIndicator(
            healthPercentage: history.batteryLevel.toDouble(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '电量: ${history.batteryLevel}%',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '健康状态: ${history.batteryHealth}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            history.recordTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 获取健康度颜色
  Color _getHealthColor(BatteryStatusColor statusColor) {
    switch (statusColor) {
      case BatteryStatusColor.excellent:
        return Colors.green;
      case BatteryStatusColor.good:
        return Colors.lightGreen;
      case BatteryStatusColor.fair:
        return Colors.orange;
      case BatteryStatusColor.poor:
        return Colors.deepOrange;
      case BatteryStatusColor.critical:
        return Colors.red;
    }
  }
}
