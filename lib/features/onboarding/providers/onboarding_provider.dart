import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, int>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<int> {
  static const _completedKey = 'onboarding_completed';

  @override
  int build() {
    return 0;
  }

  void setPage(int index) {
    state = index;
  }

  Future<void> complete() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(
      _completedKey,
      true,
    );
  }

  Future<bool> isCompleted() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_completedKey) ?? false;
  }
}