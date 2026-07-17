import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:reimburse_mate/core/providers.dart';

class LocalPreferencesPage extends ConsumerStatefulWidget {
  const LocalPreferencesPage({super.key});

  @override
  ConsumerState<LocalPreferencesPage> createState() => _LocalPreferencesPageState();
}

class _LocalPreferencesPageState extends ConsumerState<LocalPreferencesPage> {
  String _currency = 'INR';
  String _selectedThemeMode = 'system';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _currency = settings.defaultCurrency;
    _selectedThemeMode = settings.themeMode;
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateDefaultCurrency(_currency);
    await notifier.updateThemeMode(_selectedThemeMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local preferences saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
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
            'Personalize currency details and display themes here.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Default Currency', style: TextStyle(fontWeight: FontWeight.w600)),
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
            title: const Text('Appearance (Theme)', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: _themeToggle(context),
          ),
        ],
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
        color: theme.brightness == Brightness.light ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
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
