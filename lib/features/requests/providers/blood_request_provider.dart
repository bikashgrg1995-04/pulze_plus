import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/network/network_providers.dart';

import '../data/blood_request_repository.dart';
import '../models/blood_request_model.dart';

final bloodRequestRepositoryProvider =
    Provider<BloodRequestRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return BloodRequestRepository(
    apiService: apiService,
  );
});

final bloodRequestsProvider =
    AsyncNotifierProvider<BloodRequestsNotifier, List<BloodRequestModel>>(
  BloodRequestsNotifier.new,
);

class BloodRequestsNotifier
    extends AsyncNotifier<List<BloodRequestModel>> {
  BloodRequestRepository get _repository =>
      ref.read(bloodRequestRepositoryProvider);

  @override
  Future<List<BloodRequestModel>> build() async {
    return _repository.getBloodRequests();
  }

  Future<void> refreshRequests() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.getBloodRequests,
    );
  }

  Future<BloodRequestModel> createRequest({
    required Map<String, dynamic> data,
  }) async {
    final request = await _repository.createBloodRequest(
      data: data,
    );

    final currentRequests = state.maybeWhen(
      data: (requests) => requests,
      orElse: () => const <BloodRequestModel>[],
    );

    state = AsyncData([
      request,
      ...currentRequests,
    ]);

    return request;
  }

  Future<BloodRequestModel> updateRequest({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final updatedRequest = await _repository.updateBloodRequest(
      id: id,
      data: data,
    );

    final currentRequests = state.maybeWhen(
      data: (requests) => requests,
      orElse: () => const <BloodRequestModel>[],
    );

    state = AsyncData(
      currentRequests
          .map(
            (request) =>
                request.id == id ? updatedRequest : request,
          )
          .toList(),
    );

    return updatedRequest;
  }

  Future<void> cancelRequest({
    required int id,
  }) async {
    await _repository.cancelBloodRequest(
      id: id,
    );

    final currentRequests = state.maybeWhen(
      data: (requests) => requests,
      orElse: () => const <BloodRequestModel>[],
    );

    state = AsyncData(
      currentRequests
          .map(
            (request) => request.id == id
                ? request.copyWith(
                    status: 'CANCELLED',
                  )
                : request,
          )
          .toList(),
    );
  }
}