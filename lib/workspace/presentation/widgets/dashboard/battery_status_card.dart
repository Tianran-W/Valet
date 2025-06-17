import 'package:flutter/material.dart';
import 'package:valet/workspace/models/battery_model.dart';

/// 电池状态卡片 - 用于仪表盘显示
class BatteryStatusCard extends StatelessWidget {
  final List<Battery> batteries;
  final VoidCallback? onTap;

  const BatteryStatusCard({
    super.key,
    required this.batteries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.battery_6_bar,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '电池状态',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '电池健康度监控',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 统计信息
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      label: '总数',
                      value: stats['total'].toString(),
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: '健康',
                      value: stats['healthy'].toString(),
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: '警告',
                      value: stats['warning'].toString(),
                      color: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: '需更换',
                      value: stats['critical'].toString(),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              
              if (stats['critical'] != null && stats['critical']! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '有 ${stats['critical']!} 块电池需要更换',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    int total = batteries.length;
    int healthy = 0;
    int warning = 0;
    int critical = 0;

    for (final battery in batteries) {
      switch (battery.statusColor) {
        case BatteryStatusColor.excellent:
        case BatteryStatusColor.good:
          healthy++;
          break;
        case BatteryStatusColor.fair:
        case BatteryStatusColor.poor:
          warning++;
          break;
        case BatteryStatusColor.critical:
          critical++;
          break;
      }
    }

    return {
      'total': total,
      'healthy': healthy,
      'warning': warning,
      'critical': critical,
    };
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
