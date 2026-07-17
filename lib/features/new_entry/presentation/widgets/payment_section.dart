import 'package:flutter/material.dart';
import 'package:reimburse_mate/core/utils/file_picker_service.dart';
import 'package:reimburse_mate/core/widgets/file_attachment_widget.dart';
import 'package:reimburse_mate/core/widgets/dashed_border_painter.dart';
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
        
        // Method Selector — 4 equal-width segmented buttons
        Row(
          children: PaymentMethod.values.map((m) {
            final isSelected = m == selectedMethod;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: InkWell(
                  onTap: () => onMethodChanged(m),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(m.icon, size: 16, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                        const SizedBox(height: 4),
                        Text(
                          m.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
            DashedDropZone(
              onTap: onPickPressed,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_rounded, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Add Payment Proof (UPI/Transaction Screen)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
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
            DashedDropZone(
              onTap: onPickPressed,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_rounded, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Add Optional Cash Receipt',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
