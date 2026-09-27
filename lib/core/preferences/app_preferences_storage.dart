import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  AppPreferencesStorage({
    required this._preferences,
  });

  final SharedPreferences _preferences;

  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _donationRemindersEnabledKey =
      'donation_reminders_enabled';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';

  bool getNotificationsEnabled() {
    return _preferences.getBool(
          _notificationsEnabledKey,
        ) ??
        true;
  }

  Future<bool> setNotificationsEnabled(bool value) {
    return _preferences.setBool(
      _notificationsEnabledKey,
      value,
    );
  }

  bool getDonationRemindersEnabled() {
    return _preferences.getBool(
          _donationRemindersEnabledKey,
        ) ??
        true;
  }

  Future<bool> setDonationRemindersEnabled(bool value) {
    return _preferences.setBool(
      _donationRemindersEnabledKey,
      value,
    );
  }

  String getTheme() {
    return _preferences.getString(
          _themeKey,
        ) ??
        'light';
  }

  Future<bool> setTheme(String value) {
    return _preferences.setString(
      _themeKey,
      value,
    );
  }

  String getLanguage() {
    return _preferences.getString(
          _languageKey,
        ) ??
        'english';
  }

  Future<bool> setLanguage(String value) {
    return _preferences.setString(
      _languageKey,
      value,
    );
  }
}