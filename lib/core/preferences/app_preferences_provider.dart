import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_preferences_providers.dart';
import 'app_preferences_storage.dart';

class AppPreferencesState {
  const AppPreferencesState({
    required this.notificationsEnabled,
    required this.donationRemindersEnabled,
    required this.theme,
    required this.language,
    required this.hasCompletedEntry,
  });

  final bool notificationsEnabled;
  final bool donationRemindersEnabled;
  final String theme;
  final String language;
  final bool hasCompletedEntry;

  AppPreferencesState copyWith({
    bool? notificationsEnabled,
    bool? donationRemindersEnabled,
    String? theme,
    String? language,
    bool? hasCompletedEntry,
  }) {
    return AppPreferencesState(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      donationRemindersEnabled:
          donationRemindersEnabled ?? this.donationRemindersEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      hasCompletedEntry:
          hasCompletedEntry ?? this.hasCompletedEntry,
    );
  }
}

class AppPreferencesNotifier
    extends Notifier<AppPreferencesState> {
  late final AppPreferencesStorage _storage;

  @override
  AppPreferencesState build() {
    _storage = ref.read(appPreferencesStorageProvider);

    return AppPreferencesState(
      notificationsEnabled:
          _storage.getNotificationsEnabled(),
      donationRemindersEnabled:
          _storage.getDonationRemindersEnabled(),
      theme: _storage.getTheme(),
      language: _storage.getLanguage(),
      hasCompletedEntry:
          _storage.getHasCompletedEntry(),
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(
      notificationsEnabled: value,
    );

    await _storage.setNotificationsEnabled(value);
  }

  Future<void> setDonationRemindersEnabled(bool value) async {
    state = state.copyWith(
      donationRemindersEnabled: value,
    );

    await _storage.setDonationRemindersEnabled(value);
  }

  Future<void> setTheme(String value) async {
    state = state.copyWith(
      theme: value,
    );

    await _storage.setTheme(value);
  }

  Future<void> setLanguage(String value) async {
    state = state.copyWith(
      language: value,
    );

    await _storage.setLanguage(value);
  }

  Future<void> completeEntry() async {
    state = state.copyWith(
      hasCompletedEntry: true,
    );

    await _storage.setHasCompletedEntry(true);
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferencesState>(
  AppPreferencesNotifier.new,
);