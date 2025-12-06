import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import '../services/auth_service.dart';

class SettingsRepository {
  static final SettingsRepository instance = SettingsRepository._();
  SettingsRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Default values
  bool _pushNotifications = true;
  double _minMagnitude = 4.0;
  bool _nearbyAlerts = true;
  bool _communityUpdates = true;
  bool _locationServices = true;
  
  // State Notifiers
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));
  
  String? _currentUserId;

  // Getters
  bool get pushNotifications => _pushNotifications;
  double get minMagnitude => _minMagnitude;
  bool get nearbyAlerts => _nearbyAlerts;
  bool get communityUpdates => _communityUpdates;
  bool get locationServices => _locationServices;

  // Get default locale based on device language
  Locale _getDefaultLocale() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final languageCode = deviceLocale.languageCode.toLowerCase();
    if (languageCode == 'tr') {
      return const Locale('tr');
    } else if (languageCode == 'en') {
      return const Locale('en');
    } else {
      return const Locale('en'); // Default to English for other languages
    }
  }

  // Get default theme mode based on device theme
  ThemeMode _getDefaultThemeMode() {
    final brightness = ui.PlatformDispatcher.instance.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  // Initialize settings from Firestore (user-specific)
  Future<void> loadSettings() async {
    _currentUserId = AuthService.instance.currentUserId;
    
    if (_currentUserId == null) {
      // No user logged in, use defaults
      _setDefaults();
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _pushNotifications = data['push_notifications'] as bool? ?? true;
        _minMagnitude = (data['min_magnitude'] as num?)?.toDouble() ?? 4.0;
        _nearbyAlerts = data['nearby_alerts'] as bool? ?? true;
        _communityUpdates = data['community_updates'] as bool? ?? true;
        _locationServices = data['location_services'] as bool? ?? true;
        
        // Load Theme
        final themeStr = data['theme_mode'] as String?;
        if (themeStr == null) {
          themeMode.value = _getDefaultThemeMode();
        } else {
          switch (themeStr) {
            case 'dark':
              themeMode.value = ThemeMode.dark;
              break;
            case 'light':
              themeMode.value = ThemeMode.light;
              break;
            default:
              themeMode.value = ThemeMode.system;
          }
        }
        
        // Load Language
        final langCode = data['language_code'] as String?;
        if (langCode == null) {
          locale.value = _getDefaultLocale();
        } else {
          locale.value = Locale(langCode);
        }
      } else {
        // First time user, set defaults based on device
        _setDefaults();
        await _saveAllSettings(); // Save defaults to Firestore
      }
    } catch (e) {
      // Error loading, use defaults
      _setDefaults();
    }
  }

  void _setDefaults() {
    _pushNotifications = true;
    _minMagnitude = 4.0;
    _nearbyAlerts = true;
    _communityUpdates = true;
    _locationServices = true;
    themeMode.value = _getDefaultThemeMode();
    locale.value = _getDefaultLocale();
  }

  Future<void> _saveAllSettings() async {
    if (_currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'push_notifications': _pushNotifications,
        'min_magnitude': _minMagnitude,
        'nearby_alerts': _nearbyAlerts,
        'community_updates': _communityUpdates,
        'location_services': _locationServices,
        'theme_mode': themeMode.value == ThemeMode.dark 
            ? 'dark' 
            : (themeMode.value == ThemeMode.light ? 'light' : 'system'),
        'language_code': locale.value.languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }

  // Update current user ID when auth state changes
  void updateUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null) {
        loadSettings(); // Reload settings for new user
      } else {
        _setDefaults(); // Reset to defaults when logged out
      }
    }
  }

  // Save settings to Firestore
  Future<void> saveThemeMode(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'theme_mode': isDark ? 'dark' : 'light',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
  
  Future<void> saveLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'language_code': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> savePushNotifications(bool value) async {
    _pushNotifications = value;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'push_notifications': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveMinMagnitude(double value) async {
    _minMagnitude = value;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'min_magnitude': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveNearbyAlerts(bool value) async {
    _nearbyAlerts = value;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'nearby_alerts': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveCommunityUpdates(bool value) async {
    _communityUpdates = value;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'community_updates': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveLocationServices(bool value) async {
    _locationServices = value;
    if (_currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set({
        'location_services': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}

