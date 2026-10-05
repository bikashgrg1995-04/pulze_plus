import 'package:flutter/foundation.dart';

import 'package:pulze_plus/core/network/api_endpoints.dart';
import 'package:pulze_plus/core/network/api_service.dart';
import 'package:pulze_plus/features/donors/models/donor_model.dart';
import 'package:pulze_plus/features/donors/models/external_donor_model.dart';

class DonorPage {
  const DonorPage({
    required this.results,
    required this.hasNext,
  });

  final List<DonorModel> results;
  final bool hasNext;
}

class ExternalDonorPage {
  const ExternalDonorPage({
    required this.results,
    required this.hasNext,
  });

  final List<ExternalDonorModel> results;
  final bool hasNext;
}

class DonorRepository {
  const DonorRepository({
    required this.apiService,
  });

  final ApiService apiService;

  // ---------------------------------------------------------------------------
  // App Donors
  // ---------------------------------------------------------------------------

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

    debugPrint('');
    debugPrint('========== APP DONORS REQUEST ==========');
    debugPrint('Endpoint: ${ApiEndpoints.donors}');
    debugPrint('Query: $queryParameters');

    try {
      final response = await apiService.get(
        ApiEndpoints.donors,
        queryParameters: queryParameters,
      );

      debugPrint('========== APP DONORS RESPONSE =========');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data type: ${response.data.runtimeType}');
      debugPrint('Response: ${response.data}');
      debugPrint('========================================');

      final data = response.data;

      if (data is List) {
        final donors = data
            .map(
              (item) => DonorModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        debugPrint(
          'App donors parsed successfully: ${donors.length}',
        );

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

        debugPrint(
          'App donors parsed successfully: ${donors.length}',
        );
        debugPrint('Has next: ${data['next'] != null}');

        return DonorPage(
          results: donors,
          hasNext: data['next'] != null,
        );
      }

      debugPrint(
        'APP DONORS PARSE ERROR: Invalid response structure.',
      );

      throw const FormatException(
        'Invalid donors response.',
      );
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('========== APP DONORS ERROR ===========');
      debugPrint('Error type: ${error.runtimeType}');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('========================================');

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // External Donors
  // ---------------------------------------------------------------------------

  Future<ExternalDonorPage> getExternalDonors({
    int page = 1,
    String? search,
    String? bloodType,
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

    debugPrint('');
    debugPrint('======= EXTERNAL DONORS REQUEST =======');
    debugPrint('Endpoint: ${ApiEndpoints.externalDonors}');
    debugPrint('Query: $queryParameters');

    try {
      final response = await apiService.get(
        ApiEndpoints.externalDonors,
        queryParameters: queryParameters,
      );

      debugPrint('======= EXTERNAL DONORS RESPONSE ======');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data type: ${response.data.runtimeType}');
      debugPrint('Response: ${response.data}');
      debugPrint('========================================');

      final data = response.data;

      if (data is List) {
        final donors = data
            .map(
              (item) => ExternalDonorModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        debugPrint(
          'External donors parsed successfully: ${donors.length}',
        );

        return ExternalDonorPage(
          results: donors,
          hasNext: false,
        );
      }

      if (data is Map && data['results'] is List) {
        final donors = (data['results'] as List)
            .map(
              (item) => ExternalDonorModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        debugPrint(
          'External donors parsed successfully: ${donors.length}',
        );
        debugPrint('Has next: ${data['next'] != null}');

        return ExternalDonorPage(
          results: donors,
          hasNext: data['next'] != null,
        );
      }

      debugPrint(
        'EXTERNAL DONORS PARSE ERROR: Invalid response structure.',
      );

      throw const FormatException(
        'Invalid external donors response.',
      );
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('======= EXTERNAL DONORS ERROR =========');
      debugPrint('Error type: ${error.runtimeType}');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('========================================');

      rethrow;
    }
  }
}