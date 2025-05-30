import 'package:flutter/material.dart';
import '../../models/inventory_model.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  // 库存分类过滤
  ProductCategory _selectedCategory = ProductCategory.all;
  final List<ProductCategory> _categories = ProductCategory.values;
  
  // 库存状态过滤
  InventoryStatus? _selectedStatus;
  final List<InventoryStatus?> _statusOptions = [null, ...InventoryStatus.values];
  
  // 示例库存数据
  final List<Product> _inventoryItems = [
    Product(
      id: "P001",
      name: "笔记本电脑",
      category: ProductCategory.electronics,
      price: 5999.00,
      stock: 15,
      status: InventoryStatus.normal,
      lastUpdate: "2025-05-25",
    ),
    Product(
      id: "P002",
      name: "办公座椅",
      category: ProductCategory.office,
      price: 799.00,
      stock: 3,
      status: InventoryStatus.low,
      lastUpdate: "2025-05-27",
    ),
    Product(
      id: "P003",
      name: "打印机墨盒",
      category: ProductCategory.office,
      price: 159.00,
      stock: 0,
      status: InventoryStatus.outOfStock,
      lastUpdate: "2025-05-20",
    ),
    Product(
      id: "P004",
      name: "智能手机",
      category: ProductCategory.electronics,
      price: 3299.00,
      stock: 42,
      status: InventoryStatus.normal,
      lastUpdate: "2025-05-28",
    ),
    Product(
      id: "P005",
      name: "矿泉水(箱)",
      category: ProductCategory.food,
      price: 36.00,
      stock: 8,
      status: InventoryStatus.normal,
      lastUpdate: "2025-05-29",
    ),
    Product(
      id: "P006",
      name: "工作服",
      category: ProductCategory.clothing,
      price: 128.00,
      stock: 4,
      status: InventoryStatus.low,
      lastUpdate: "2025-05-26",
    ),
    Product(
      id: "P007",
      name: "茶杯",
      category: ProductCategory.daily,
      price: 29.90,
      stock: 25,
      status: InventoryStatus.normal,
      lastUpdate: "2025-05-21",
    ),
  ];

  // 获取过滤后的库存列表
  List<Product> get _filteredItems {
    return _inventoryItems.where((product) {
      // 根据搜索词过滤
      final matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 根据分类过滤
      final matchesCategory = _selectedCategory == ProductCategory.all || 
          product.category == _selectedCategory;
      
      // 根据状态过滤
      final matchesStatus = _selectedStatus == null || product.status == _selectedStatus;
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // 显示商品详情对话框
  void _showItemDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('商品详情: ${product.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('商品ID', product.id),
              _detailRow('商品名称', product.name),
              _detailRow('类别', product.category.displayName),
              _detailRow('单价', '¥${product.price.toStringAsFixed(2)}'),
              _detailRow('库存数量', '${product.stock}'),
              _detailRow('库存状态', product.status.displayName),
              _detailRow('最后更新', product.lastUpdate),
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
              _showEditItemDialog(product);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  // 显示编辑商品对话框
  void _showEditItemDialog(Product product) {
    // 在实际应用中，这里会实现编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑商品: ${product.name} (功能开发中)')),
    );
  }

  // 显示新增商品对话框
  void _showAddItemDialog() {
    // 在实际应用中，这里会实现添加功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加新商品功能开发中')),
    );
  }

  // 商品详情行
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

  // 库存状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '正常':
        return Colors.green;
      case '低库存':
        return Colors.orange;
      case '缺货':
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
                  '商品总数',
                  '${_inventoryItems.length}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '低库存商品',
                  '${_inventoryItems.where((product) => product.status == InventoryStatus.low).length}',
                  Icons.warning_amber,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '缺货商品',
                  '${_inventoryItems.where((product) => product.status == InventoryStatus.outOfStock).length}',
                  Icons.error_outline,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 列表标题
            Row(
              children: [
                Text(
                  '库存列表',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filteredItems.length}个商品)',
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
                          final product = _filteredItems[index];
                          return ListTile(
                            onTap: () => _showItemDetails(product),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(product.id.substring(1)),
                            ),
                            title: Text(product.name),
                            subtitle: Text('${product.category.displayName} | ¥${product.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 库存状态标签
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(product.status.displayName).withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(product.status.displayName),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${product.status.displayName} (${product.stock})',
                                    style: TextStyle(
                                      color: _getStatusColor(product.status.displayName),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // 操作按钮
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showEditItemDialog(product),
                                  tooltip: '编辑',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // 显示更多操作菜单
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('更多操作: ${product.name}')),
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
