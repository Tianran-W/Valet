import 'package:flutter/material.dart';

/// 信息详情行组件
/// 在详情对话框中使用，用于显示键值对信息
class DetailRowWidget extends StatelessWidget {
  final String label;
  final dynamic value;

  const DetailRowWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '')),
        ],
      ),
    );
  }
}
