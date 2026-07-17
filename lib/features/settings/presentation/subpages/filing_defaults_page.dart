import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';

class FilingDefaultsPage extends ConsumerStatefulWidget {
  const FilingDefaultsPage({super.key});

  @override
  ConsumerState<FilingDefaultsPage> createState() => _FilingDefaultsPageState();
}

class _FilingDefaultsPageState extends ConsumerState<FilingDefaultsPage> {
  final _emailController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _emailController.text = settings.recipientEmail;
    _bodyController.text = settings.emailBody;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateRecipientEmail(_emailController.text.trim());
    await notifier.updateEmailBody(_bodyController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filing defaults updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filing Defaults', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Configure default variables to speed up claim emailing workflows.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecoration(context, 'Recipient Email Address', hint: 'accounts@company.com'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bodyController,
            maxLines: 6,
            decoration: _fieldDecoration(context, 'Default Email Body Template'),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label, {String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.brightness == Brightness.light ? Colors.white : const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }
}
