import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/workspace/application/inventory_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/presentation/widgets/dashboard/return_reminder.dart';
import 'package:valet/workspace/presentation/widgets/dashboard/inventory_alert.dart';
import 'package:valet/workspace/presentation/widgets/dashboard/recommended_materials.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late InventoryService _inventoryService;
  late AuthService _authService;
  
  // 数据状态
  List<MaterialAlert> _inventoryWarnings = [];
  List<ReturnReminder> _returnReminders = [];
  List<RecommendedMaterial> _recommendedMaterials = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";
  
  // 推荐物资配置
  String? _projectType;
  int? _participantCount;

  @override
  void initState() {
    super.initState();
    _inventoryService = getIt<InventoryService>();
    _authService = getIt<AuthService>();
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
      if (_authService.currentUser?.isAdmin == true) {
        // 管理员加载库存预警和所有归还提醒
        final results = await Future.wait([
          _inventoryService.getInventoryWarnings(),
          _inventoryService.getReturnReminders(),
        ]);

        setState(() {
          _inventoryWarnings = results[0] as List<MaterialAlert>;
          _returnReminders = results[1] as List<ReturnReminder>;
          _isLoading = false;
        });
      } else {
        // 普通用户只加载归还提醒（只显示自己的）
        final returnReminders = await _inventoryService.getReturnReminders();
        
        setState(() {
          _inventoryWarnings = []; // 普通用户不需要看到库存预警
          _returnReminders = returnReminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// 获取推荐物资
  Future<void> _loadRecommendedMaterials() async {
    if (_projectType == null || _participantCount == null) return;
    
    try {
      final materials = await _inventoryService.getRecommendedMaterials(
        projectType: _projectType!,
        participantCount: _participantCount!,
      );
      
      setState(() {
        _recommendedMaterials = materials;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取推荐物资失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 显示推荐配置对话框
  void _showRecommendationConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => RecommendationConfigDialog(
        initialProjectType: _projectType,
        initialParticipantCount: _participantCount,
        onSubmit: (projectType, participantCount) {
          setState(() {
            _projectType = projectType;
            _participantCount = participantCount;
          });
          _loadRecommendedMaterials();
        },
      ),
    );
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
                      '欢迎回来，${_authService.currentUser?.username ?? "用户"}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _authService.currentUser?.isAdmin == true 
                                ? Colors.red.shade100 
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _authService.currentUser?.isAdmin == true 
                                  ? Colors.red.shade300 
                                  : Colors.blue.shade300,
                            ),
                          ),
                          child: Text(
                            _authService.currentUser?.role.displayName ?? '用户',
                            style: TextStyle(
                              color: _authService.currentUser?.isAdmin == true 
                                  ? Colors.red.shade700 
                                  : Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
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
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                tooltip: '获取推荐物资',
                onPressed: _showRecommendationConfigDialog,
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

          // 数据显示区域
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载数据...'),
                ],
              ),
            )
          else ...[
            // 推荐物资卡片（所有用户都可以看到）
            RecommendedMaterialsCard(
              materials: _recommendedMaterials,
              onRefresh: _projectType != null && _participantCount != null 
                  ? _loadRecommendedMaterials 
                  : null,
            ),
            const SizedBox(height: 16),
            
            if (_authService.currentUser?.isAdmin == true) ...[
              // 管理员可以看到库存预警和所有归还提醒
              InventoryAlertCard(alerts: _inventoryWarnings),
              const SizedBox(height: 16),
              ReturnReminderCard(reminders: _returnReminders),
            ] else ...[
              ReturnReminderCard(reminders: _returnReminders),
            ],
          ],
        ],
      ),
    );
  }
}
