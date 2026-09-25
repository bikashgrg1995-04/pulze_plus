
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/features/profile/data/profile_repository.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';
import 'package:pulze_plus/features/profile/models/profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.read(
      profileRepositoryProvider,
    );

    return const ProfileState.initial();
  }

  Future<ProfileResponseModel> loadProfile() async {
    state = state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
    );

    try {
      final response =
          await _profileRepository.getMe();

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
    String? phoneNumber,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
    );

    try {
      final profile =
          await _profileRepository.createProfile(
        gender: gender,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        bloodType: bloodType,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
      );
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
    String? phoneNumber,
    String? bloodType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
    );

    try {
      final profile =
          await _profileRepository.updateProfile(
        gender: gender,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        bloodType: bloodType,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
      );
    } catch (error) {
      state = ProfileState(
        status: ProfileStatus.error,
        profile: state.profile,
        message: error.toString(),
      );

      rethrow;
    }
  }

  Future<void> updateDonorStatus({
    required bool isDonor,
  }) async {
    final currentProfile = state.profile;

    if (currentProfile == null) {
      throw StateError(
        'Profile is not loaded.',
      );
    }

    state = state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
    );

    try {
      final updatedIsDonor =
          await _profileRepository.updateDonorStatus(
        isDonor: isDonor,
      );

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: currentProfile.copyWith(
          isDonor: updatedIsDonor,
        ),
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

  Future<void> updateAvatar({
    required File avatarFile,
  }) async {
    final currentProfile = state.profile;

    if (currentProfile == null) {
      throw StateError(
        'Profile is not loaded.',
      );
    }

    state = state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
    );

    try {
      final avatarUrl =
          await _profileRepository.updateAvatar(
        avatarFile: avatarFile,
      );

      state = ProfileState(
        status: ProfileStatus.loaded,
        profile: currentProfile.copyWith(
          avatar: avatarUrl,
        ),
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

  void setProfile(ProfileModel profile) {
    state = ProfileState(
      status: ProfileStatus.loaded,
      profile: profile,
    );
  }

  void clearProfile() {
    state = const ProfileState.initial();
  }
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);