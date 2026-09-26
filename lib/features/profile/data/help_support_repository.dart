import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/help_support_models.dart';

class HelpSupportRepository {
  HelpSupportRepository({
    required this._apiService,
  });

  final ApiService _apiService;

  Future<List<FAQModel>> getFaqs() async {
    final response = await _apiService.get(
      ApiEndpoints.faqs,
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (json) => FAQModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<SupportRequestModel> contactSupport({
    required String subject,
    required String message,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.contactSupport,
      data: {
        'subject': subject,
        'message': message,
      },
    );

    return SupportRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<SupportRequestModel> reportProblem({
    required String subject,
    required String message,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.reportProblem,
      data: {
        'subject': subject,
        'message': message,
      },
    );

    return SupportRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<SupportRequestModel> submitFeedback({
    required String subject,
    required String message,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.feedback,
      data: {
        'subject': subject,
        'message': message,
      },
    );

    return SupportRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

}