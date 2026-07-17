import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/features/filing/application/filing_notifier.dart';

class FileClaimsScreen extends ConsumerStatefulWidget {
  final List<Reimbursement> claims;

  const FileClaimsScreen({
    super.key,
    required this.claims,
  });

  @override
  ConsumerState<FileClaimsScreen> createState() => _FileClaimsScreenState();
}

class _FileClaimsScreenState extends ConsumerState<FileClaimsScreen> {
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _attachZip = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      
      final totalAmount = widget.claims.fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0));
      final formatter = NumberFormat.simpleCurrency(name: settings.defaultCurrency);
      
      _emailController.text = settings.recipientEmail;
      _subjectController.text = 'Reimbursement Claims (${widget.claims.length} items) - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      
      // Auto compile itemized body list
      var claimRowsText = '';
      for (final c in widget.claims) {
        claimRowsText += '• ${c.projectCode} - ${c.particulars}: ${formatter.format(c.amount ?? 0.0)}\n';
      }

      _bodyController.text = '${settings.emailBody}\n\nSummary of Claims:\n$claimRowsText\nTotal Amount: ${formatter.format(totalAmount)}\n\nBest Regards,\n${settings.userName}';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _triggerFiling(bool exportOnly) async {
    await ref.read(filingNotifierProvider.notifier).fileClaims(
          claims: widget.claims,
          recipient: _emailController.text.trim(),
          body: _bodyController.text,
          subject: _subjectController.text.trim(),
          attachZip: _attachZip,
          exportOnly: exportOnly,
        );

    final filingState = ref.read(filingNotifierProvider);
    if (filingState.status == FilingStateStatus.completed) {
      if (mounted) {
        final missing = filingState.missingAttachmentCount;
        final message = exportOnly
            ? (missing > 0
                ? 'ZIP saved, but $missing attachment(s) were missing and skipped.'
                : 'ZIP saved successfully.')
            : (missing > 0
                ? 'Claims filed, but $missing attachment(s) were missing and skipped.'
                : 'Claims successfully processed and status updated.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context);
      }
    } else if (filingState.status == FilingStateStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Filing Error: ${filingState.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filingState = ref.watch(filingNotifierProvider);
    final isBusy = filingState.status == FilingStateStatus.generating ||
        filingState.status == FilingStateStatus.launching;

    final totalVal = widget.claims.fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0));
    final defaultCurrency = ref.watch(settingsProvider).defaultCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Claims', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isBusy
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing claims and packages...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Claim aggregation summary card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Aggregate Claims Size',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.simpleCurrency(name: defaultCurrency).format(totalVal),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.claims.length} claims selected for filing',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields (read-only-styled, surface-container fill)
                TextFormField(
                  controller: _emailController,
                  decoration: _fieldDecoration(context, 'Recipient Email Address'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  decoration: _fieldDecoration(context, 'Email Subject'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 8,
                  decoration: _fieldDecoration(context, 'Email Body Template'),
                ),
                const SizedBox(height: 16),

                // Attachments config switch
                SwitchListTile(
                  title: const Text('Compress and attach receipts ZIP package'),
                  subtitle: const Text('Includes receipt scans along with the tabular CSV file'),
                  value: _attachZip,
                  onChanged: (val) {
                    setState(() {
                      _attachZip = val;
                    });
                  },
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Action controls
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _triggerFiling(true),
                        icon: const Icon(Icons.folder_zip_rounded),
                        label: const Text('Save ZIP'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _triggerFiling(false),
                        icon: const Icon(Icons.mail_rounded),
                        label: const Text('Send via Mail'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }
}
