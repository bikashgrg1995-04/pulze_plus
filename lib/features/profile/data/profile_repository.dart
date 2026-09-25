
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:pulze_plus/core/network/api_endpoints.dart';
import 'package:pulze_plus/core/network/api_service.dart';
import 'package:pulze_plus/features/auth/models/user_model.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';

class ProfileRepository {
  ProfileRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<ProfileResponseModel> getMe() async {
    final response = await _apiService.get(
      ApiEndpoints.me,
    );

    return ProfileResponseModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<ProfileModel> createProfile({
    required String gender,
    required DateTime dateOfBirth,
    String? phoneNumber,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.profile,
      data: {
        'gender': gender,
        'date_of_birth': _formatDate(dateOfBirth),
        'phone_number': phoneNumber,
        'blood_type': bloodType,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data,
    );

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(
        data['profile'] as Map,
      ),
    );
  }

  Future<ProfileModel> updateProfile({
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{};

    if (gender != null) {
      data['gender'] = gender;
    }

    if (dateOfBirth != null) {
      data['date_of_birth'] =
          _formatDate(dateOfBirth);
    }

    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }

    if (bloodType != null) {
      data['blood_type'] = bloodType;
    }

    if (address != null) {
      data['address'] = address;
    }

    if (city != null) {
      data['city'] = city;
    }

    if (latitude != null) {
      data['latitude'] = latitude;
    }

    if (longitude != null) {
      data['longitude'] = longitude;
    }

    final response = await _apiService.patch(
      ApiEndpoints.profile,
      data: data,
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(
        responseData['profile'] as Map,
      ),
    );
  }

  Future<bool> updateDonorStatus({
    required bool isDonor,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.profileDonor,
      data: {
        'is_donor': isDonor,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data,
    );

    return data['is_donor'] as bool;
  }

  Future<String> updateAvatar({
    required File avatarFile,
  }) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        avatarFile.path,
        filename: avatarFile.path.split('/').last,
      ),
    });

    final response = await _apiService.patch(
      ApiEndpoints.profileAvatar,
      data: formData,
    );

    final data = Map<String, dynamic>.from(
      response.data,
    );

    return data['avatar'] as String;
  }

  static String _formatDate(DateTime date) {
    final year =
        date.year.toString().padLeft(4, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class ProfileResponseModel {
  const ProfileResponseModel({
    required this.user,
    this.profile,
  });

  final UserModel user;
  final ProfileModel? profile;

  factory ProfileResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final profileData =
        json['profile'] as Map?;

    return ProfileResponseModel(
      user: UserModel.fromJson(
        Map<String, dynamic>.from(
          json['user'] as Map,
        ),
      ),
      profile: profileData == null
          ? null
          : ProfileModel.fromJson(
              Map<String, dynamic>.from(
                profileData,
              ),
            ),
    );
  }
}