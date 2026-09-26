
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';

import 'package:pulze_plus/features/auth/providers/auth_provider.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.status == next.status) {
          return;
        }

        notifyListeners();
      },
    );
  }
}