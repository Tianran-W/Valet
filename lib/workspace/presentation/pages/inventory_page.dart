import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/item_examples.dart';
import 'package:valet/workspace/presentation/widgets/inventory/inventory_widgets.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  // 分类过滤
  ProductCategory _selectedCategory = ProductCategory.all;
  final List<ProductCategory> _categories = ProductCategory.values;
  
  // 状态过滤
  InventoryStatus? _selectedStatus;
  final List<InventoryStatus?> _statusOptions = [null, ...InventoryStatus.values];
  
  // 示例物品数据
  final List<Item> _inventoryItems = ItemExamples.getAllItems();

  // 获取过滤后的物品列表
  List<Item> get _filteredItems {
    return _inventoryItems.where((item) {
      // 根据搜索词过滤
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 根据分类过滤
      final matchesCategory = _selectedCategory == ProductCategory.all || 
          item.category == _selectedCategory;
      
      // 根据状态过滤
      final matchesStatus = _selectedStatus == null || item.status == _selectedStatus;
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // 显示物品详情对话框
  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('物品详情: ${item.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('物品ID', item.id),
              _detailRow('物品名称', item.name),
              _detailRow('类别', item.category.displayName),
              _detailRow('单价', '¥${item.price.toStringAsFixed(2)}'),
              _detailRow('数量', '${item.quantity}'),
              _detailRow('状态', item.status.displayName),
              if (item.status == InventoryStatus.onLoan && item.borrowedBy != null)
                _detailRow('借用人', item.borrowedBy!),
              _detailRow('最后更新', item.lastUpdate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditItemDialog(item);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  // 显示编辑物品对话框
  void _showEditItemDialog(Item item) {
    // 在实际应用中，这里会实现编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑物品: ${item.name} (功能开发中)')),
    );
  }

  // 显示新增物品对话框
  void _showAddItemDialog() {
    // 在实际应用中，这里会实现添加功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加新物品功能开发中')),
    );
  }

  // 物品详情行，使用DetailRowWidget组件
  Widget _detailRow(String label, String value) {
    return DetailRowWidget(label: label, value: value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '库存管理',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // 导出数据功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导出功能开发中')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('导出'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _showAddItemDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('添加物资'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 搜索和过滤区域
            InventoryFilters(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              selectedCategory: _selectedCategory,
              categories: _categories,
              onCategoryChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              selectedStatus: _selectedStatus,
              statusOptions: _statusOptions,
              onStatusChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 统计信息卡片
            InventoryStats(items: _inventoryItems),
            const SizedBox(height: 24),
            
            // 列表标题
            Row(
              children: [
                Text(
                  '物品列表',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filteredItems.length}个物品)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 库存列表
            Expanded(
              child: InventoryItemList(
                items: _filteredItems,
                onItemTap: _showItemDetails,
                onItemEdit: _showEditItemDialog,
                onItemMoreActions: (item) {
                  // 显示更多操作菜单
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更多操作: ${item.name}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}
