/*
 * Valet - 一个用于设备管理的Flutter应用
 * Copyright (C) 2025 您的姓名或组织
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'package:valet/workspace/presentation/home/erp_home_page.dart';
import 'package:valet/api/core/logger_service.dart';

void main() async {
  // 初始化日志服务
  logger.setLogLevel(Level.debug);
  logger.info('应用程序启动', tag: 'App');
  
  // 显示版权和许可信息
  if (kDebugMode) {
    logger.info('Valet  Copyright (C) 2025 HITCRT');
    logger.info('This program comes with ABSOLUTELY NO WARRANTY');
    logger.info('This is free software, and you are welcome to redistribute it');
    logger.info('under certain conditions; see the LICENSE file for details.');
  }

  // 初始化环境变量
  await dotenv.load(fileName: ".env/dev.env");

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
      home: const ERPHomePage(title: '科研设备管理'),
    );
  }
}
