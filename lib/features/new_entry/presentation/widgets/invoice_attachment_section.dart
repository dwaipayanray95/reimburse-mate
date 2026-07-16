import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reimburse_mate/core/utils/file_picker_service.dart';
import 'package:reimburse_mate/core/widgets/file_attachment_widget.dart';

class InvoiceAttachmentSection extends StatelessWidget {
  final PickedFileResult? attachment;
  final VoidCallback onPickPressed;
  final VoidCallback onRemovePressed;

  const InvoiceAttachmentSection({
    super.key,
    required this.attachment,
    required this.onPickPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Invoice Attachment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              '*Required',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attachment != null)
          FileAttachmentWidget(
            path: attachment!.path,
            fileType: attachment!.type == CustomFileType.pdf ? 'pdf' : 'image',
            onRemove: onRemovePressed,
            subtitle: attachment!.type == CustomFileType.pdf ? 'PDF Invoice' : 'Image Invoice',
          )
        else
          InkWell(
            onTap: onPickPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Attach Invoice (Photo or PDF)',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
