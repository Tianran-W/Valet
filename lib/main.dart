import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:valet/workspace/presentation/home/erp_home_page.dart';
import 'package:valet/api/core/logger_service.dart';

void main() {
  // 初始化日志服务
  logger.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
  logger.enableConsole(true);
  
  // 记录应用启动日志
  logger.info('应用程序启动', tag: 'App');
  
  // 运行应用
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ERPHomePage(title: '科研设备管理 仪表盘'),
    );
  }
}
