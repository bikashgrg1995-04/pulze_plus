import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }

    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    return granted;
  }

  Future<Position> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));

      return position;
    } on Exception catch (_) {
      rethrow;
    }
  }
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();

  @override
  String toString() {
    return 'Location services are disabled.';
  }
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() {
    return 'Location permission was denied.';
  }
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  const LocationPermissionPermanentlyDeniedException();

  @override
  String toString() {
    return 'Location permission was permanently denied.';
  }
}
