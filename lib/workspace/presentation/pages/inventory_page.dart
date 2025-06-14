import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/workspace/application/inventory_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';
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
  
  // 分类过滤控制器
  final TextEditingController _categoryController = TextEditingController();
  String _categoryQuery = "";
  
  // 状态过滤
  InventoryStatus? _selectedStatus;
  final List<InventoryStatus?> _statusOptions = [null, ...InventoryStatus.values];
  
  // 贵重物品过滤
  bool? _isValuableFilter;
  
  // 当前用户借用的物品过滤
  bool _showMyBorrowings = false;
  List<int> _userBorrowedItemIds = [];
  
  // 当前用户ID (在实际应用中应从认证系统获取)
  final int _currentUserId = 1;
  
  // API服务
  late InventoryService _inventoryService;
  
  // 物品数据
  List<Item> _inventoryItems = [];
  
  // 加载状态
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  // 获取过滤后的物品列表
  List<Item> get _filteredItems {
    return _inventoryItems.where((item) {
      // 根据搜索词过滤
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.id.toString().contains(_searchQuery);
      
      // 根据分类过滤
      final matchesCategory = _categoryQuery.isEmpty || 
          item.category.toLowerCase().contains(_categoryQuery.toLowerCase());
      
      // 根据状态过滤
      final matchesStatus = _selectedStatus == null || item.status == _selectedStatus;
      
      // 根据贵重物品过滤
      final matchesValuable = _isValuableFilter == null || item.isValuable == _isValuableFilter;
      
      // 根据用户借用过滤
      final matchesUserBorrowings = !_showMyBorrowings || _userBorrowedItemIds.contains(item.id);
      
      return matchesSearch && matchesCategory && matchesStatus && matchesValuable && matchesUserBorrowings;
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
              _detailRow('类别', item.category),
              _detailRow('数量', '${item.quantity}'),
              _detailRow('贵重物品', item.isValuable ? '是' : '否'),
              _detailRow('状态', item.status.displayName),
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
              _showBorrowItemDialog(item);
            },
            child: const Text('借用'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showReturnItemDialog(item);
            },
            child: const Text('归还'),
          ),
        ],
      ),
    );
  }

  // 显示新增物品对话框
  Future<void> _showAddItemDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        inventoryService: _inventoryService,
      ),
    );
    
    if (result != null && mounted) {
      try {
        // 显示加载中提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在添加物品...')),
        );
        
        // 添加物品
        await _inventoryService.addItem(
          name: result['name'],
          category: result['categoryId'],
          quantity: result['quantity'],
          isValuable: result['isValuable'],
          serialNumber: result['serialNumber'],
          usageLimit: result['usageLimit'],
        );
        
        if (mounted) {
          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('添加成功'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 重新加载数据
          _loadInventoryItems();
        }
      } catch (e) {
        if (mounted) {
          // 显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 显示添加分类对话框
  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        inventoryService: _inventoryService,
      ),
    );
    
    if (result == true && mounted) {
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('分类添加成功'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 重新加载数据
      _loadInventoryItems();
    }
  }

  // 显示借用物品对话框
  Future<void> _showBorrowItemDialog(Item item) async {
    // 只有在库可借的物品才能借用
    if (item.status != InventoryStatus.inStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('物品: ${item.name} 当前状态为${item.status.displayName}，无法借用'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => BorrowItemDialog(
        item: item,
        userId: _currentUserId,
      ),
    );
    
    if (result != null && mounted) {
      try {
        // 显示加载中提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在处理借用请求...')),
        );
        
        // 借用物品
        await _inventoryService.borrowItem(
          materialId: result['materialId'],
          userId: result['userId'],
          isValuable: result['isValuable'],
          usageProject: result['usageProject'],
          approvalReason: result['approvalReason'],
        );
        
        if (mounted) {
          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('借用成功'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 重新加载数据
          _loadInventoryItems();
        }
      } catch (e) {
        if (mounted) {
          // 显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('借用失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 显示归还物品对话框
  Future<void> _showReturnItemDialog(Item item) async {
    // 只有借出的物品才能归还
    if (item.status != InventoryStatus.onLoan) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('物品: ${item.name} 当前状态为${item.status.displayName}，无法归还'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => ReturnItemDialog(
        item: item,
        userId: _currentUserId,
      ),
    );
    
    if (result != null && mounted) {
      try {
        // 显示加载中提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在处理归还请求...')),
        );
        
        // 归还物品
        await _inventoryService.returnItem(
          materialId: result['materialId'],
          userId: result['userId'],
        );
        
        if (mounted) {
          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('归还成功'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 重新加载数据
          _loadInventoryItems();
        }
      } catch (e) {
        if (mounted) {
          // 显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('归还失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 物品详情行，使用DetailRowWidget组件
  Widget _detailRow(String label, dynamic value) {
    return DetailRowWidget(label: label, value: value);
  }

  @override
  void initState() {
    super.initState();
    // 初始化API服务
    _inventoryService = getIt<InventoryService>();

    // 加载数据
    _loadInventoryItems();
  }
  
  // 从API加载物品数据
  Future<void> _loadInventoryItems() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });
    
    try {
      // 并行加载物品列表和用户借用记录
      final itemsFuture = _inventoryService.getInventoryItems(
        category: _categoryQuery.isEmpty ? null : _categoryQuery,
        status: _selectedStatus?.displayName,
      );
      
      final borrowingsFuture = _showMyBorrowings 
          ? _inventoryService.getUserBorrowings(_currentUserId)
          : Future.value(_userBorrowedItemIds);
      
      final results = await Future.wait([itemsFuture, borrowingsFuture]);
      final items = results[0] as List<Item>;
      final borrowedItemIds = results[1] as List<int>;
      
      setState(() {
        _inventoryItems = items;
        _userBorrowedItemIds = borrowedItemIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取物品列表失败: $_errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              onPressed: _loadInventoryItems,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
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
                    OutlinedButton.icon(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.category),
                      label: const Text('添加分类'),
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
              categoryController: _categoryController,
              categoryQuery: _categoryQuery,
              onCategoryChanged: (value) {
                setState(() {
                  _categoryQuery = value;
                });
                // 当分类更改时重新加载数据
                _loadInventoryItems();
              },
              selectedStatus: _selectedStatus,
              statusOptions: _statusOptions,
              onStatusChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                // 当状态更改时重新加载数据
                _loadInventoryItems();
              },
              isValuableFilter: _isValuableFilter,
              onIsValuableChanged: (value) {
                setState(() {
                  _isValuableFilter = value;
                });
              },
              showMyBorrowings: _showMyBorrowings,
              onShowMyBorrowingsChanged: (value) {
                setState(() {
                  _showMyBorrowings = value;
                });
                // 当切换"我的借用"过滤时重新加载数据
                _loadInventoryItems();
              },
            ),
            const SizedBox(height: 16),
            
            // 统计信息卡片
            InventoryStats(items: _inventoryItems),
            const SizedBox(height: 24),
            
            // 列表标题和刷新按钮
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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新列表',
                  onPressed: _loadInventoryItems,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 库存列表
            Expanded(
              child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('加载失败: $_errorMessage'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadInventoryItems,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : InventoryItemList(
                    items: _filteredItems,
                    onItemTap: _showItemDetails,
                    onItemBorrow: _showBorrowItemDialog,
                    onItemReturn: _showReturnItemDialog,
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
