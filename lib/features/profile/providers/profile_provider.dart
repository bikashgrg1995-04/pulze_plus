import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:pulze_plus/core/network/network_providers.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/features/profile/data/profile_repository.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';
import 'package:pulze_plus/features/profile/models/profile_state.dart';
import 'package:pulze_plus/core/location/location_providers.dart';
import 'package:pulze_plus/core/location/location_service.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepository;
  late final LocationService _locationService;

  @override
  ProfileState build() {
    _profileRepository = ref.read(profileRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);

    return const ProfileState.initial();
  }

  Future<ProfileResponseModel> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading, clearMessage: true);

    try {
      final response = await _profileRepository.getMe();

      if (response.profile == null) {
        state = const ProfileState.initial();

        return response;
      }

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: response.profile,
      );

      return response;
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: state.profile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> createProfile({
    required String gender,
    required DateTime dateOfBirth,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading, clearMessage: true);

    try {
      final profile = await _profileRepository.createProfile(
        gender: gender,
        dateOfBirth: dateOfBirth,
        bloodType: bloodType,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );

      state = ProfileState(status: ProfileStatus.loaded, profile: profile);
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: state.profile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> updateProfile({
    String? gender,
    DateTime? dateOfBirth,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading, clearMessage: true);

    try {
      final profile = await _profileRepository.updateProfile(
        gender: gender,
        dateOfBirth: dateOfBirth,
        bloodType: bloodType,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );

      state = ProfileState(status: ProfileStatus.loaded, profile: profile);
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: state.profile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> updateDonorStatus({required bool isDonor}) async {
    final currentProfile = state.profile;

    if (currentProfile == null) {
      throw StateError('Profile is not loaded.');
    }

    state = state.copyWith(status: ProfileStatus.loading, clearMessage: true);

    try {
      if (!isDonor) {
        final updatedIsDonor = await _profileRepository.updateDonorStatus(
          isDonor: false,
        );

        state = ProfileState(
          status: ProfileStatus.loaded,
          profile: currentProfile.copyWith(isDonor: updatedIsDonor),
        );

        return;
      }

      // --------------------------------------------------
      // 1. Location permission/service
      // --------------------------------------------------

      await _locationService.ensurePermission();

      // --------------------------------------------------
      // 2. Current GPS location
      // --------------------------------------------------

      final position = await _locationService.getCurrentPosition();

      // --------------------------------------------------
      // 3. Save donor location
      // --------------------------------------------------

      final updatedProfile = await _profileRepository.updateProfile(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // --------------------------------------------------
      // 4. Enable Pulze+ location setting
      // --------------------------------------------------

      await ref.read(appPreferencesProvider.notifier).setLocationEnabled(true);

      // --------------------------------------------------
      // 5. Activate donor
      // --------------------------------------------------

      final updatedIsDonor = await _profileRepository.updateDonorStatus(
        isDonor: true,
      );

      // --------------------------------------------------
      // 6. Update local state
      // --------------------------------------------------

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: updatedProfile.copyWith(isDonor: updatedIsDonor),
      );
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: currentProfile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> updateAvatar({required File avatarFile}) async {
    final currentProfile = state.profile;

    if (currentProfile == null) {
      throw StateError('Profile is not loaded.');
    }

    state = state.copyWith(status: ProfileStatus.loading, clearMessage: true);

    try {
      final avatarUrl = await _profileRepository.updateAvatar(
        avatarFile: avatarFile,
      );

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: currentProfile.copyWith(avatar: avatarUrl),
      );
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: currentProfile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(clearMessage: true);

    try {
      await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (error) {
      state = state.copyWith(message: error.toString());

      rethrow;
    }
  }

  Future<void> sendPhoneVerification({required String phoneNumber}) async {
    state = state.copyWith(clearMessage: true);

    try {
      await _profileRepository.sendPhoneVerification(
        phoneNumber: phoneNumber,
        purpose: 'PROFILE_PHONE',
      );
    } catch (error) {
      state = state.copyWith(message: error.toString());
      rethrow;
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required String code,
  }) async {
    state = state.copyWith(clearMessage: true);

    try {
      await _profileRepository.verifyPhone(
        phoneNumber: phoneNumber,
        purpose: 'PROFILE_PHONE',
        code: code,
      );

      final currentProfile = state.profile;

      if (currentProfile != null) {
        state = ProfileState(
          status: ProfileStatus.loaded,
          profile: currentProfile.copyWith(
            phoneNumber: phoneNumber,
            isPhoneVerified: true,
          ),
        );
      }
    } catch (error) {
      state = state.copyWith(message: error.toString());
      rethrow;
    }
  }

  Future<void> resendPhoneVerification({required String phoneNumber}) async {
    state = state.copyWith(clearMessage: true);

    try {
      await _profileRepository.resendPhoneVerification(
        phoneNumber: phoneNumber,
        purpose: 'PROFILE_PHONE',
      );
    } catch (error) {
      state = state.copyWith(message: error.toString());
      rethrow;
    }
  }

  Future<Position> getCurrentLocation() async {
    return _locationService.getCurrentPosition();
  }

  Future<void> setLocationEnabled(bool value) async {
    if (!value) {
      await ref.read(appPreferencesProvider.notifier).setLocationEnabled(false);
      return;
    }

    await _locationService.ensurePermission();

    await ref.read(appPreferencesProvider.notifier).setLocationEnabled(true);
  }

  void setProfile(ProfileModel profile) {
    state = ProfileState(status: ProfileStatus.loaded, profile: profile);
  }

  void clearProfile() {
    state = const ProfileState.initial();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(apiService: ref.read(apiServiceProvider));
});

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
