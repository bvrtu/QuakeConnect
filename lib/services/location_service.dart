import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/settings_repository.dart';

class LocationService {
  static Position? _currentPosition;
  static DateTime? _lastLocationUpdate;
  static const Duration _locationCacheDuration = Duration(minutes: 5);

  /// Get current user location
  /// Returns null if permission denied or location services disabled
  static Future<Position?> getCurrentLocation() async {
    // Check if location services are enabled in settings
    if (!SettingsRepository.instance.locationServices) {
      print('LocationService: Location services disabled in settings');
      return null;
    }

    // Check if we have a cached location that's still valid
    if (_currentPosition != null && _lastLocationUpdate != null) {
      final age = DateTime.now().difference(_lastLocationUpdate!);
      if (age < _locationCacheDuration) {
        print('LocationService: Using cached location');
        return _currentPosition;
      }
    }

    try {
      // Check if location services are enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationService: Location services disabled on device');
        return null;
      }

      // Check location permission
      final permission = await Permission.location.status;
      print('LocationService: Permission status: $permission');
      
      if (!permission.isGranted) {
        if (permission.isDenied) {
          print('LocationService: Requesting location permission...');
          final result = await Permission.location.request();
          print('LocationService: Permission request result: $result');
          if (!result.isGranted) {
            print('LocationService: Permission denied or permanently denied');
            return null;
          }
        } else if (permission.isPermanentlyDenied) {
          print('LocationService: Permission permanently denied');
          return null;
        } else {
          print('LocationService: Permission in unknown state: $permission');
          return null;
        }
      }

      print('LocationService: Getting current position...');
      // Get current position
      // Try with high accuracy first, then fall back to lower accuracy
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        _lastLocationUpdate = DateTime.now();
        print('LocationService: Location obtained (high accuracy): ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
        return _currentPosition;
      } catch (e) {
        print('LocationService: High accuracy failed, trying low accuracy...');
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 10),
          );
          _lastLocationUpdate = DateTime.now();
          print('LocationService: Location obtained (low accuracy): ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
          return _currentPosition;
        } catch (e2) {
          print('LocationService: Low accuracy also failed, trying lowest...');
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest,
            timeLimit: const Duration(seconds: 10),
          );
          _lastLocationUpdate = DateTime.now();
          print('LocationService: Location obtained (lowest accuracy): ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
          return _currentPosition;
        }
      }
    } catch (e) {
      print('LocationService: Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0; // Convert to km
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission.isGranted;
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Clear cached location when location services are disabled
  static void clearCache() {
    _currentPosition = null;
    _lastLocationUpdate = null;
    print('LocationService: Cache cleared');
  }
}

