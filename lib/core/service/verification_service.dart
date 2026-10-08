import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// Thrown with a message that is safe to show directly to the user.
class VerificationException implements Exception {
  final String message;
  const VerificationException(this.message);
  @override
  String toString() => message;
}

/// Handles the two things a policy can demand at check-in: where you are
/// (location) and who you are (selfie).
class VerificationService {
  final ImagePicker _picker = ImagePicker();

  Future<Position> getCurrentLocation() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      throw const VerificationException(
          'Please turn on your phone\'s location (GPS) and try again.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const VerificationException(
          'Location permission is needed to check in. Please allow it and try again.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const VerificationException(
          'Location permission is blocked. Please enable it for Placfy in your phone settings.');
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      debugPrint(
          '📍 [Verification] lat=${pos.latitude} lng=${pos.longitude} accuracy=${pos.accuracy}m mocked=${pos.isMocked}');
      if (pos.isMocked) {
        throw const VerificationException(
            'Fake location detected. Please turn off any mock-location app and try again.');
      }
      return pos;
    } on TimeoutException {
      throw const VerificationException(
          'Could not get your location. Please move to an open area and try again.');
    }
  }

  double distanceMeters(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Opens the front camera and returns the file path of the selfie.
  Future<String> captureSelfie() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (file == null) {
        throw const VerificationException(
            'A selfie is required to check in. Please try again.');
      }
      debugPrint('🤳 [Verification] selfie captured: ${file.path}');
      return file.path;
    } on VerificationException {
      rethrow;
    } catch (e) {
      debugPrint('🤳 [Verification] camera error: $e');
      throw const VerificationException(
          'Could not open the camera. Please allow camera access and try again.');
    }
  }
}