import 'package:flutter/material.dart';
import 'package:valet/workspace/presentation/widgets/dashboard_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎回来，管理员',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          Text(
            '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          
          // 快速统计卡片
          const Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: '设备总数量',
                  value: '1,358',
                  icon: Icons.science,
                  color: Colors.blue,
                  change: '+3.2%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: '本月借用次数',
                  value: '245',
                  icon: Icons.swap_horiz,
                  color: Colors.orange,
                  change: '+8.5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: '维修中设备',
                  value: '32',
                  icon: Icons.build,
                  color: Colors.red,
                  change: '-4.1%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: '设备利用率',
                  value: '78.6%',
                  icon: Icons.analytics,
                  color: Colors.green,
                  change: '+2.3%',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          Text(
            '待办事项',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                TodoItem(
                  title: '完成实验室设备年度盘点',
                  deadline: '今天',
                  priority: 'high',
                ),
                Divider(height: 1),
                TodoItem(
                  title: '审核精密仪器采购申请',
                  deadline: '明天',
                  priority: 'medium',
                ),
                Divider(height: 1),
                TodoItem(
                  title: '协调机械设备维修事宜',
                  deadline: '后天',
                  priority: 'low',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            '最近活动',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ActivityItem(
                  title: '激光切割机 #A2201 已借出',
                  time: '10分钟前',
                  user: '材料实验室 - 陈研究员',
                ),
                Divider(height: 1),
                ActivityItem(
                  title: '高精度示波器 #E0512 已归还',
                  time: '1小时前',
                  user: '电子实验室 - 王工程师',
                ),
                Divider(height: 1),
                ActivityItem(
                  title: '新设备 3D扫描仪 已入库',
                  time: '今天上午',
                  user: '设备管理部 - 李主管',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
