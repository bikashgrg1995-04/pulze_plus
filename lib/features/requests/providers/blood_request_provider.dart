import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/network/network_providers.dart';

import '../data/blood_request_repository.dart';
import '../models/accepted_blood_request_detail_model.dart';
import '../models/blood_request_completion_model.dart';
import '../models/blood_request_model.dart';
import '../models/blood_request_response_model.dart';

final bloodRequestRepositoryProvider =
    Provider<BloodRequestRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return BloodRequestRepository(
    apiService: apiService,
  );
});

// ============================================================
// MY BLOOD REQUESTS
// ============================================================

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

  // ----------------------------------------------------------
  // ACCEPT
  // ----------------------------------------------------------

  Future<BloodRequestResponseModel> acceptRequest({
    required int id,
  }) async {
    final response = await _repository.acceptBloodRequest(
      id: id,
    );

    return response;
  }

  // ----------------------------------------------------------
  // DECLINE
  // ----------------------------------------------------------

  Future<BloodRequestResponseModel> declineRequest({
    required int id,
  }) async {
    final response = await _repository.declineBloodRequest(
      id: id,
    );

    return response;
  }

  // ----------------------------------------------------------
  // COMPLETE
  // ----------------------------------------------------------

  Future<BloodRequestCompletionModel> completeRequest({
    required int id,
    required int unitsCompleted,
  }) async {
    final result = await _repository.completeBloodRequest(
      id: id,
      unitsCompleted: unitsCompleted,
    );

    return result;
  }

  // ----------------------------------------------------------
  // CONNECTION
  // ----------------------------------------------------------

  Future<AcceptedBloodRequestDetailModel> getConnection({
    required int id,
  }) async {
    return _repository.getAcceptedBloodRequestConnection(
      id: id,
    );
  }
}

// ============================================================
// GENERAL BLOOD REQUESTS
// ============================================================

final generalBloodRequestsProvider = AsyncNotifierProvider<
    GeneralBloodRequestsNotifier,
    List<BloodRequestModel>>(
  GeneralBloodRequestsNotifier.new,
);

class GeneralBloodRequestsNotifier
    extends AsyncNotifier<List<BloodRequestModel>> {
  BloodRequestRepository get _repository =>
      ref.read(bloodRequestRepositoryProvider);

  @override
  Future<List<BloodRequestModel>> build() async {
    return _repository.getGeneralBloodRequests();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.getGeneralBloodRequests,
    );
  }
}

// ============================================================
// INCOMING DIRECT REQUESTS
// ============================================================

final incomingBloodRequestsProvider = AsyncNotifierProvider<
    IncomingBloodRequestsNotifier,
    List<BloodRequestModel>>(
  IncomingBloodRequestsNotifier.new,
);

class IncomingBloodRequestsNotifier
    extends AsyncNotifier<List<BloodRequestModel>> {
  BloodRequestRepository get _repository =>
      ref.read(bloodRequestRepositoryProvider);

  @override
  Future<List<BloodRequestModel>> build() async {
    return _repository.getIncomingBloodRequests();
  }

  Future<void> refreshRequests() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.getIncomingBloodRequests,
    );
  }
}