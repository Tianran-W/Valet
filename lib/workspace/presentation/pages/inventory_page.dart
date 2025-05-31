import 'package:flutter/material.dart';
import '../../models/inventory_model.dart';
import '../../models/item_examples.dart';

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

  // 物品详情行
  Widget _detailRow(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

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
                      label: const Text('添加商品'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 搜索和过滤区域
            Row(
              children: [
                // 搜索框
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索商品名称或ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
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
                    value: _selectedStatus,
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status?.displayName ?? '全部'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 统计信息卡片
            Row(
              children: [
                _buildStatCard(
                  '物品总数',
                  '${_inventoryItems.length}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '已借出',
                  '${_inventoryItems.where((item) => item.status == InventoryStatus.onLoan).length}',
                  Icons.person,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '维修中',
                  '${_inventoryItems.where((item) => item.status == InventoryStatus.maintenance).length}',
                  Icons.build,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '已报废',
                  '${_inventoryItems.where((item) => item.status == InventoryStatus.scrapped).length}',
                  Icons.delete_outline,
                  Colors.red,
                ),
              ],
            ),
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
              child: Card(
                elevation: 1,
                child: _filteredItems.isEmpty
                    ? const Center(child: Text('没有找到匹配的商品'))
                    : ListView.separated(
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
                            onTap: () => _showItemDetails(item),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(item.id.substring(1)),
                            ),
                            title: Text(item.name),
                            subtitle: Text('${item.category.displayName} | ¥${item.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 库存状态标签
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item.status.displayName).withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(item.status.displayName),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${item.status.displayName} (${item.quantity})',
                                    style: TextStyle(
                                      color: _getStatusColor(item.status.displayName),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // 操作按钮
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showEditItemDialog(item),
                                  tooltip: '编辑',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // 显示更多操作菜单
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('更多操作: ${item.name}')),
                                    );
                                  },
                                  tooltip: '更多操作',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 统计卡片组件
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(51),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
