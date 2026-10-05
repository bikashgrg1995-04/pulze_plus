import 'package:flutter/foundation.dart';

import 'blood_request_response_model.dart';

@immutable
class BloodRequestCompletionModel {
  const BloodRequestCompletionModel({
    required this.response,
    required this.unitsFulfilled,
    required this.unitsRemaining,
    required this.requestStatus,
  });

  final BloodRequestResponseModel response;
  final int unitsFulfilled;
  final int unitsRemaining;
  final String requestStatus;

  bool get isFulfilled =>
      requestStatus == 'FULFILLED';

  factory BloodRequestCompletionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BloodRequestCompletionModel(
      response:
          BloodRequestResponseModel.fromJson(
        Map<String, dynamic>.from(
          json['response'] as Map,
        ),
      ),
      unitsFulfilled:
          _parseInt(json['units_fulfilled']),
      unitsRemaining:
          _parseInt(json['units_remaining']),
      requestStatus:
          json['request_status']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}