import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/widgets/glass_card.dart';
import 'subpages/user_info_page.dart';
import 'subpages/filing_defaults_page.dart';
import 'subpages/local_preferences_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Settings List Cards
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                        ),
                        title: const Text('User Information', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${settings.userName} · ${settings.companyName}', style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserInfoPage()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.forward_to_inbox_rounded, color: theme.colorScheme.primary),
                        ),
                        title: const Text('Filing Defaults', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(settings.recipientEmail, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FilingDefaultsPage()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                        ),
                        title: const Text('Local Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Currency: ${settings.defaultCurrency} · Theme: ${settings.themeMode.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocalPreferencesPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version Tag at the Bottom
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Version 1.0.7',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
