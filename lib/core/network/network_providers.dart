import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';
import 'dio_client.dart';
import 'token_storage.dart';

class SessionExpirySignal extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void notifySessionExpired() {
    state++;
  }
}

final sessionExpirySignalProvider = NotifierProvider<SessionExpirySignal, int>(
  SessionExpirySignal.new,
);

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    tokenStorage: ref.read(tokenStorageProvider),
    onSessionExpired: () {
      ref.read(sessionExpirySignalProvider.notifier).notifySessionExpired();
    },
  );
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(dioClient: ref.read(dioClientProvider));
});
