import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/workspace/application/inventory_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/presentation/widgets/dashboard/return_reminder.dart';
import 'package:valet/workspace/presentation/widgets/dashboard/inventory_alert.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late InventoryService _inventoryService;
  
  // 数据状态
  List<MaterialAlert> _inventoryWarnings = [];
  List<ReturnReminder> _returnReminders = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _inventoryService = getIt<InventoryService>();
    _loadDashboardData();
  }

  /// 加载仪表盘数据
  Future<void> _loadDashboardData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });

    try {
      // 并行加载库存预警和归还提醒
      final results = await Future.wait([
        _inventoryService.getInventoryWarnings(),
        _inventoryService.getReturnReminders(),
      ]);

      setState(() {
        _inventoryWarnings = results[0] as List<MaterialAlert>;
        _returnReminders = results[1] as List<ReturnReminder>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来，管理员',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
                tooltip: '刷新数据',
                onPressed: _isLoading ? null : _loadDashboardData,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
                      '加载数据失败: $_errorMessage',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadDashboardData,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),

          // 库存预警和归还提醒
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载预警和提醒信息...'),
                ],
              ),
            )
          else ...[
            // 库存预警
            InventoryAlertCard(alerts: _inventoryWarnings),
            const SizedBox(height: 16),
            
            // 归还提醒
            ReturnReminderCard(reminders: _returnReminders),
          ],
        ],
      ),
    );
  }
}
