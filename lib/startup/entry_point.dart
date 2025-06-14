import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/user/presentation/pages/login_page.dart';
import 'package:valet/workspace/presentation/home/home_page.dart';

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

/// 应用根组件
/// 负责检查用户认证状态并决定显示登录页面还是主应用
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AuthService _authService;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
    _checkAuthStatus();
  }

  /// 检查用户认证状态
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.checkAuthStatus();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 显示加载页面
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载...'),
            ],
          ),
        ),
      );
    }

    // 根据认证状态决定显示的页面
    if (_isLoggedIn) {
      return const HomePage(title: '科研设备管理');
    } else {
      return const LoginPage();
    }
  }
}