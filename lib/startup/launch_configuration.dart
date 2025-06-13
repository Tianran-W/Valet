import 'dart:io';

import 'package:flutter/foundation.dart';

enum IntegrationMode {
  develop,
  release,
  unitTest,
  integrationTest;

  // test mode
  bool get isTest => isUnitTest || isIntegrationTest;

  bool get isUnitTest => this == IntegrationMode.unitTest;

  bool get isIntegrationTest => this == IntegrationMode.integrationTest;

  // release mode
  bool get isRelease => this == IntegrationMode.release;

  // develop mode
  bool get isDevelop => this == IntegrationMode.develop;
}

/// 应用启动配置类
/// 包含应用启动时的各种配置参数
class LaunchConfiguration {
  /// 创建一个新的LaunchConfiguration实例
  /// [isAnonymousMode] 是否为匿名模式
  /// [version] 应用版本号
  LaunchConfiguration({
    this.isAnonymousMode = false,
    required this.version,
  }) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      integrationMode = IntegrationMode.unitTest;
    } else if (kReleaseMode) {
      integrationMode = IntegrationMode.release;
    } else {
      integrationMode = IntegrationMode.develop;
    }
  }

  /// 是否以匿名模式启动
  final bool isAnonymousMode;

  /// 应用版本
  final String version;

  /// 应用模式
  late final IntegrationMode integrationMode;
}
