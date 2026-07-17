import 'package:flutter/material.dart';
import 'package:reimburse_mate/models/expense_category.dart';

class CategorySelector extends StatelessWidget {
  final ExpenseCategory selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ExpenseCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = ExpenseCategory.values[index];
          final isSelected = cat == selectedCategory;

          return ChoiceChip(
            label: Row(
              children: [
                Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                const SizedBox(width: 6),
                Text(cat.label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onCategorySelected(cat),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            side: BorderSide.none,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            selectedColor: cat.color,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}
