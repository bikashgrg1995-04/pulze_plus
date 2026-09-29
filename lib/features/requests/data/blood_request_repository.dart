import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../models/blood_request_model.dart';

class BloodRequestRepository {
  const BloodRequestRepository({
    required this.apiService,
  });

  final ApiService apiService;

  Future<List<BloodRequestModel>> getBloodRequests() async {
    final response = await apiService.get(
      ApiEndpoints.bloodRequests,
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
      'Invalid blood requests response.',
    );
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
}