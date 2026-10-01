import 'package:pulze_plus/core/network/api_endpoints.dart';
import 'package:pulze_plus/core/network/api_service.dart';
import 'package:pulze_plus/features/requests/models/donor_model.dart';

class DonorPage {
  const DonorPage({
    required this.results,
    required this.hasNext,
  });

  final List<DonorModel> results;
  final bool hasNext;
}

class DonorRepository {
  const DonorRepository({
    required this.apiService,
  });

  final ApiService apiService;

  Future<DonorPage> getDonors({
    int page = 1,
    String? search,
    String? bloodType,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (bloodType != null && bloodType.isNotEmpty) {
      queryParameters['blood_type'] = bloodType;
    }

    if (latitude != null) {
      queryParameters['latitude'] = latitude;
    }

    if (longitude != null) {
      queryParameters['longitude'] = longitude;
    }

    if (radius != null) {
      queryParameters['radius'] = radius;
    }

    final response = await apiService.get(
      ApiEndpoints.donors,
      queryParameters: queryParameters,
    );

    final data = response.data;

    if (data is List) {
      final donors = data
          .map(
            (item) => DonorModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      return DonorPage(
        results: donors,
        hasNext: false,
      );
    }

    if (data is Map && data['results'] is List) {
      final donors = (data['results'] as List)
          .map(
            (item) => DonorModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      return DonorPage(
        results: donors,
        hasNext: data['next'] != null,
      );
    }

    throw const FormatException(
      'Invalid donors response.',
    );
  }
}
