import 'package:valet/service/api/api_service.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/workspace/models/battery_model.dart';

/// 电池管理服务类
class BatteryService {
  final ApiService _apiService;
  static const String _tag = 'BatteryService';

  /// 构造函数
  BatteryService(this._apiService);

  /// 获取所有电池列表
  Future<List<Battery>> getAllBatteries() async {
    try {
      logger.info('获取所有电池列表', tag: _tag);
      final batteries = await _apiService.batteryApi.getAllBatteries();
      logger.info('成功获取${batteries.length}个电池', tag: _tag);
      return batteries;
    } catch (e) {
      logger.error('获取电池列表失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 获取电池详情
  /// [materialId]: 电池物资ID
  Future<Battery> getBatteryDetail(int materialId) async {
    try {
      logger.info('获取电池详情: materialId=$materialId', tag: _tag);
      final battery = await _apiService.batteryApi.getBatteryDetail(materialId);
      logger.info('成功获取电池详情: ${battery.modelName}', tag: _tag);
      return battery;
    } catch (e) {
      logger.error('获取电池详情失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 获取电池状态历史
  /// [materialId]: 电池物资ID
  Future<List<BatteryStatusHistory>> getBatteryHistory(int materialId) async {
    try {
      logger.info('获取电池状态历史: materialId=$materialId', tag: _tag);
      final history = await _apiService.batteryApi.getBatteryHistory(materialId);
      logger.info('成功获取${history.length}条状态历史', tag: _tag);
      return history;
    } catch (e) {
      logger.error('获取电池状态历史失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 提交电池状态
  /// [materialId]: 电池物资ID
  /// [batteryLevel]: 电池电量百分比
  /// [batteryHealth]: 电池健康状态
  Future<bool> submitBatteryStatus({
    required int materialId,
    required int batteryLevel,
    required String batteryHealth,
  }) async {
    try {
      logger.info('提交电池状态: materialId=$materialId, level=$batteryLevel%, health=$batteryHealth', tag: _tag);
      
      final statusData = BatteryStatusSubmit(
        materialId: materialId,
        batteryLevel: batteryLevel,
        batteryHealth: batteryHealth,
      );
      
      final success = await _apiService.batteryApi.submitBatteryStatus(statusData);
      
      if (success) {
        logger.info('电池状态提交成功', tag: _tag);
      } else {
        logger.error('电池状态提交失败', tag: _tag);
      }
      
      return success;
    } catch (e) {
      logger.error('提交电池状态失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 新增电池
  /// [modelName]: 电池型号
  /// [snCode]: SN码
  /// [lifespanCycles]: 设计寿命（充电周期）
  /// [isExpensive]: 是否贵重（0或1）
  Future<Battery> addBattery({
    required String modelName,
    required String snCode,
    required int lifespanCycles,
    bool isExpensive = false,
  }) async {
    try {
      logger.info('新增电池: modelName=$modelName, snCode=$snCode, lifespanCycles=$lifespanCycles', tag: _tag);
      
      final batteryData = AddBatteryRequest(
        modelName: modelName,
        snCode: snCode,
        lifespanCycles: lifespanCycles,
        isExpensive: isExpensive ? 1 : 0,
      );
      
      final battery = await _apiService.batteryApi.addBattery(batteryData);
      logger.info('电池新增成功: ${battery.modelName}', tag: _tag);
      return battery;
    } catch (e) {
      logger.error('新增电池失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 更新电池信息
  /// [materialId]: 电池物资ID
  /// [modelName]: 电池型号（可选）
  /// [lifespanCycles]: 设计寿命（可选）
  Future<Battery> updateBattery({
    required int materialId,
    String? modelName,
    int? lifespanCycles,
  }) async {
    try {
      logger.info('更新电池信息: materialId=$materialId', tag: _tag);
      
      final updateData = UpdateBatteryRequest(
        modelName: modelName,
        lifespanCycles: lifespanCycles,
      );
      
      final battery = await _apiService.batteryApi.updateBattery(materialId, updateData);
      logger.info('电池信息更新成功: ${battery.modelName}', tag: _tag);
      return battery;
    } catch (e) {
      logger.error('更新电池信息失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 删除（报废）电池
  /// [materialId]: 电池物资ID
  Future<bool> deleteBattery(int materialId) async {
    try {
      logger.info('删除（报废）电池: materialId=$materialId', tag: _tag);
      
      final success = await _apiService.batteryApi.deleteBattery(materialId);
      
      if (success) {
        logger.info('电池删除成功', tag: _tag);
      } else {
        logger.error('电池删除失败', tag: _tag);
      }
      
      return success;
    } catch (e) {
      logger.error('删除电池失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 根据健康度过滤电池
  /// [batteries]: 电池列表
  /// [healthFilter]: 健康度过滤条件（null表示不过滤）
  List<Battery> filterBatteriesByHealth(List<Battery> batteries, BatteryStatusColor? healthFilter) {
    if (healthFilter == null) return batteries;
    return batteries.where((battery) => battery.statusColor == healthFilter).toList();
  }

  /// 根据状态过滤电池
  /// [batteries]: 电池列表
  /// [statusFilter]: 状态过滤条件（null表示不过滤）
  List<Battery> filterBatteriesByStatus(List<Battery> batteries, String? statusFilter) {
    if (statusFilter == null || statusFilter.isEmpty) return batteries;
    return batteries.where((battery) => battery.status == statusFilter).toList();
  }

  /// 搜索电池
  /// [batteries]: 电池列表
  /// [query]: 搜索关键词
  List<Battery> searchBatteries(List<Battery> batteries, String query) {
    if (query.isEmpty) return batteries;
    
    final lowercaseQuery = query.toLowerCase();
    return batteries.where((battery) {
      return battery.modelName.toLowerCase().contains(lowercaseQuery) ||
             battery.snCode.toLowerCase().contains(lowercaseQuery) ||
             battery.status.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// 排序电池列表
  /// [batteries]: 电池列表
  /// [sortBy]: 排序字段
  /// [ascending]: 是否升序
  List<Battery> sortBatteries(
    List<Battery> batteries, 
    BatterySortField sortBy, 
    bool ascending
  ) {
    final sorted = List<Battery>.from(batteries);
    
    switch (sortBy) {
      case BatterySortField.modelName:
        sorted.sort((a, b) => ascending 
          ? a.modelName.compareTo(b.modelName)
          : b.modelName.compareTo(a.modelName));
        break;
      case BatterySortField.health:
        sorted.sort((a, b) => ascending 
          ? a.healthPercentage.compareTo(b.healthPercentage)
          : b.healthPercentage.compareTo(a.healthPercentage));
        break;
      case BatterySortField.cycles:
        sorted.sort((a, b) => ascending 
          ? a.currentCycles.compareTo(b.currentCycles)
          : b.currentCycles.compareTo(a.currentCycles));
        break;
      case BatterySortField.status:
        sorted.sort((a, b) => ascending 
          ? a.status.compareTo(b.status)
          : b.status.compareTo(a.status));
        break;
    }
    
    return sorted;
  }

  /// 获取电池统计信息
  /// [batteries]: 电池列表
  static Map<String, dynamic> getBatteryStatistics(List<Battery> batteries) {
    if (batteries.isEmpty) {
      return {
        'total': 0,
        'inStock': 0,
        'borrowed': 0,
        'scrapped': 0,
        'needsReplacement': 0,
        'avgHealth': 0.0,
      };
    }

    final total = batteries.length;
    final inStock = batteries.where((b) => b.status == '在库可借').length;
    final borrowed = batteries.where((b) => b.status == '已借出').length;
    final scrapped = batteries.where((b) => b.status == '已报废').length;
    final needsReplacement = batteries.where((b) => b.needsReplacement).length;
    final avgHealth = batteries.map((b) => b.healthPercentage).reduce((a, b) => a + b) / total;

    return {
      'total': total,
      'inStock': inStock,
      'borrowed': borrowed,
      'scrapped': scrapped,
      'needsReplacement': needsReplacement,
      'avgHealth': avgHealth,
    };
  }
}

/// 电池排序字段枚举
enum BatterySortField {
  modelName('型号'),
  health('健康度'),
  cycles('使用周期'),
  status('状态');

  const BatterySortField(this.displayName);
  final String displayName;
}
