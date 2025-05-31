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
                  title: '今日销售额',
                  value: '¥158,200',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  change: '+15.3%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: '本月订单数',
                  value: '1,204',
                  icon: Icons.shopping_bag,
                  color: Colors.orange,
                  change: '+5.7%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: '库存商品',
                  value: '3,452',
                  icon: Icons.inventory_2,
                  color: Colors.green,
                  change: '-2.1%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: '员工出勤率',
                  value: '94.3%',
                  icon: Icons.people,
                  color: Colors.purple,
                  change: '+1.2%',
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
                  title: '确认月度财务报表',
                  deadline: '今天',
                  priority: 'high',
                ),
                Divider(height: 1),
                TodoItem(
                  title: '审批销售部门预算',
                  deadline: '明天',
                  priority: 'medium',
                ),
                Divider(height: 1),
                TodoItem(
                  title: '与供应商会议',
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
                  title: '新订单 #1058 已创建',
                  time: '10分钟前',
                  user: '销售部 - 张经理',
                ),
                Divider(height: 1),
                ActivityItem(
                  title: '发票 #2213 已支付',
                  time: '1小时前',
                  user: '财务部 - 李会计',
                ),
                Divider(height: 1),
                ActivityItem(
                  title: '新员工 王小明 已入职',
                  time: '今天上午',
                  user: '人事部 - 赵总监',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
