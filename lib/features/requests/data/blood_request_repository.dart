import 'package:pulze_plus/features/requests/models/accepted_blood_request_detail_model.dart';
import 'package:pulze_plus/features/requests/models/blood_request_completion_model.dart';
import 'package:pulze_plus/features/requests/models/blood_request_response_model.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../models/blood_request_model.dart';

class BloodRequestRepository {
  const BloodRequestRepository({required this.apiService});

  final ApiService apiService;

  Future<List<BloodRequestModel>> getBloodRequests() async {
    final response = await apiService.get(ApiEndpoints.bloodRequests);

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw const FormatException('Invalid blood requests response.');
  }

  Future<BloodRequestModel> getBloodRequest({
    required int id,
  }) async {
    final response = await apiService.get(
      '${ApiEndpoints.bloodRequests}$id/',
    );

    return BloodRequestModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<BloodRequestModel> createBloodRequest({
    required Map<String, dynamic> data,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.bloodRequests,
      data: data,
    );

    return BloodRequestModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<BloodRequestModel> updateBloodRequest({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await apiService.patch(
      '${ApiEndpoints.bloodRequests}$id/',
      data: data,
    );

    return BloodRequestModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> cancelBloodRequest({
    required int id,
  }) async {
    await apiService.delete(
      '${ApiEndpoints.bloodRequests}$id/',
    );
  }

  Future<List<BloodRequestModel>> getGeneralBloodRequests() async {
    final response = await apiService.get(
      '${ApiEndpoints.bloodRequests}general/',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw const FormatException(
      'Invalid general blood requests response.',
    );
  }

  Future<List<BloodRequestModel>> getIncomingBloodRequests() async {
    final response = await apiService.get(
      '${ApiEndpoints.bloodRequests}incoming/',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map(
            (item) => BloodRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw const FormatException(
      'Invalid incoming blood requests response.',
    );
  }

  Future<BloodRequestResponseModel> acceptBloodRequest({
    required int id,
  }) async {
    final response = await apiService.post(
      '${ApiEndpoints.bloodRequests}$id/accept/',
    );

    return BloodRequestResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<BloodRequestResponseModel> declineBloodRequest({
    required int id,
  }) async {
    final response = await apiService.post(
      '${ApiEndpoints.bloodRequests}$id/decline/',
    );

    return BloodRequestResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<BloodRequestCompletionModel> completeBloodRequest({
    required int id,
    required int unitsCompleted,
  }) async {
    final response = await apiService.post(
      '${ApiEndpoints.bloodRequests}$id/complete/',
      data: {
        'units_completed': unitsCompleted,
      },
    );

    return BloodRequestCompletionModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AcceptedBloodRequestDetailModel>
      getAcceptedBloodRequestConnection({
    required int id,
  }) async {
    final response = await apiService.get(
      '${ApiEndpoints.bloodRequests}$id/connection/',
    );

    return AcceptedBloodRequestDetailModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}