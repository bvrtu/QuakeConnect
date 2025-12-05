import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static final SettingsRepository instance = SettingsRepository._();
  SettingsRepository._();

  // Default values
  bool _pushNotifications = true;
  double _minMagnitude = 4.0;
  bool _nearbyAlerts = true;
  bool _communityUpdates = true;
  bool _locationServices = true;
  
  // State Notifiers
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  // Getters
  bool get pushNotifications => _pushNotifications;
  double get minMagnitude => _minMagnitude;
  bool get nearbyAlerts => _nearbyAlerts;
  bool get communityUpdates => _communityUpdates;
  bool get locationServices => _locationServices;

  // Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _minMagnitude = prefs.getDouble('min_magnitude') ?? 4.0;
    _nearbyAlerts = prefs.getBool('nearby_alerts') ?? true;
    _communityUpdates = prefs.getBool('community_updates') ?? true;
    _locationServices = prefs.getBool('location_services') ?? true;
    
    // Load Theme
    final isDark = prefs.getBool('is_dark_mode');
    if (isDark == null) {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    
    // Load Language
    final langCode = prefs.getString('language_code') ?? 'en';
    locale.value = Locale(langCode);
  }

  // Save settings to SharedPreferences
  Future<void> saveThemeMode(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
  
  Future<void> saveLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  Future<void> savePushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
  }

  Future<void> saveMinMagnitude(double value) async {
    _minMagnitude = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('min_magnitude', value);
  }

  Future<void> saveNearbyAlerts(bool value) async {
    _nearbyAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nearby_alerts', value);
  }

  Future<void> saveCommunityUpdates(bool value) async {
    _communityUpdates = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('community_updates', value);
  }

  Future<void> saveLocationServices(bool value) async {
    _locationServices = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_services', value);
  }
}

