import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/features/settings/data/settings_repository.dart';

class SettingsState {
  final String recipientEmail;
  final String emailBody;
  final String defaultCurrency;
  final String userName;
  final String companyName;
  final String themeMode; // 'system' | 'light' | 'dark'

  SettingsState({
    required this.recipientEmail,
    required this.emailBody,
    required this.defaultCurrency,
    required this.userName,
    required this.companyName,
    required this.themeMode,
  });

  SettingsState copyWith({
    String? recipientEmail,
    String? emailBody,
    String? defaultCurrency,
    String? userName,
    String? companyName,
    String? themeMode,
  }) {
    return SettingsState(
      recipientEmail: recipientEmail ?? this.recipientEmail,
      emailBody: emailBody ?? this.emailBody,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      userName: userName ?? this.userName,
      companyName: companyName ?? this.companyName,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository)
      : super(SettingsState(
          recipientEmail: _repository.recipientEmail,
          emailBody: _repository.emailBody,
          defaultCurrency: _repository.defaultCurrency,
          userName: _repository.userName,
          companyName: _repository.companyName,
          themeMode: _repository.themeMode,
        ));

  Future<void> updateRecipientEmail(String val) async {
    await _repository.setRecipientEmail(val);
    state = state.copyWith(recipientEmail: val);
  }

  Future<void> updateEmailBody(String val) async {
    await _repository.setEmailBody(val);
    state = state.copyWith(emailBody: val);
  }

  Future<void> updateDefaultCurrency(String val) async {
    await _repository.setDefaultCurrency(val);
    state = state.copyWith(defaultCurrency: val);
  }

  Future<void> updateUserName(String val) async {
    await _repository.setUserName(val);
    state = state.copyWith(userName: val);
  }

  Future<void> updateCompanyName(String val) async {
    await _repository.setCompanyName(val);
    state = state.copyWith(companyName: val);
  }

  Future<void> updateThemeMode(String val) async {
    await _repository.setThemeMode(val);
    state = state.copyWith(themeMode: val);
  }
}
