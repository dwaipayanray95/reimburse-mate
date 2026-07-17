import 'package:flutter/material.dart';
import 'package:reimburse_mate/models/claim_status.dart';

class FilterBar extends StatelessWidget {
  final ClaimStatus? selectedStatus;
  final ValueChanged<ClaimStatus?> onStatusChanged;

  const FilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: ClaimStatus.values.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = selectedStatus == null;
            return ChoiceChip(
              label: const Text('All Claims'),
              selected: isAll,
              onSelected: (_) => onStatusChanged(null),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
              backgroundColor: theme.colorScheme.surfaceContainer,
              side: BorderSide.none,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isAll ? theme.colorScheme.onPrimary : unselectedColor,
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final status = ClaimStatus.values[index - 1];
          final isSelected = selectedStatus == status;

          return ChoiceChip(
            label: Text(status.label),
            selected: isSelected,
            onSelected: (_) => onStatusChanged(status),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            backgroundColor: theme.colorScheme.surfaceContainer,
            side: BorderSide.none,
            selectedColor: status.color,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : unselectedColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}
