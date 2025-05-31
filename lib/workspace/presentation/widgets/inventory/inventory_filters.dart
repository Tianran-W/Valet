import 'package:flutter/material.dart';
import '../../../models/inventory_model.dart';

/// 库存过滤组件
class InventoryFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final ProductCategory selectedCategory;
  final List<ProductCategory> categories;
  final Function(ProductCategory?) onCategoryChanged;
  final InventoryStatus? selectedStatus;
  final List<InventoryStatus?> statusOptions;
  final Function(InventoryStatus?) onStatusChanged;

  const InventoryFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 搜索框
        Expanded(
          flex: 2,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索商品名称或ID',
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
          child: DropdownButtonFormField<ProductCategory>(
            decoration: InputDecoration(
              labelText: '商品分类',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            value: selectedCategory,
            items: categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    ))
                .toList(),
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
      ],
    );
  }
}
