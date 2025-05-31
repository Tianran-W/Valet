import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valet/workspace/application/inventory_service.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 添加新物品对话框
class AddItemDialog extends StatefulWidget {
  final InventoryService inventoryService;
  
  const AddItemDialog({
    super.key,
    required this.inventoryService,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _snCodeController = TextEditingController();
  final _usageLimitController = TextEditingController();
  
  // 选择的分类
  Category? _selectedCategory;
  bool _isValuable = false;
  bool _isLoading = true;
  String? _errorMessage;

  // 物品分类列表
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // 加载物品分类列表
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await widget.inventoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '获取物品类别失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _snCodeController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新物品'),
      content: _isLoading ? 
        const Center(child: CircularProgressIndicator()) :
        _errorMessage != null ? 
          _buildErrorContent() :
          _buildFormContent(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (!_isLoading && _errorMessage == null)
          FilledButton(
            onPressed: _submitForm,
            child: const Text('添加'),
          ),
      ],
    );
  }

  // 错误提示内容
  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _errorMessage ?? '未知错误',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadCategories,
          child: const Text('重试'),
        ),
      ],
    );
  }

  // 表单内容
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 物品名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '物品名称 *',
                hintText: '请输入物品名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入物品名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 物品数量
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '数量 *',
                hintText: '请输入物品数量',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入物品数量';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return '请输入有效的数量';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 物品分类
            DropdownButtonFormField<Category>(
              decoration: const InputDecoration(
                labelText: '物品分类 *',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return '请选择物品分类';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // SN码（可选）
            TextFormField(
              controller: _snCodeController,
              decoration: const InputDecoration(
                labelText: 'SN码（可选）',
                hintText: '请输入物品SN码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 使用期限（可选）
            TextFormField(
              controller: _usageLimitController,
              decoration: const InputDecoration(
                labelText: '使用期限（天数，可选）',
                hintText: '请输入物品使用期限',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            
            // 是否贵重
            SwitchListTile(
              title: const Text('是否贵重物品'),
              value: _isValuable,
              onChanged: (value) {
                setState(() {
                  _isValuable = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建物品数据
      final data = {
        'name': _nameController.text.trim(),
        'categoryId': _selectedCategory?.id ?? 0,
        'categoryName': _selectedCategory?.name ?? '',
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'isValuable': _isValuable,
        'serialNumber': _snCodeController.text.isEmpty ? null : _snCodeController.text.trim(),
        'usageLimit': _usageLimitController.text.isEmpty ? null : int.tryParse(_usageLimitController.text),
      };
      
      // 返回数据
      Navigator.of(context).pop(data);
    }
  }
}
