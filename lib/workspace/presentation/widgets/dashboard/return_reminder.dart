import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 归还提醒卡片组件
class ReturnReminderCard extends StatelessWidget {
  final List<ReturnReminder> reminders;

  const ReturnReminderCard({
    super.key,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    final overdueReminders = reminders.where((r) => r.isOverdue).toList();
    final upcomingReminders = reminders.where((r) => !r.isOverdue && r.daysUntilDue <= 3).toList();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_return,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '归还提醒',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: overdueReminders.isNotEmpty ? Colors.red.shade100 : 
                           upcomingReminders.isNotEmpty ? Colors.orange.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reminders.length}',
                    style: TextStyle(
                      color: overdueReminders.isNotEmpty ? Colors.red.shade700 : 
                             upcomingReminders.isNotEmpty ? Colors.orange.shade700 : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              const Text(
                '暂无归还提醒',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: reminders.take(3).map((reminder) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ReturnReminderItem(reminder: reminder),
                  )
                ).toList(),
              ),
            if (reminders.length > 3)
              TextButton(
                onPressed: () {
                  // 显示所有提醒
                  _showAllReminders(context);
                },
                child: Text('查看全部 ${reminders.length} 条提醒'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllReminders(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('归还提醒详情'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: reminders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => ReturnReminderItem(reminder: reminders[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 归还提醒项组件
class ReturnReminderItem extends StatelessWidget {
  final ReturnReminder reminder;

  const ReturnReminderItem({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = reminder.isOverdue;
    final daysUntilDue = reminder.daysUntilDue;
    
    Color backgroundColor = Colors.blue.shade50;
    Color borderColor = Colors.blue.shade200;
    String statusText = '正常';
    Color statusColor = Colors.blue;

    if (isOverdue) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      statusText = '已逾期';
      statusColor = Colors.red;
    } else if (daysUntilDue <= 1) {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
      statusText = '即将到期';
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.materialName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '借用人: ${reminder.borrower}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '归还日期: ${_formatDate(reminder.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
