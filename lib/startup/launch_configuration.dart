import 'package:flutter/foundation.dart';

/// 应用启动配置类
/// 包含应用启动时的各种配置参数
class LaunchConfiguration {
  /// 创建一个新的LaunchConfiguration实例
  /// [isAnonymousMode] 是否为匿名模式
  /// [version] 应用版本号
  /// [isTestMode] 是否为测试模式
  /// [isDevelopment] 是否为开发环境
  /// [envVars] 环境变量
  LaunchConfiguration({
    this.isAnonymousMode = false,
    required this.version,
    this.isTestMode = false,
    this.isDevelopment = kDebugMode,
    Map<String, dynamic>? envVars,
  }) : envVars = envVars ?? {};

  /// 是否以匿名模式启动
  final bool isAnonymousMode;

  /// 应用版本
  final String version;

  /// 是否为测试模式
  final bool isTestMode;

  /// 是否为开发环境
  final bool isDevelopment;

  /// 环境变量
  final Map<String, dynamic> envVars;

  /// 创建一个深度拷贝
  LaunchConfiguration copyWith({
    bool? isAnonymousMode,
    String? version,
    bool? isTestMode,
    bool? isDevelopment,
    Map<String, dynamic>? envVars,
  }) {
    return LaunchConfiguration(
      isAnonymousMode: isAnonymousMode ?? this.isAnonymousMode,
      version: version ?? this.version,
      isTestMode: isTestMode ?? this.isTestMode,
      isDevelopment: isDevelopment ?? this.isDevelopment,
      envVars: envVars ?? Map.from(this.envVars),
    );
  }
}
