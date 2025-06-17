import 'dart:io';
import 'package:flutter/foundation.dart';

/// 平台检测工具类
class PlatformHelper {
  
  /// 是否为移动端平台
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// 是否为桌面端平台
  static bool get isDesktop {
    if (kIsWeb) return true; // Web版本按桌面端处理
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  /// 是否为Web平台
  static bool get isWeb => kIsWeb;
  
  /// 获取当前平台名称
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// 是否支持相机功能
  static bool get supportCamera {
    if (kIsWeb) return true; // Web支持相机
    return Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  /// 是否支持文件系统选择
  static bool get supportFilePicker {
    return true; // 所有平台都支持文件选择
  }
}
