import 'package:flutter/material.dart';
import 'package:reimburse_mate/core/utils/file_picker_service.dart';
import 'package:reimburse_mate/core/widgets/file_attachment_widget.dart';
import 'package:reimburse_mate/models/payment_method.dart';

class PaymentSection extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final PickedFileResult? attachment;
  final VoidCallback onPickPressed;
  final VoidCallback onRemovePressed;

  const PaymentSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.attachment,
    required this.onPickPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requiresProof = selectedMethod.requiresPaymentProof;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method & Proof',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        
        // Method Selector
        LayoutBuilder(
          builder: (context, constraints) {
            return ToggleButtons(
              constraints: BoxConstraints(
                minWidth: (constraints.maxWidth - 5) / 4,
                minHeight: 40,
              ),
              borderRadius: BorderRadius.circular(12),
              isSelected: PaymentMethod.values.map((m) => m == selectedMethod).toList(),
              onPressed: (index) => onMethodChanged(PaymentMethod.values[index]),
              children: PaymentMethod.values.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(m.label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),

        // Conditional Proof Picker
        if (requiresProof) ...[
          Row(
            children: [
              const Text('Payment Receipt', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text(
                '*Required',
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (attachment != null)
            FileAttachmentWidget(
              path: attachment!.path,
              fileType: attachment!.type == CustomFileType.pdf ? 'pdf' : 'image',
              onRemove: onRemovePressed,
              subtitle: 'Payment Proof',
            )
          else
            OutlinedButton.icon(
              onPressed: onPickPressed,
              icon: const Icon(Icons.receipt_rounded),
              label: const Text('Add Payment Proof (UPI/Transaction Screen)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          const Text(
            'Payment Receipt (Optional for cash payments)',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (attachment != null)
            FileAttachmentWidget(
              path: attachment!.path,
              fileType: attachment!.type == CustomFileType.pdf ? 'pdf' : 'image',
              onRemove: onRemovePressed,
              subtitle: 'Cash Payment Receipt',
            )
          else
            OutlinedButton.icon(
              onPressed: onPickPressed,
              icon: const Icon(Icons.receipt_rounded),
              label: const Text('Add Optional Cash Receipt'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ],
    );
  }
}
