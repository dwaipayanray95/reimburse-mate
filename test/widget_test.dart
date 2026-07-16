import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/main.dart';
import 'package:reimburse_mate/core/providers.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ReimburseMateApp(),
      ),
    );

    // Verify that Splash screen title exists
    expect(find.text('Reimburse Mate'), findsOneWidget);

    // Advance the mock clock to bypass the splash screen timer (2500ms)
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
