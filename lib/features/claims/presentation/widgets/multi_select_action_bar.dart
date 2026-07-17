import 'package:flutter/material.dart';

class MultiSelectActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onFileClaims;
  final VoidCallback onBatchDelete;
  final VoidCallback onClear;

  const MultiSelectActionBar({
    super.key,
    required this.count,
    required this.onFileClaims,
    required this.onBatchDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onClear,
          ),
          const SizedBox(width: 8),
          Text(
            '$count Selected',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: onBatchDelete,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onFileClaims,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('File Claims'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
