import 'package:flutter/material.dart';

// 统计卡片组件
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const DashboardCard({
    super.key, 
    required this.title, 
    required this.value, 
    required this.icon, 
    required this.color,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                color: change.contains('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 待办事项组件
class TodoItem extends StatelessWidget {
  final String title;
  final String deadline;
  final String priority;

  const TodoItem({
    super.key, 
    required this.title, 
    required this.deadline, 
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text('截止: $deadline'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: priority == 'high' ? Colors.red.shade100 : 
                 priority == 'medium' ? Colors.orange.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          priority == 'high' ? '高优' : 
          priority == 'medium' ? '中优' : '低优',
          style: TextStyle(
            color: priority == 'high' ? Colors.red.shade700 : 
                   priority == 'medium' ? Colors.orange.shade700 : Colors.green.shade700,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () {
        // 处理点击事件
      },
    );
  }
}

// 活动项组件
class ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String user;

  const ActivityItem({
    super.key, 
    required this.title, 
    required this.time, 
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(user),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      onTap: () {
        // 处理点击事件
      },
    );
  }
}
