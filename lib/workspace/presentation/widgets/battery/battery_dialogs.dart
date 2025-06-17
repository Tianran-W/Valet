import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valet/workspace/models/battery_model.dart';

/// 添加电池对话框
class AddBatteryDialog extends StatefulWidget {
  const AddBatteryDialog({super.key});

  @override
  State<AddBatteryDialog> createState() => _AddBatteryDialogState();
}

class _AddBatteryDialogState extends State<AddBatteryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _modelNameController = TextEditingController();
  final _snCodeController = TextEditingController();
  final _lifespanCyclesController = TextEditingController();
  bool _isExpensive = false;

  @override
  void dispose() {
    _modelNameController.dispose();
    _snCodeController.dispose();
    _lifespanCyclesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'modelName': _modelNameController.text.trim(),
        'snCode': _snCodeController.text.trim(),
        'lifespanCycles': int.parse(_lifespanCyclesController.text.trim()),
        'isExpensive': _isExpensive,
      };
      Navigator.of(context).pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新电池'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: '电池型号 *',
                  hintText: '例如：DJI Mavic 3 智能飞行电池',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入电池型号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _snCodeController,
                decoration: const InputDecoration(
                  labelText: 'SN码 *',
                  hintText: '例如：DJI-M3B-20231101-005',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入SN码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _lifespanCyclesController,
                decoration: const InputDecoration(
                  labelText: '设计寿命（充电周期） *',
                  hintText: '例如：300',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入设计寿命';
                  }
                  final cycles = int.tryParse(value.trim());
                  if (cycles == null || cycles <= 0) {
                    return '请输入有效的充电周期数';
                  }
                  if (cycles > 10000) {
                    return '充电周期数不能超过10000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('标记为贵重物品'),
                subtitle: const Text('贵重物品需要特殊管理流程'),
                value: _isExpensive,
                onChanged: (value) {
                  setState(() {
                    _isExpensive = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('添加'),
        ),
      ],
    );
  }
}

/// 编辑电池对话框
class EditBatteryDialog extends StatefulWidget {
  final Battery battery;

  const EditBatteryDialog({
    super.key,
    required this.battery,
  });

  @override
  State<EditBatteryDialog> createState() => _EditBatteryDialogState();
}

class _EditBatteryDialogState extends State<EditBatteryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _modelNameController = TextEditingController();
  final _lifespanCyclesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _modelNameController.text = widget.battery.modelName;
    _lifespanCyclesController.text = widget.battery.lifespanCycles.toString();
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _lifespanCyclesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'modelName': _modelNameController.text.trim(),
        'lifespanCycles': int.parse(_lifespanCyclesController.text.trim()),
      };
      Navigator.of(context).pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('编辑电池: ${widget.battery.snCode}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 显示不可编辑的信息
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '电池信息',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('物资ID: ${widget.battery.materialId}'),
                      Text('SN码: ${widget.battery.snCode}'),
                      Text('当前状态: ${widget.battery.status}'),
                      Text('已使用周期: ${widget.battery.currentCycles}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: '电池型号 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入电池型号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _lifespanCyclesController,
                decoration: const InputDecoration(
                  labelText: '设计寿命（充电周期） *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入设计寿命';
                  }
                  final cycles = int.tryParse(value.trim());
                  if (cycles == null || cycles <= 0) {
                    return '请输入有效的充电周期数';
                  }
                  if (cycles > 10000) {
                    return '充电周期数不能超过10000';
                  }
                  if (cycles < widget.battery.currentCycles) {
                    return '设计寿命不能小于当前已使用周期数(${widget.battery.currentCycles})';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 提交电池状态对话框
class SubmitBatteryStatusDialog extends StatefulWidget {
  final Battery battery;

  const SubmitBatteryStatusDialog({
    super.key,
    required this.battery,
  });

  @override
  State<SubmitBatteryStatusDialog> createState() => _SubmitBatteryStatusDialogState();
}

class _SubmitBatteryStatusDialogState extends State<SubmitBatteryStatusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _batteryLevelController = TextEditingController();
  BatteryHealthStatus _selectedHealth = BatteryHealthStatus.good;

  @override
  void dispose() {
    _batteryLevelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'materialId': widget.battery.materialId,
        'batteryLevel': int.parse(_batteryLevelController.text.trim()),
        'batteryHealth': _selectedHealth.displayName,
      };
      Navigator.of(context).pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('提交电池状态: ${widget.battery.modelName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 电池信息卡片
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '电池信息',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('型号: ${widget.battery.modelName}'),
                      Text('SN码: ${widget.battery.snCode}'),
                      Text('当前状态: ${widget.battery.status}'),
                      Text('健康度: ${widget.battery.healthPercentage.toStringAsFixed(1)}% (${widget.battery.statusText})'),
                      Text('使用周期: ${widget.battery.currentCycles}/${widget.battery.lifespanCycles}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _batteryLevelController,
                decoration: const InputDecoration(
                  labelText: '当前电量 (%) *',
                  hintText: '0-100',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入当前电量';
                  }
                  final level = int.tryParse(value.trim());
                  if (level == null || level < 0 || level > 100) {
                    return '电量范围应在0-100之间';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<BatteryHealthStatus>(
                value: _selectedHealth,
                decoration: const InputDecoration(
                  labelText: '健康状态 *',
                  border: OutlineInputBorder(),
                ),
                items: BatteryHealthStatus.values.map((status) => DropdownMenuItem<BatteryHealthStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Icon(
                        _getHealthIcon(status),
                        color: _getHealthColor(status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                )).toList(),
                onChanged: (status) {
                  if (status != null) {
                    setState(() {
                      _selectedHealth = status;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              
              // 健康状态说明
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getHealthDescription(_selectedHealth),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('提交'),
        ),
      ],
    );
  }

  IconData _getHealthIcon(BatteryHealthStatus status) {
    switch (status) {
      case BatteryHealthStatus.excellent:
        return Icons.battery_full;
      case BatteryHealthStatus.good:
        return Icons.battery_6_bar;
      case BatteryHealthStatus.fair:
        return Icons.battery_4_bar;
      case BatteryHealthStatus.poor:
        return Icons.battery_2_bar;
      case BatteryHealthStatus.critical:
        return Icons.battery_alert;
    }
  }

  Color _getHealthColor(BatteryHealthStatus status) {
    switch (status) {
      case BatteryHealthStatus.excellent:
        return Colors.green;
      case BatteryHealthStatus.good:
        return Colors.lightGreen;
      case BatteryHealthStatus.fair:
        return Colors.orange;
      case BatteryHealthStatus.poor:
        return Colors.deepOrange;
      case BatteryHealthStatus.critical:
        return Colors.red;
    }
  }

  String _getHealthDescription(BatteryHealthStatus status) {
    switch (status) {
      case BatteryHealthStatus.excellent:
        return '电池性能优秀，充放电正常，续航时间满足预期';
      case BatteryHealthStatus.good:
        return '电池性能良好，充放电基本正常，续航时间略有下降';
      case BatteryHealthStatus.fair:
        return '电池性能一般，充放电速度有所下降，续航时间明显减少';
      case BatteryHealthStatus.poor:
        return '电池性能较差，充放电异常，续航时间严重下降';
      case BatteryHealthStatus.critical:
        return '电池性能极差，存在安全隐患，建议立即更换';
    }
  }
}
