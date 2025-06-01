import 'package:flutter/material.dart';
import 'package:valet/workspace/application/inventory_service.dart';

/// 添加新分类对话框
class AddCategoryDialog extends StatefulWidget {
  final InventoryService inventoryService;
  
  const AddCategoryDialog({
    super.key,
    required this.inventoryService,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 构建错误提示内容
  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(_errorMessage ?? '发生未知错误'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('关闭'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新分类'),
      content: _isSubmitting ? 
        const Center(child: CircularProgressIndicator()) :
        _errorMessage != null ? 
          _buildErrorContent() :
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类名称
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '分类名称 *',
                    hintText: '请输入分类名称',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitForm(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入分类名称';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
      actions: _isSubmitting || _errorMessage != null ? null : [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('确定'),
        ),
      ],
    );
  }

  // 提交表单
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        await widget.inventoryService.addCategory(
          name: _nameController.text.trim(),
        );
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }
}
