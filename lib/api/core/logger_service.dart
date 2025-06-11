import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志服务类，提供统一的日志记录功能，基于logger包实现
class LoggerService {
  /// 单例实例
  static final LoggerService _instance = LoggerService._internal();

  /// Logger实例
  late final Logger _logger;

  // 预留字段，将在实现文件输出时使用
  // bool _enableFile = false;
  // String? _logFilePath;

  /// 当前过滤器
  Level _currentLevel = Level.info;

  /// 私有构造函数
  LoggerService._internal() {
    // 初始化Logger
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,  // 方法堆栈数量
        errorMethodCount: 8,  // 错误时堆栈数量
        lineLength: 120,  // 每行长度
        colors: true,  // 彩色输出
        printEmojis: true,  // 打印表情
        dateTimeFormat: DateTimeFormat.dateAndTime,  // 日期时间格式
      ),
      level: _currentLevel,  // 默认日志级别
      filter: ProductionFilter(),  // 只在非发布版本中打印
    );
  }

  /// 获取单例实例
  factory LoggerService() => _instance;

  /// 设置日志级别
  void setLogLevel(Level level) {
    _currentLevel = level;
    Logger.level = level;
  }

  /// 启用/禁用文件输出
  void enableFileOutput(bool enable, {String? filePath}) {
    // TODO: 实现文件输出，需要自定义LogOutput
    if (enable && filePath != null) {
      // 未来实现文件输出的占位符
      // 可以使用FileOutput类来实现文件日志
    }
  }

  /// 记录调试级别日志
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    if (kDebugMode) {
      _logger.d(taggedMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// 记录信息级别日志
  void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.i(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// 记录警告级别日志
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.w(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// 记录错误级别日志
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.e(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// 记录致命错误级别日志
  void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.f(taggedMessage, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志服务实例，方便直接调用
final logger = LoggerService();
