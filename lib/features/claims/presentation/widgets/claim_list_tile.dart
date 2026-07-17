import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/models/claim_status.dart';
import 'package:reimburse_mate/models/expense_category.dart';
import 'package:reimburse_mate/core/widgets/status_chip.dart';

class ClaimListTile extends StatelessWidget {
  final Reimbursement item;
  final bool isSelected;
  final bool isMultiSelectActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ClaimListTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isMultiSelectActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final status = ClaimStatus.fromDbKey(item.status);
    final category = ExpenseCategory.fromDbKey(item.category);
    final currencyFmt = NumberFormat.simpleCurrency(name: item.currency);

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: isMultiSelectActive
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.projectCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Text(
              currencyFmt.format(item.amount ?? 0.0),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.particulars.isNotEmpty ? item.particulars : 'No particulars provided',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(item.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                StatusChip(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
