import 'package:flutter/material.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/startup/authenticated_entry_point.dart';

/// 应用程序入口点抽象类
/// 定义了应用启动的标准接口
abstract class EntryPoint {
  Widget create(LaunchConfiguration config);
}

/// Valet应用程序入口点
/// 负责创建和配置应用的主界面
class ValetApplication implements EntryPoint {
  @override
  Widget create(LaunchConfiguration config) {
    return AppRoot();
  }
}