import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/workspace/application/platform_helper.dart';

/// 权限管理工具类
class PermissionHelper {
  static const String _tag = 'PermissionHelper';

  /// 检查并请求相机权限
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // 桌面端通常不需要额外的相机权限请求
    if (PlatformHelper.isDesktop) {
      logger.debug('桌面端跳过相机权限检查', tag: _tag);
      return true;
    }

    try {
      logger.info('正在检查相机权限', tag: _tag);
      
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        logger.debug('相机权限已授予', tag: _tag);
        return true;
      }
      
      if (status.isDenied) {
        logger.info('请求相机权限', tag: _tag);
        final result = await Permission.camera.request();
        
        if (result.isGranted) {
          logger.debug('相机权限授予成功', tag: _tag);
          return true;
        } else {
          logger.warning('相机权限被拒绝', tag: _tag);
          if (context.mounted) {
            await _showPermissionDialog(
              context,
              '相机权限',
              '需要相机权限才能拍照上传图片',
            );
          }
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        logger.warning('相机权限被永久拒绝', tag: _tag);
        if (context.mounted) {
          await _showSettingsDialog(
            context,
            '相机权限被拒绝',
            '请在设置中开启相机权限以便拍照上传图片',
          );
        }
        return false;
      }
      
      return false;
    } catch (e) {
      logger.error('检查相机权限失败', tag: _tag, error: e);
      return false;
    }
  }

  /// 检查并请求相册权限
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // 桌面端使用文件选择器，不需要存储权限
    if (PlatformHelper.isDesktop) {
      logger.debug('桌面端跳过存储权限检查', tag: _tag);
      return true;
    }

    try {
      logger.info('正在检查存储权限', tag: _tag);
      
      // 根据平台选择合适的权限
      Permission permission;
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        permission = Permission.photos;
      } else {
        // Android 13+ 使用photos权限，之前版本使用storage权限
        permission = Permission.photos;
      }
      
      final status = await permission.status;
      
      if (status.isGranted) {
        logger.debug('存储权限已授予', tag: _tag);
        return true;
      }
      
      if (status.isDenied) {
        logger.info('请求存储权限', tag: _tag);
        final result = await permission.request();
        
        if (result.isGranted) {
          logger.debug('存储权限授予成功', tag: _tag);
          return true;
        } else {
          logger.warning('存储权限被拒绝', tag: _tag);
          if (context.mounted) {
            await _showPermissionDialog(
              context,
              '相册权限',
              '需要相册权限才能选择图片上传',
            );
          }
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        logger.warning('存储权限被永久拒绝', tag: _tag);
        if (context.mounted) {
          await _showSettingsDialog(
            context,
            '相册权限被拒绝',
            '请在设置中开启相册权限以便选择图片上传',
          );
        }
        return false;
      }
      
      return false;
    } catch (e) {
      logger.error('检查存储权限失败', tag: _tag, error: e);
      return false;
    }
  }

  /// 显示权限说明对话框
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示设置页面对话框
  static Future<void> _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('打开设置'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
