import 'package:flutter/material.dart';
import 'package:valet/workspace/models/battery_model.dart';
import 'package:valet/workspace/application/battery_service.dart';

/// 电池统计卡片
class BatteryStats extends StatelessWidget {
  final List<Battery> batteries;

  const BatteryStats({
    super.key,
    required this.batteries,
  });

  @override
  Widget build(BuildContext context) {
    final stats = BatteryService.getBatteryStatistics(batteries);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '电池统计',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '总数',
                    value: stats['total'].toString(),
                    color: Colors.blue,
                    icon: Icons.battery_unknown,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '在库',
                    value: stats['inStock'].toString(),
                    color: Colors.green,
                    icon: Icons.battery_full,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '已借出',
                    value: stats['borrowed'].toString(),
                    color: Colors.orange,
                    icon: Icons.battery_6_bar,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '需更换',
                    value: stats['needsReplacement'].toString(),
                    color: Colors.red,
                    icon: Icons.battery_alert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '平均健康度: ${stats['avgHealth'].toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withAlpha(51),
          radius: 20,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

/// 电池过滤器组件
class BatteryFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? statusFilter;
  final List<String> statusOptions;
  final ValueChanged<String?> onStatusChanged;
  final BatteryStatusColor? healthFilter;
  final ValueChanged<BatteryStatusColor?> onHealthChanged;
  final BatterySortField sortField;
  final bool sortAscending;
  final Function(BatterySortField, bool) onSortChanged;

  const BatteryFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.statusOptions,
    required this.onStatusChanged,
    required this.healthFilter,
    required this.onHealthChanged,
    required this.sortField,
    required this.sortAscending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索型号、SN码或状态...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            
            // 过滤选项
            Row(
              children: [
                // 状态过滤
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: statusFilter,
                    decoration: const InputDecoration(
                      labelText: '状态',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('全部状态'),
                      ),
                      ...statusOptions.map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      )),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 健康度过滤
                Expanded(
                  child: DropdownButtonFormField<BatteryStatusColor>(
                    value: healthFilter,
                    decoration: const InputDecoration(
                      labelText: '健康度',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<BatteryStatusColor>(
                        value: null,
                        child: Text('全部'),
                      ),
                      ...BatteryStatusColor.values.map((color) => DropdownMenuItem<BatteryStatusColor>(
                        value: color,
                        child: Text(_getHealthDisplayName(color)),
                      )),
                    ],
                    onChanged: onHealthChanged,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 排序选项
                Expanded(
                  child: DropdownButtonFormField<BatterySortField>(
                    value: sortField,
                    decoration: const InputDecoration(
                      labelText: '排序',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: BatterySortField.values.map((field) => DropdownMenuItem<BatterySortField>(
                      value: field,
                      child: Text(field.displayName),
                    )).toList(),
                    onChanged: (field) {
                      if (field != null) {
                        onSortChanged(field, sortAscending);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                
                // 排序方向按钮
                IconButton(
                  icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  tooltip: sortAscending ? '升序' : '降序',
                  onPressed: () => onSortChanged(sortField, !sortAscending),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthDisplayName(BatteryStatusColor color) {
    switch (color) {
      case BatteryStatusColor.excellent:
        return '优秀 (80-100%)';
      case BatteryStatusColor.good:
        return '良好 (60-80%)';
      case BatteryStatusColor.fair:
        return '一般 (40-60%)';
      case BatteryStatusColor.poor:
        return '较差 (20-40%)';
      case BatteryStatusColor.critical:
        return '极差 (0-20%)';
    }
  }
}

/// 电池列表组件
class BatteryList extends StatelessWidget {
  final List<Battery> batteries;
  final Function(Battery) onBatteryTap;
  final Function(Battery) onSubmitStatus;
  final Function(Battery) onEditBattery;
  final Function(Battery) onDeleteBattery;
  final dynamic currentUser; // 当前用户信息

  const BatteryList({
    super.key,
    required this.batteries,
    required this.onBatteryTap,
    required this.onSubmitStatus,
    required this.onEditBattery,
    required this.onDeleteBattery,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (batteries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.battery_unknown, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无电池数据', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Card(
      elevation: 1,
      child: ListView.separated(
        itemCount: batteries.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final battery = batteries[index];
          return BatteryTile(
            battery: battery,
            onTap: () => onBatteryTap(battery),
            onSubmitStatus: () => onSubmitStatus(battery),
            onEdit: () => onEditBattery(battery),
            onDelete: () => onDeleteBattery(battery),
            isAdmin: currentUser?.isAdmin ?? false,
          );
        },
      ),
    );
  }
}

/// 电池项目Tile
class BatteryTile extends StatelessWidget {
  final Battery battery;
  final VoidCallback onTap;
  final VoidCallback onSubmitStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAdmin;

  const BatteryTile({
    super.key,
    required this.battery,
    required this.onTap,
    required this.onSubmitStatus,
    required this.onEdit,
    required this.onDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor(battery.statusColor);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              battery.modelName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // 健康度指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: healthColor.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: healthColor.withAlpha(102)),
            ),
            child: Text(
              '${battery.healthPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: healthColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('SN: ${battery.snCode}'),
          const SizedBox(height: 2),
          Row(
            children: [
              Text('状态: ${battery.status}'),
              const SizedBox(width: 16),
              Text('循环: ${battery.currentCycles}/${battery.lifespanCycles}'),
            ],
          ),
          const SizedBox(height: 4),
          // 健康度进度条
          LinearProgressIndicator(
            value: battery.healthPercentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(healthColor),
          ),
          const SizedBox(height: 2),
          Text(
            '健康度: ${battery.statusText}',
            style: TextStyle(
              color: healthColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 提交状态按钮
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: '提交状态',
            onPressed: onSubmitStatus,
          ),
          // 管理员专用按钮
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '编辑',
              onPressed: onEdit,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  enabled: battery.status != '已报废',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: battery.status == '已报废' ? Colors.grey : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '报废',
                        style: TextStyle(
                          color: battery.status == '已报废' ? Colors.grey : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Color _getHealthColor(BatteryStatusColor statusColor) {
    switch (statusColor) {
      case BatteryStatusColor.excellent:
        return Colors.green;
      case BatteryStatusColor.good:
        return Colors.lightGreen;
      case BatteryStatusColor.fair:
        return Colors.orange;
      case BatteryStatusColor.poor:
        return Colors.deepOrange;
      case BatteryStatusColor.critical:
        return Colors.red;
    }
  }
}

/// 电池健康状态指示器
class BatteryHealthIndicator extends StatelessWidget {
  final double healthPercentage;
  final double size;

  const BatteryHealthIndicator({
    super.key,
    required this.healthPercentage,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForHealth(healthPercentage);
    final icon = _getIconForHealth(healthPercentage);

    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  Color _getColorForHealth(double health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.lightGreen;
    if (health >= 40) return Colors.orange;
    if (health >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getIconForHealth(double health) {
    if (health >= 80) return Icons.battery_full;
    if (health >= 60) return Icons.battery_6_bar;
    if (health >= 40) return Icons.battery_4_bar;
    if (health >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}
