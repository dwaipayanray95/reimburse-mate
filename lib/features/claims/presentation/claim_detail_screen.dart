import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/models/claim_status.dart';
import 'package:reimburse_mate/models/expense_category.dart';
import 'package:reimburse_mate/models/payment_method.dart';
import 'package:reimburse_mate/core/widgets/status_chip.dart';
import 'package:pdfrx/pdfrx.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final Reimbursement claim;

  const ClaimDetailScreen({
    super.key,
    required this.claim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFmt = NumberFormat.simpleCurrency(name: claim.currency);
    final category = ExpenseCategory.fromDbKey(claim.category);
    final method = PaymentMethod.fromDbKey(claim.paymentMethod);
    final status = ClaimStatus.fromDbKey(claim.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Claim Details',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<ClaimStatus>(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Change status',
            onSelected: (newStatus) async {
              await ref.read(claimsNotifierProvider.notifier).updateStatus(claim.id, newStatus);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Marked as ${newStatus.label}')),
                );
              }
            },
            itemBuilder: (context) => ClaimStatus.values
                .where((s) => s != status)
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(s.icon, size: 18, color: s.color),
                        const SizedBox(width: 10),
                        Text('Mark as ${s.label}'),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete entry?'),
                  content: const Text('This will permanently delete this claim.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(claimsNotifierProvider.notifier).deleteClaim(claim.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Amount & Project Display
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Text(
                    currencyFmt.format(claim.amount ?? 0.0),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    claim.projectCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  StatusChip(status: status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details List
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildDetailTile(
                    Icons.category_rounded,
                    'Category',
                    category.label,
                  ),
                  const Divider(height: 1),
                  _buildDetailTile(
                    Icons.calendar_today_rounded,
                    'Date',
                    DateFormat('MMMM dd, yyyy').format(claim.date),
                  ),
                  const Divider(height: 1),
                  _buildDetailTile(
                    Icons.description_rounded,
                    'Particulars',
                    claim.particulars.isNotEmpty ? claim.particulars : '—',
                  ),
                  if (claim.note.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailTile(
                      Icons.speaker_notes_rounded,
                      'Notes',
                      claim.note,
                    ),
                  ],
                  const Divider(height: 1),
                  _buildDetailTile(
                    method.icon,
                    'Payment Method',
                    method.label,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attachments Section
          const Text(
            'Attachments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Invoice Attachment
          if (claim.invoicePath != null) ...[
            const Text('Invoice:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildAttachmentViewer(claim.invoicePath!, claim.invoiceFileType == 'pdf'),
            const SizedBox(height: 16),
          ],

          // Payment Proof Attachment
          if (claim.paymentPath != null) ...[
            const Text('Payment Proof:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildAttachmentViewer(claim.paymentPath!, claim.paymentFileType == 'pdf'),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentViewer(String path, bool isPdf) {
    if (!File(path).existsSync()) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.grey),
              SizedBox(height: 6),
              Text('File no longer available', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (isPdf) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x291A1B20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PdfViewer.file(path),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 120,
          color: Colors.grey.withOpacity(0.1),
          child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
        ),
      ),
    );
  }
}
