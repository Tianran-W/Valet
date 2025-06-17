import 'package:valet/service/logger_service.dart';
import 'package:valet/service/api/api_client.dart';
import 'package:valet/workspace/models/battery_model.dart';

/// 电池管理 API 类，处理电池相关的 API 请求
class BatteryApi {
  final ApiClient _apiClient;

  /// 构造函数
  BatteryApi(this._apiClient);

  // =================== 电池管理相关 API ===================

  /// 提交电池状态
  /// [statusData]: 电池状态数据
  Future<bool> submitBatteryStatus(BatteryStatusSubmit statusData) async {
    try {
      logger.info('提交电池状态: materialId=${statusData.materialId}, level=${statusData.batteryLevel}%, health=${statusData.batteryHealth}');
      
      await _apiClient.post('/batteryStatus', body: statusData.toJson());
      return true;
    } catch (e) {
      logger.error('提交电池状态失败: $e');
      throw Exception('提交电池状态失败: $e');
    }
  }

  /// 查询电池历史状态
  /// [materialId]: 电池物资ID
  Future<List<BatteryStatusHistory>> getBatteryHistory(int materialId) async {
    try {
      logger.info('查询电池历史状态: materialId=$materialId');
      
      final List<dynamic> response = await _apiClient.get('/batteryHistory/$materialId');
      return response.map((json) => BatteryStatusHistory.fromJson(json)).toList();
    } catch (e) {
      logger.error('查询电池历史状态失败: $e');
      throw Exception('查询电池历史状态失败: $e');
    }
  }

  /// 新增电池
  /// [batteryData]: 电池数据
  /// 权限：管理员
  Future<Battery> addBattery(AddBatteryRequest batteryData) async {
    try {
      logger.info('新增电池: modelName=${batteryData.modelName}, snCode=${batteryData.snCode}');
      
      final response = await _apiClient.post('/admin/batteries', body: batteryData.toJson());
      return Battery.fromJson(response);
    } catch (e) {
      logger.error('新增电池失败: $e');
      throw Exception('新增电池失败: $e');
    }
  }

  /// 查询所有电池
  Future<List<Battery>> getAllBatteries() async {
    try {
      logger.info('查询所有电池列表');
      
      final List<dynamic> response = await _apiClient.get('/batteries');
      return response.map((json) => Battery.fromJson(json)).toList();
    } catch (e) {
      logger.error('查询所有电池失败: $e');
      throw Exception('查询所有电池失败: $e');
    }
  }

  /// 查询单个电池详情
  /// [materialId]: 电池物资ID
  Future<Battery> getBatteryDetail(int materialId) async {
    try {
      logger.info('查询电池详情: materialId=$materialId');
      
      final response = await _apiClient.get('/batteries/$materialId');
      return Battery.fromJson(response);
    } catch (e) {
      logger.error('查询电池详情失败: $e');
      throw Exception('查询电池详情失败: $e');
    }
  }

  /// 更新电池信息
  /// [materialId]: 电池物资ID
  /// [updateData]: 更新数据
  /// 权限：管理员
  Future<Battery> updateBattery(int materialId, UpdateBatteryRequest updateData) async {
    try {
      logger.info('更新电池信息: materialId=$materialId');
      
      final response = await _apiClient.put('/admin/batteries/$materialId', body: updateData.toJson());
      return Battery.fromJson(response);
    } catch (e) {
      logger.error('更新电池信息失败: $e');
      throw Exception('更新电池信息失败: $e');
    }
  }

  /// 删除（报废）电池
  /// [materialId]: 电池物资ID
  /// 权限：管理员
  Future<bool> deleteBattery(int materialId) async {
    try {
      logger.info('删除（报废）电池: materialId=$materialId');
      
      await _apiClient.delete('/admin/batteries/$materialId');
      return true;
    } catch (e) {
      logger.error('删除电池失败: $e');
      throw Exception('删除电池失败: $e');
    }
  }
}
