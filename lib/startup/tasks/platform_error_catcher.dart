import 'package:valet/service/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valet/startup/launch_configuration.dart';

import '../startup.dart';

class PlatformErrorCatcherTask extends LaunchTask {
  @override
  Future<void> initialize(LaunchConfiguration configuration) async {
    await super.initialize(configuration);

    // 处理未被 Flutter 捕获的平台错误。
    // 降低应用崩溃的可能性，并记录错误日志。
    // 仅在非调试模式下生效。
    if (!kDebugMode) {
      PlatformDispatcher.instance.onError = (error, stack) {
        logger.error('Uncaught platform error', error: error, stackTrace: stack);
        return true;
      };
    }

    ErrorWidget.builder = (details) {
      if (kDebugMode) {
        return Container(
          width: double.infinity,
          height: 30,
          color: Colors.red,
          child: Text(
            'ERROR: ${details.exceptionAsString()}',
          ),
        );
      }

      // 在非调试模式下，隐藏错误小部件
      return const SizedBox.shrink();
    };
  }
}
