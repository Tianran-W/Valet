import 'package:flutter/foundation.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/startup/startup.dart';

/// 功能标志管理类
/// 用于控制应用中的功能开关
class FeatureFlags {
  static final FeatureFlags _instance = FeatureFlags._internal();
  factory FeatureFlags() => _instance;
  
  FeatureFlags._internal();
  
  /// 功能开关映射表
  final Map<String, bool> _flags = {};
  
  /// 设置功能标志
  void setFlag(String name, bool value) {
    _flags[name] = value;
  }
  
  /// 批量设置功能标志
  void setFlags(Map<String, bool> flags) {
    _flags.addAll(flags);
  }
  
  /// 检查功能是否启用
  bool isEnabled(String name) {
    return _flags[name] ?? false;
  }
  
  /// 清除所有功能标志
  void clear() {
    _flags.clear();
  }
}

/// 功能标志初始化任务
/// 负责初始化应用的功能开关
class FeatureFlagTask extends LaunchTask {
  final FeatureFlags _featureFlags = FeatureFlags();

  @override
  Future<void> initialize(LaunchConfiguration configuration) async {
    logger.info('初始化功能标志', tag: 'FeatureFlagTask');
    
    try {
      // 设置基础功能标志
      final baseFlags = <String, bool>{
        'dark_theme': true,
        'notifications': true,
        'offline_mode': false,
        'analytics': !configuration.isAnonymousMode,
      };
      
      // 设置开发环境特定的功能标志
      if (configuration.isDevelopment) {
        baseFlags.addAll({
          'debug_overlay': true,
          'test_features': true,
        });
      }
      
      // 设置测试环境特定的功能标志
      if (configuration.isTestMode) {
        baseFlags.addAll({
          'mock_api': true,
          'fast_animations': true,
        });
      }
      
      // 从配置中应用环境变量中的功能标志
      if (configuration.envVars.containsKey('feature_flags')) {
        final envFlags = configuration.envVars['feature_flags'] as Map<String, bool>?;
        if (envFlags != null) {
          baseFlags.addAll(envFlags);
        }
      }
      
      // 应用所有功能标志
      _featureFlags.setFlags(baseFlags);
      
      logger.debug('功能标志初始化完成，共${baseFlags.length}个标志', tag: 'FeatureFlagTask');
      
      // 如果在调试模式下，打印所有功能标志的状态
      if (kDebugMode) {
        baseFlags.forEach((key, value) {
          logger.debug('功能标志: $key = $value', tag: 'FeatureFlagTask');
        });
      }
    } catch (e, s) {
      logger.error('功能标志初始化失败', tag: 'FeatureFlagTask', error: e, stackTrace: s);
      // 非关键任务，不抛出异常
    }
  }
  
  @override
  Future<void> dispose() async {
    // 清除所有功能标志
    _featureFlags.clear();
    logger.debug('功能标志已清除', tag: 'FeatureFlagTask');
  }
}
