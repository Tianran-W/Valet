import 'package:flutter/foundation.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 日志服务类，提供统一的日志记录功能
class LoggerService {
  /// 单例实例
  static final LoggerService _instance = LoggerService._internal();

  /// 当前日志级别，默认为 info
  LogLevel _currentLevel = LogLevel.info;

  /// 是否启用控制台输出
  bool _enableConsole = true;

  /// 是否启用文件输出（预留）
  bool _enableFile = false;

  /// 日志文件路径（预留）
  String? _logFilePath;

  /// 私有构造函数
  LoggerService._internal();

  /// 获取单例实例
  factory LoggerService() => _instance;

  /// 设置日志级别
  void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// 启用/禁用控制台输出
  void enableConsole(bool enable) {
    _enableConsole = enable;
  }

  /// 启用/禁用文件输出（预留）
  void enableFileOutput(bool enable, {String? filePath}) {
    _enableFile = enable;
    if (enable && filePath != null) {
      _logFilePath = filePath;
    }
  }

  /// 记录调试级别日志
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 记录信息级别日志
  void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 记录警告级别日志
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 记录错误级别日志
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 记录致命错误级别日志
  void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 内部日志记录方法
  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // 如果当前日志级别低于设置的级别，则不记录
    if (level.index < _currentLevel.index) {
      return;
    }

    final DateTime now = DateTime.now();
    final String formattedDate = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
    final String formattedTime = '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}.${_threeDigits(now.millisecond)}';
    final String levelString = level.toString().split('.').last.toUpperCase();
    final String tagString = tag != null ? '[$tag] ' : '';
    final String logMessage = '[$formattedDate $formattedTime] [$levelString] $tagString$message';

    // 控制台输出
    if (_enableConsole) {
      if (kDebugMode) {
        print(logMessage);
        if (error != null) {
          print('ERROR: $error');
        }
        if (stackTrace != null) {
          print('STACK TRACE: $stackTrace');
        }
      }
    }

    // 文件输出（预留）
    if (_enableFile && _logFilePath != null) {
      // TODO: 实现文件输出逻辑
    }
  }

  /// 格式化两位数字
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  /// 格式化三位数字
  String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }
}

/// 全局日志服务实例，方便直接调用
final logger = LoggerService();
