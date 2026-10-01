import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope.',
  );
});

final appPreferencesStorageProvider = Provider<AppPreferencesStorage>((ref) {
  return AppPreferencesStorage(
    preferences: ref.read(sharedPreferencesProvider),
  );
});
