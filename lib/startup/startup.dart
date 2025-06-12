import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:synchronized/synchronized.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/startup/deps_resolver.dart';
import 'package:valet/startup/entry_point.dart';
import 'package:valet/startup/launch_configuration.dart';
import 'package:valet/startup/tasks/app_widget.dart';
import 'package:valet/startup/tasks/feature_flag_task.dart';
import 'package:valet/startup/tasks/localization.dart';
import 'package:valet/startup/tasks/platform_error_catcher.dart';

/// 全局依赖注入容器实例
final getIt = GetIt.instance;

Future<void> runValet({bool isAnonymous = false}) async {
  logger.info('restart Valet: isAnon: $isAnonymous');

  await ValetRunner.run(ValetApplication());
}

/// 应用启动核心类
/// 负责协调和管理整个应用的启动流程
class ValetRunner {
  /// 启动应用
  static Future<void> run(EntryPoint f) async {
    // 清除所有已注册的服务和状态
    if (getIt.isRegistered<AppLauncher>(instance: AppLauncher)) {
      await getIt<AppLauncher>().dispose();
    }

    // 清除所有状态以重置应用状态
    await getIt.reset();

    final config = LaunchConfiguration(
      version: '1.0.0', // 应用版本，实际项目可从pubspec.yaml或构建配置中读取
      isAnonymousMode: false,
      isTestMode: false,
      isDevelopment: true, // 默认为开发环境，实际项目可从构建配置中读取
    );

    // 指定应用运行模式
    await initGetIt(getIt, f, config);

    // 创建应用启动器实例
    final launcher = getIt<AppLauncher>();
    launcher.addTasks(
      [
        // 平台错误捕获（最高优先级）
        PlatformErrorCatcherTask(),
        // 功能标志初始化
        FeatureFlagTask(),
        // 国际化
        LocalizationTask(),
        // UI组件初始化
        AppWidgetTask(),
      ],
    );
    await launcher.launch(); // 执行启动任务
  }
}

Future<void> initGetIt(
  GetIt getIt,
  EntryPoint f,
  LaunchConfiguration config,
) async {
  getIt.registerFactory<EntryPoint>(() => f);
  
  getIt.registerLazySingleton<AppLauncher>(
    () => AppLauncher(configuration: config),
    dispose: (launcher) async {
      await launcher.dispose();
    },
  );

  await dotenv.load(fileName: ".env/dev.env");

  // 注册API基础URL
  getIt.registerSingleton<String>(
    dotenv.env['BACKEND_URL'] ?? '',
    instanceName: 'baseUrl',
  );
  
  // 注册认证令牌（异步）
  // TODO: 从安全存储或用户登录状态获取
  getIt.registerSingletonAsync<String>(
    () async => '',
    instanceName: 'authToken',
  );

  await DepsResolver.resolve(getIt);
}

/// 应用启动器，负责按顺序执行启动任务
class AppLauncher {
  /// 创建一个新的AppLauncher实例
  /// [configuration] 启动配置
  AppLauncher({
    required LaunchConfiguration configuration
  }) : _configuration = configuration;

  final LaunchConfiguration _configuration;
  final List<LaunchTask> _tasks = [];
  final lock = Lock();

  void addTask(LaunchTask task) {
    lock.synchronized(() {
      logger.info('AppLauncher: adding task: $task');
      _tasks.add(task);
    });
  }

  void addTasks(Iterable<LaunchTask> tasks) {
    lock.synchronized(() {
      logger.info('AppLauncher: adding tasks: ${tasks.map((e) => e.runtimeType)}');
      _tasks.addAll(tasks);
    });
  }

  /// 初始化所有任务
  Future<void> launch() async {
    logger.info('开始执行启动任务序列，共${_tasks.length}个任务', tag: 'AppLauncher');
    
    for (final task in _tasks) {
      final taskName = task.runtimeType.toString();
      
      try {
        logger.debug('执行任务: $taskName', tag: 'AppLauncher');
        await task.initialize(_configuration);
        logger.debug('任务完成: $taskName', tag: 'AppLauncher');
      } catch (e, s) {
        logger.error('任务执行失败: $taskName', tag: 'AppLauncher', error: e, stackTrace: s);
        
        if (task.type == LaunchTaskType.appLauncher) {
          logger.fatal('应用启动任务失败，终止启动流程', tag: 'AppLauncher', error: e, stackTrace: s);
          rethrow;
        } else {
          logger.warning('继续执行后续任务', tag: 'AppLauncher');
        }
      }
    }
  }

  /// 释放所有任务资源
  Future<void> dispose() async {
    await lock.synchronized(() async {
      logger.info('开始清理启动任务资源，共${_tasks.length}个任务', tag: 'AppLauncher');
      
      // 反向执行释放操作，确保依赖关系正确处理
      for (final task in _tasks.reversed) {
        final taskName = task.runtimeType.toString();
        
        try {
          logger.debug('清理任务资源: $taskName', tag: 'AppLauncher');
          await task.dispose();
          logger.debug('任务资源清理完成: $taskName', tag: 'AppLauncher');
        } catch (e, s) {
          logger.error('任务资源清理失败: $taskName', tag: 'AppLauncher', error: e, stackTrace: s);
        }
      }
    });
  }
}

enum LaunchTaskType {
  dataProcessing,
  appLauncher,
}

/// 启动任务抽象基类
/// 定义了每个启动任务必须实现的接口
class LaunchTask {
  const LaunchTask();

  LaunchTaskType get type => LaunchTaskType.dataProcessing;

  /// 初始化任务
  Future<void> initialize(LaunchConfiguration configuration) async {
    logger.info('LaunchTask: $runtimeType initialize');
  }

  /// 释放任务资源
  Future<void> dispose() async {
    logger.info('LaunchTask: $runtimeType dispose');
  }
}
