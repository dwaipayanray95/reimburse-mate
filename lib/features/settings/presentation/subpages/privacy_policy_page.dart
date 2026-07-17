import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = rootBundle.loadString('docs/PRIVACY_POLICY.md');
  }

  Future<void> _openLink(String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(20),
            onTapLink: (text, href, title) {
              if (href != null) _openLink(href);
            },
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              p: theme.textTheme.bodyMedium,
              a: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
              code: theme.textTheme.bodySmall?.copyWith(
                backgroundColor: theme.colorScheme.surfaceContainer,
                fontFamily: 'monospace',
              ),
            ),
          );
        },
      ),
    );
  }
}
