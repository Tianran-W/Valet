import 'package:flutter/widgets.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/startup/startup.dart';

/// 国际化初始化任务
/// 初始化应用的国际化支持
class LocalizationTask extends LaunchTask {
  @override
  Future<void> initialize(LaunchConfiguration configuration) async {
    logger.info('初始化国际化支持', tag: 'LocalizationTask');
    
    // 确保Flutter绑定已初始化
    WidgetsFlutterBinding.ensureInitialized();
    
    // 这里可以初始化应用的国际化支持
    // 例如：await EasyLocalization.ensureInitialized();
    
    logger.debug('国际化支持初始化完成', tag: 'LocalizationTask');
  }

  @override
  Future<void> dispose() async {
    // 国际化资源通常不需要特别清理
  }
}
