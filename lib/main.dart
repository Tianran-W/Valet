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

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:valet/service/logger_service.dart';
import 'package:valet/startup/startup.dart';

/// 应用入口点
Future<void> main() async {
  // 初始化基本的日志服务
  logger.setLogLevel(Level.debug);
  logger.info('应用程序启动', tag: 'App');
  
  // 显示版权和许可信息
  if (kDebugMode) {
    logger.info('Valet  Copyright (C) 2025 HITCRT');
    logger.info('This program comes with ABSOLUTELY NO WARRANTY');
    logger.info('This is free software, and you are welcome to redistribute it');
    logger.info('under certain conditions; see the LICENSE file for details.');
  }

  await runValet(
    isAnonymous: false,
  );
}