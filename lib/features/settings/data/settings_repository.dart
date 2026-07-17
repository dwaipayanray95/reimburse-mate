import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyEmail = 'settings_recipient_email';
  static const String _keyBody = 'settings_email_body';
  static const String _keyCurrency = 'settings_default_currency';
  static const String _keyName = 'settings_user_name';
  static const String _keyCompany = 'settings_company_name';
  static const String _keyThemeMode = 'settings_theme_mode'; // NEW

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  String get recipientEmail => _prefs.getString(_keyEmail) ?? 'finance@company.com';
  Future<bool> setRecipientEmail(String val) => _prefs.setString(_keyEmail, val);

  String get emailBody => _prefs.getString(_keyBody) ?? 'Please find attached my reimbursement claims.';
  Future<bool> setEmailBody(String val) => _prefs.setString(_keyBody, val);

  String get defaultCurrency => _prefs.getString(_keyCurrency) ?? 'INR';
  Future<bool> setDefaultCurrency(String val) => _prefs.setString(_keyCurrency, val);

  String get userName => _prefs.getString(_keyName) ?? 'Ray';
  Future<bool> setUserName(String val) => _prefs.setString(_keyName, val);

  String get companyName => _prefs.getString(_keyCompany) ?? 'My Company';
  Future<bool> setCompanyName(String val) => _prefs.setString(_keyCompany, val);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system'; // 'system' | 'light' | 'dark'
  Future<bool> setThemeMode(String val) => _prefs.setString(_keyThemeMode, val);
}
