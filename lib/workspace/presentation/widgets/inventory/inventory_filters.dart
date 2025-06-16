import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 库存过滤组件
class InventoryFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final TextEditingController categoryController;
  final String categoryQuery;
  final Function(String) onCategoryChanged;
  final InventoryStatus? selectedStatus;
  final List<InventoryStatus?> statusOptions;
  final Function(InventoryStatus?) onStatusChanged;
  final bool? isValuableFilter; 
  final Function(bool?) onIsValuableChanged;
  final bool showMyBorrowings; // 是否显示我借用的物品
  final Function(bool) onShowMyBorrowingsChanged; // 切换显示我借用的物品

  const InventoryFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.categoryController,
    required this.categoryQuery,
    required this.onCategoryChanged,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
    required this.isValuableFilter,
    required this.onIsValuableChanged,
    required this.showMyBorrowings,
    required this.onShowMyBorrowingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // 搜索框
            Expanded(
              flex: 2,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '搜索物资名称、ID或SN码',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: 16),
            
            // 分类过滤
            Expanded(
              child: TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  hintText: '输入物资分类',
                  labelText: '物资分类',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 16),
            
            // 状态过滤
            Expanded(
              child: DropdownButtonFormField<InventoryStatus?>(
                decoration: InputDecoration(
                  labelText: '库存状态',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                value: selectedStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status?.displayName ?? '全部'),
                        ))
                    .toList(),
                onChanged: onStatusChanged,
              ),
            ),
            const SizedBox(width: 16),
            
            // 贵重物品过滤
            Expanded(
              child: DropdownButtonFormField<bool?>(
                decoration: InputDecoration(
                  labelText: '贵重物品',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                value: isValuableFilter,
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('全部'),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text('是'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('否'),
                  ),
                ],
                onChanged: onIsValuableChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 我的借用过滤开关
        Row(
          children: [
            Switch(
              value: showMyBorrowings,
              onChanged: onShowMyBorrowingsChanged,
            ),
            const Text('只显示我借用的物资'),
          ],
        ),
      ],
    );
  }
}
