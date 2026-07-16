import 'package:flutter/material.dart';
import 'package:reimburse_mate/models/ocr_result.dart';

class OcrResultBanner extends StatelessWidget {
  final OcrResult result;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const OcrResultBanner({
    super.key,
    required this.result,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'OCR Scan Completed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (result.amount != null)
            Text(
              'Amount detected: ${result.currencyCode ?? '₹'} ${result.amount!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13),
            ),
          if (result.vendor != null)
            Text(
              'Merchant detected: ${result.vendor}',
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onApply,
                child: const Text('Apply Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
