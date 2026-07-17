import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _emailController = TextEditingController();
  final _bodyController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  String _currency = 'INR';



  @override
  void dispose() {
    _emailController.dispose();
    _bodyController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateRecipientEmail(_emailController.text.trim());
    await notifier.updateEmailBody(_bodyController.text.trim());
    await notifier.updateUserName(_nameController.text.trim());
    await notifier.updateCompanyName(_companyController.text.trim());
    await notifier.updateDefaultCurrency(_currency);
    await notifier.updateThemeMode(_selectedThemeMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  String _selectedThemeMode = 'system';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _emailController.text = settings.recipientEmail;
    _bodyController.text = settings.emailBody;
    _nameController.text = settings.userName;
    _companyController.text = settings.companyName;
    _currency = settings.defaultCurrency;
    _selectedThemeMode = settings.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Setup Card
          _sectionCard(
            context,
            title: 'User Information',
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _fieldDecoration(context, 'Your Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: _fieldDecoration(context, 'Company / Project Name'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email defaults
          _sectionCard(
            context,
            title: 'Filing Defaults',
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(context, 'Recipient Email Address', hint: 'accounts@company.com'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: _fieldDecoration(context, 'Default Email Body Template'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Local configuration
          _sectionCard(
            context,
            title: 'Local Preferences',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Default Currency'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
                onTap: () {
                  showCurrencyPicker(
                    context: context,
                    onSelect: (Currency currency) {
                      setState(() {
                        _currency = currency.code;
                      });
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Appearance'),
                trailing: _themeToggle(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required List<Widget> children}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          ...children,
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
      fillColor: theme.colorScheme.surface,
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

  Widget _themeToggle(BuildContext context) {
    final theme = Theme.of(context);
    Widget segment(String mode, IconData icon) {
      final isSelected = _selectedThemeMode == mode;
      return InkWell(
        onTap: () async {
          setState(() => _selectedThemeMode = mode);
          await ref.read(settingsProvider.notifier).updateThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('system', Icons.brightness_auto_rounded),
          segment('light', Icons.light_mode_rounded),
          segment('dark', Icons.dark_mode_rounded),
        ],
      ),
    );
  }
}
