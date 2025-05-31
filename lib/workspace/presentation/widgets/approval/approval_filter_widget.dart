import 'package:flutter/material.dart';
import 'package:valet/workspace/models/approval_model.dart';

/// 审批过滤器
class ApprovalFilterWidget extends StatefulWidget {
  final List<ApprovalType> selectedTypes;
  final Function(List<ApprovalType>) onFilterChanged;

  const ApprovalFilterWidget({
    super.key,
    required this.selectedTypes,
    required this.onFilterChanged,
  });

  @override
  State<ApprovalFilterWidget> createState() => _ApprovalFilterWidgetState();
}

class _ApprovalFilterWidgetState extends State<ApprovalFilterWidget> {
  late List<ApprovalType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final type in ApprovalType.values)
          FilterChip(
            label: Text(type.name),
            selected: _selectedTypes.contains(type),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  if (!_selectedTypes.contains(type)) {
                    _selectedTypes.add(type);
                  }
                } else {
                  _selectedTypes.remove(type);
                }
                widget.onFilterChanged(_selectedTypes);
              });
            },
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            checkmarkColor: Theme.of(context).colorScheme.primary,
          ),
        const SizedBox(width: 8),
        ActionChip(
          label: const Text('清除过滤'),
          onPressed: () {
            setState(() {
              _selectedTypes = List.from(ApprovalType.values);
              widget.onFilterChanged(_selectedTypes);
            });
          },
          avatar: const Icon(Icons.clear, size: 16),
        ),
      ],
    );
  }
}
