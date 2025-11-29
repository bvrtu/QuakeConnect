import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/notification_model.dart';
import '../models/earthquake.dart';
import '../services/earthquake_api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../data/settings_repository.dart';
import '../l10n/app_localizations.dart';

class NotificationRepository {
  static final NotificationRepository instance = NotificationRepository._();
  NotificationRepository._() {
    _items = [];
    _loadNotificationsFromAPI();
  }

  List<NotificationModel> _items = [];
  bool _isLoading = false;
  final Set<String> _deletedIds = {}; // Track deleted notification IDs
  final Set<String> _shownNotificationIds = {}; // Track which notifications were already shown on phone

  List<NotificationModel> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> _loadNotificationsFromAPI() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final earthquakes = await EarthquakeApiService.fetchRecentEarthquakes(limit: 100);
      final settings = SettingsRepository.instance;
      
      // Get user location if location services are enabled
      Position? userLocation;
      double? calculatedDistance;
      if (settings.locationServices) {
        userLocation = await LocationService.getCurrentLocation();
      }
      
      // Create notifications from real earthquake data
      final notifications = <NotificationModel>[];
      
      for (final eq in earthquakes) {
        final notificationId = eq.earthquakeId ?? '${eq.latitude}_${eq.longitude}_${eq.dateTime.millisecondsSinceEpoch}';
        
        // Skip if this notification was deleted
        if (_deletedIds.contains(notificationId)) {
          continue;
        }
        
        // Calculate distance if we have user location
        if (userLocation != null) {
          calculatedDistance = LocationService.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            eq.latitude,
            eq.longitude,
          );
        } else {
          // Use distance from API if available, otherwise null
          calculatedDistance = eq.distance > 0 ? eq.distance : null;
        }
        
        // Apply filters based on settings
        bool shouldNotify = false;
        
        // Check minimum magnitude filter
        if (eq.magnitude >= settings.minMagnitude) {
          shouldNotify = true;
        }
        
        // Check nearby alerts filter (within 200km)
        if (settings.nearbyAlerts && calculatedDistance != null && calculatedDistance <= 200) {
          shouldNotify = true;
        }
        
        // If neither filter matches, skip this earthquake
        if (!shouldNotify) {
          continue;
        }
        
        final notificationType = eq.magnitude >= 5.0 
            ? NotificationType.majorEarthquake 
            : NotificationType.earthquake;
        
        // Create earthquake with calculated distance
        final earthquakeWithDistance = Earthquake(
          magnitude: eq.magnitude,
          location: eq.location,
          timeAgo: eq.timeAgo,
          depth: eq.depth,
          distance: calculatedDistance ?? 0.0,
          latitude: eq.latitude,
          longitude: eq.longitude,
          earthquakeId: eq.earthquakeId,
          provider: eq.provider,
          dateTime: eq.dateTime,
        );
        
        notifications.add(
          NotificationModel(
            id: notificationId,
            type: notificationType,
            title: eq.magnitude >= 5.0 ? 'major_earthquake_alert' : 'earthquake_detected', // Localization key
            content: 'M${eq.magnitude.toStringAsFixed(1)} earthquake in ${eq.location}', // Will be localized in card
            timeAgo: eq.timeAgo,
            magnitude: 'M${eq.magnitude.toStringAsFixed(1)}',
            badgeColor: null, // Will be set based on magnitude in card
            earthquake: earthquakeWithDistance,
            isRead: false,
          ),
        );
        
        // Show phone notification if push notifications are enabled and this is a new notification
        if (settings.pushNotifications && !_shownNotificationIds.contains(notificationId)) {
          _shownNotificationIds.add(notificationId);
          // Show notification on phone (this will be handled by NotificationService)
          // We'll call this after a small delay to avoid showing too many at once
          Future.delayed(const Duration(milliseconds: 100), () {
            NotificationService.instance.showEarthquakeNotification(earthquakeWithDistance);
          });
        }
      }
      
      // Sort by date (newest first)
      notifications.sort((a, b) {
        if (a.earthquake != null && b.earthquake != null) {
          return b.earthquake!.dateTime.compareTo(a.earthquake!.dateTime);
        }
        return 0;
      });
      
      _items = notifications;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      // On error, keep empty list or use sample data as fallback
      _items = [];
    }
  }

  Future<void> refresh() async {
    await _loadNotificationsFromAPI();
  }

  void markReadAndRemove(String id) {
    // Legacy method name kept for compatibility; no longer removes.
    // Now it only marks as read, preserving the item in the list.
    for (final n in _items) {
      if (n.id == id) {
        n.isRead = true;
        break;
      }
    }
  }

  void markRead(String id) {
    for (final n in _items) {
      if (n.id == id) {
        n.isRead = true;
        break;
      }
    }
  }

  void markUnread(String id) {
    for (final n in _items) {
      if (n.id == id) {
        n.isRead = false;
        break;
      }
    }
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    _deletedIds.add(id); // Mark as deleted so it won't come back on refresh
  }
}


