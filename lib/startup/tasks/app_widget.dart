import 'package:flutter/material.dart';

import 'package:valet/service/logger_service.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/workspace/presentation/home/home_page.dart';

/// UI组件初始化任务
/// 初始化应用的UI组件和主题
class AppWidgetTask extends LaunchTask {
  @override
  Future<void> initialize(LaunchConfiguration configuration) async {
    logger.info('初始化应用UI组件', tag: 'AppWidgetTask');
    
    // 确保Flutter绑定已初始化
    WidgetsFlutterBinding.ensureInitialized();
    
    // 这里可以进行主题预加载、字体加载等UI相关的初始化
    // 例如：await precacheImage(AssetImage('assets/images/logo.png'), null);

    runApp(MaterialApp(
        title: 'ERP System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(title: '科研设备管理'),
      )
    );
  }

  @override
  Future<void> dispose() async {
    // UI组件通常不需要特别清理
  }
}
