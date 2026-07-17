import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/features/claims/data/claims_repository.dart';
import 'package:reimburse_mate/features/claims/application/claims_notifier.dart';
import 'package:reimburse_mate/features/claims/application/multi_select_notifier.dart';
import 'package:reimburse_mate/features/claims/application/filter_notifier.dart';
import 'package:reimburse_mate/features/dashboard/application/dashboard_notifier.dart';
import 'package:reimburse_mate/features/new_entry/application/entry_notifier.dart';
import 'package:reimburse_mate/features/ocr/data/ocr_service.dart';
import 'package:reimburse_mate/features/ocr/application/ocr_notifier.dart';
import 'package:reimburse_mate/features/filing/data/zip_export_service.dart';
import 'package:reimburse_mate/features/filing/data/email_service.dart';
import 'package:reimburse_mate/features/filing/application/filing_notifier.dart';
import 'package:reimburse_mate/features/settings/data/settings_repository.dart';
import 'package:reimburse_mate/features/settings/application/settings_notifier.dart';

// SharedPreferences provider (must be overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Settings Repository & Notifier
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

// Claims Repository & Notifier
final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ClaimsRepository(db);
});

final claimsNotifierProvider = StateNotifierProvider<ClaimsNotifier, AsyncValue<List<Reimbursement>>>((ref) {
  final repo = ref.watch(claimsRepositoryProvider);
  return ClaimsNotifier(repo);
});

// Filters & MultiSelect
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

final multiSelectProvider = StateNotifierProvider<MultiSelectNotifier, MultiSelectState>((ref) {
  return MultiSelectNotifier();
});

// Dashboard
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardStats>((ref) {
  final notifier = DashboardNotifier();
  // Listen to claims to update stats dynamically
  ref.listen<AsyncValue<List<Reimbursement>>>(claimsNotifierProvider, (_, next) {
    next.whenData((claims) => notifier.updateStats(claims));
  });
  return notifier;
});

// OCR
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

final ocrNotifierProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final service = ref.watch(ocrServiceProvider);
  return OcrNotifier(service);
});

// Filing
final zipExportServiceProvider = Provider<ZipExportService>((ref) {
  return ZipExportService();
});

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

final filingNotifierProvider = StateNotifierProvider<FilingNotifier, FilingState>((ref) {
  final zip = ref.watch(zipExportServiceProvider);
  final email = ref.watch(emailServiceProvider);
  final claims = ref.watch(claimsNotifierProvider.notifier);
  return FilingNotifier(zip, email, claims);
});

// Entry
final entryNotifierProvider = StateNotifierProvider<EntryNotifier, EntrySaveState>((ref) {
  final repo = ref.watch(claimsRepositoryProvider);
  return EntryNotifier(repo);
});
