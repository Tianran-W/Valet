import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 库存预警卡片组件
class InventoryAlertCard extends StatelessWidget {
  final List<MaterialAlert> alerts;

  const InventoryAlertCard({
    super.key,
    required this.alerts,
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
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '库存预警',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: alerts.isEmpty ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: TextStyle(
                      color: alerts.isEmpty ? Colors.green.shade700 : Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alerts.isEmpty)
              const Text(
                '暂无库存预警',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: alerts.take(3).map((alert) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InventoryAlertItem(alert: alert),
                  )
                ).toList(),
              ),
            if (alerts.length > 3)
              TextButton(
                onPressed: () {
                  // 显示所有预警
                  _showAllAlerts(context);
                },
                child: Text('查看全部 ${alerts.length} 条预警'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('库存预警详情'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => InventoryAlertItem(alert: alerts[index]),
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

/// 库存预警项组件
class InventoryAlertItem extends StatelessWidget {
  final MaterialAlert alert;

  const InventoryAlertItem({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.materialName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '当前库存: ${alert.currentQuantity} / 预警阈值: ${alert.alertThreshold}',
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
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '预警',
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
}
