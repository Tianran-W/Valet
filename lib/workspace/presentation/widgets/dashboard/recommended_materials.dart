import 'package:flutter/material.dart';
import 'package:valet/workspace/models/inventory_model.dart';

/// 推荐物资卡片组件
class RecommendedMaterialsCard extends StatelessWidget {
  final List<RecommendedMaterial> materials;
  final VoidCallback? onRefresh;

  const RecommendedMaterialsCard({
    super.key,
    required this.materials,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  '推荐物资',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: materials.isEmpty ? Colors.grey.shade100 : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${materials.length}',
                    style: TextStyle(
                      color: materials.isEmpty ? Colors.grey.shade700 : Colors.amber.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRefresh != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh,
                    tooltip: '刷新推荐',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (materials.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '暂无推荐物资，请设置项目信息获取个性化推荐',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: materials.take(5).map((material) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RecommendedMaterialItem(material: material),
                  )
                ).toList(),
              ),
            if (materials.length > 5)
              TextButton(
                onPressed: () {
                  _showAllMaterials(context);
                },
                child: Text('查看全部 ${materials.length} 条推荐'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllMaterials(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推荐物资详情'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: materials.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => RecommendedMaterialItem(
              material: materials[index],
              showDetails: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 推荐物资项组件
class RecommendedMaterialItem extends StatelessWidget {
  final RecommendedMaterial material;
  final bool showDetails;

  const RecommendedMaterialItem({
    super.key,
    required this.material,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  material.materialName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '平均使用: ${material.avgUsage.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            material.recommendReason,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (showDetails) ...[
            const SizedBox(height: 4),
            Text(
              'ID: ${material.materialId}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 推荐物资配置对话框
class RecommendationConfigDialog extends StatefulWidget {
  final Function(String projectType, int participantCount) onSubmit;
  final String? initialProjectType;
  final int? initialParticipantCount;

  const RecommendationConfigDialog({
    super.key,
    required this.onSubmit,
    this.initialProjectType,
    this.initialParticipantCount,
  });

  @override
  State<RecommendationConfigDialog> createState() => _RecommendationConfigDialogState();
}

class _RecommendationConfigDialogState extends State<RecommendationConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _projectTypeController = TextEditingController();
  final _participantCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectTypeController.text = widget.initialProjectType ?? '';
    _participantCountController.text = widget.initialParticipantCount?.toString() ?? '';
  }

  @override
  void dispose() {
    _projectTypeController.dispose();
    _participantCountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final projectType = _projectTypeController.text.trim();
      final participantCount = int.parse(_participantCountController.text.trim());
      
      widget.onSubmit(projectType, participantCount);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置推荐条件'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _projectTypeController,
              decoration: const InputDecoration(
                labelText: '项目类型 *',
                hintText: '例如：机器人竞赛、科研项目等',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入项目类型';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _participantCountController,
              decoration: const InputDecoration(
                labelText: '参与人数 *',
                hintText: '例如：10',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入参与人数';
                }
                final count = int.tryParse(value.trim());
                if (count == null || count <= 0) {
                  return '请输入有效的参与人数';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('获取推荐'),
        ),
      ],
    );
  }
}
