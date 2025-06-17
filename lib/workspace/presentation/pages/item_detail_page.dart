import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/presentation/widgets/image_upload_widget.dart';

/// 物品详情页面
class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息卡片
            _buildBasicInfoCard(context),
            const SizedBox(height: 16),
            
            // 借用图片
            _buildImageSection(
              context, 
              '借用相关图片', 
              RecordType.borrow,
              item.id,
            ),
            const SizedBox(height: 16),
            
            // 归还图片
            _buildImageSection(
              context, 
              '归还相关图片', 
              RecordType.returnItem,
              item.id,
            ),
            const SizedBox(height: 16),
            
            // 报废图片
            _buildImageSection(
              context, 
              '报废相关图片', 
              RecordType.scrap,
              item.id,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('物品ID', item.id.toString()),
            _buildInfoRow('物品名称', item.name),
            _buildInfoRow('类别', item.category),
            _buildInfoRow('状态', item.status.displayName),
            _buildInfoRow('数量', item.quantity.toString()),
            _buildInfoRow('是否贵重', item.isValuable ? '是' : '否'),
            if (item.serialNumber != null && item.serialNumber!.isNotEmpty)
              _buildInfoRow('序列号', item.serialNumber!),
            if (item.usageLimit != null && item.usageLimit! > 0)
              _buildInfoRow('使用期限', '${item.usageLimit}天'),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 构建图片部分
  Widget _buildImageSection(
    BuildContext context,
    String title,
    RecordType recordType,
    int materialId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ImageUploadWidget(
              recordType: recordType,
              materialId: materialId,
              readOnly: true, // 详情页面为只读模式
              maxImages: 10,
            ),
          ],
        ),
      ),
    );
  }
}
