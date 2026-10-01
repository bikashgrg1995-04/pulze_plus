
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  AppPreferencesStorage({required this._preferences});

  final SharedPreferences _preferences;

  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _donationRemindersEnabledKey =
      'donation_reminders_enabled';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';
  static const _hasCompletedEntryKey = 'has_completed_entry';

  static const _locationEnabledKey = 'location_enabled';
  static const _hasCompletedLocationSetupKey =
      'has_completed_location_setup';

  bool getNotificationsEnabled() {
    return _preferences.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<bool> setNotificationsEnabled(bool value) {
    return _preferences.setBool(_notificationsEnabledKey, value);
  }

  bool getDonationRemindersEnabled() {
    return _preferences.getBool(_donationRemindersEnabledKey) ?? true;
  }

  Future<bool> setDonationRemindersEnabled(bool value) {
    return _preferences.setBool(_donationRemindersEnabledKey, value);
  }

  String getTheme() {
    return _preferences.getString(_themeKey) ?? 'light';
  }

  Future<bool> setTheme(String value) {
    return _preferences.setString(_themeKey, value);
  }

  String getLanguage() {
    return _preferences.getString(_languageKey) ?? 'english';
  }

  Future<bool> setLanguage(String value) {
    return _preferences.setString(_languageKey, value);
  }

  bool getHasCompletedEntry() {
    return _preferences.getBool(_hasCompletedEntryKey) ?? false;
  }

  Future<bool> setHasCompletedEntry(bool value) {
    return _preferences.setBool(_hasCompletedEntryKey, value);
  }

  bool getLocationEnabled() {
    return _preferences.getBool(_locationEnabledKey) ?? false;
  }

  Future<bool> setLocationEnabled(bool value) {
    return _preferences.setBool(_locationEnabledKey, value);
  }

  bool getHasCompletedLocationSetup() {
    return _preferences.getBool(_hasCompletedLocationSetupKey) ?? false;
  }

  Future<bool> setHasCompletedLocationSetup(bool value) {
    return _preferences.setBool(
      _hasCompletedLocationSetupKey,
      value,
    );
  }
}