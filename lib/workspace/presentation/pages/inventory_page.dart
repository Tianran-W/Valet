import 'package:flutter/material.dart';

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
  String _selectedCategory = "全部";
  final List<String> _categories = ["全部", "电子产品", "办公用品", "生活用品", "食品", "服装"];
  
  // 库存状态过滤
  String _selectedStatus = "全部";
  final List<String> _statusOptions = ["全部", "正常", "低库存", "缺货"];
  
  // 示例库存数据
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      "id": "P001",
      "name": "笔记本电脑",
      "category": "电子产品",
      "price": 5999.00,
      "stock": 15,
      "status": "正常",
      "lastUpdate": "2025-05-25",
    },
    {
      "id": "P002",
      "name": "办公座椅",
      "category": "办公用品",
      "price": 799.00,
      "stock": 3,
      "status": "低库存",
      "lastUpdate": "2025-05-27",
    },
    {
      "id": "P003",
      "name": "打印机墨盒",
      "category": "办公用品",
      "price": 159.00,
      "stock": 0,
      "status": "缺货",
      "lastUpdate": "2025-05-20",
    },
    {
      "id": "P004",
      "name": "智能手机",
      "category": "电子产品",
      "price": 3299.00,
      "stock": 42,
      "status": "正常",
      "lastUpdate": "2025-05-28",
    },
    {
      "id": "P005",
      "name": "矿泉水(箱)",
      "category": "食品",
      "price": 36.00,
      "stock": 8,
      "status": "正常",
      "lastUpdate": "2025-05-29",
    },
    {
      "id": "P006",
      "name": "工作服",
      "category": "服装",
      "price": 128.00,
      "stock": 4,
      "status": "低库存",
      "lastUpdate": "2025-05-26",
    },
    {
      "id": "P007",
      "name": "茶杯",
      "category": "生活用品",
      "price": 29.90,
      "stock": 25,
      "status": "正常",
      "lastUpdate": "2025-05-21",
    },
  ];

  // 获取过滤后的库存列表
  List<Map<String, dynamic>> get _filteredItems {
    return _inventoryItems.where((item) {
      // 根据搜索词过滤
      final matchesSearch = _searchQuery.isEmpty || 
          item["name"].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item["id"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 根据分类过滤
      final matchesCategory = _selectedCategory == "全部" || item["category"] == _selectedCategory;
      
      // 根据状态过滤
      final matchesStatus = _selectedStatus == "全部" || item["status"] == _selectedStatus;
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // 显示商品详情对话框
  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('商品详情: ${item['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('商品ID', item['id']),
              _detailRow('商品名称', item['name']),
              _detailRow('类别', item['category']),
              _detailRow('单价', '¥${item['price'].toStringAsFixed(2)}'),
              _detailRow('库存数量', '${item['stock']}'),
              _detailRow('库存状态', item['status']),
              _detailRow('最后更新', item['lastUpdate']),
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

  // 显示编辑商品对话框
  void _showEditItemDialog(Map<String, dynamic> item) {
    // 在实际应用中，这里会实现编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑商品: ${item["name"]} (功能开发中)')),
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
                  child: DropdownButtonFormField<String>(
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
                              child: Text(category),
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
                  child: DropdownButtonFormField<String>(
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
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
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
                  '${_inventoryItems.where((item) => item["status"] == "低库存").length}',
                  Icons.warning_amber,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '缺货商品',
                  '${_inventoryItems.where((item) => item["status"] == "缺货").length}',
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
                          final item = _filteredItems[index];
                          return ListTile(
                            onTap: () => _showItemDetails(item),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(item['id'].substring(1)),
                            ),
                            title: Text(item['name']),
                            subtitle: Text('${item['category']} | ¥${item['price'].toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 库存状态标签
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status']).withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(item['status']),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${item['status']} (${item['stock']})',
                                    style: TextStyle(
                                      color: _getStatusColor(item['status']),
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
                                      SnackBar(content: Text('更多操作: ${item["name"]}')),
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
