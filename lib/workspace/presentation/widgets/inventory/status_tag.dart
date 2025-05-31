import 'package:flutter/material.dart';

/// 状态标签组件
class StatusTagWidget extends StatelessWidget {
  final String status;
  final String quantity;
  
  const StatusTagWidget({
    super.key, 
    required this.status,
    required this.quantity,
  });

  // 状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '在库可借':
        return Colors.green;
      case '已借出':
        return Colors.blue;
      case '维修中':
        return Colors.orange;
      case '已报废':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        '$status ($quantity)',
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
