import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/models/claim_status.dart';
import 'package:reimburse_mate/core/widgets/status_chip.dart';

class RecentActivityTile extends StatelessWidget {
  final Reimbursement item;
  final VoidCallback onTap;

  const RecentActivityTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = ClaimStatus.fromDbKey(item.status);
    final currencyFormat = NumberFormat.simpleCurrency(name: item.currency);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.projectCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Text(
            currencyFormat.format(item.amount ?? 0.0),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(item.date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          StatusChip(status: status),
        ],
      ),
    );
  }
}
