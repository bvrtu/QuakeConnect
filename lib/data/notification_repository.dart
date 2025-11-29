import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/earthquake.dart';
import '../services/earthquake_api_service.dart';
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

  List<NotificationModel> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> _loadNotificationsFromAPI() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final earthquakes = await EarthquakeApiService.fetchRecentEarthquakes(limit: 100);
      
      // Create notifications from real earthquake data
      final notifications = <NotificationModel>[];
      
      for (final eq in earthquakes) {
        // Create notification for major earthquakes (5.0+) or nearby earthquakes (within 100km)
        if (eq.magnitude >= 5.0 || eq.distance <= 100) {
          final notificationId = eq.earthquakeId ?? '${eq.latitude}_${eq.longitude}_${eq.dateTime.millisecondsSinceEpoch}';
          
          // Skip if this notification was deleted
          if (_deletedIds.contains(notificationId)) {
            continue;
          }
          
          final notificationType = eq.magnitude >= 5.0 
              ? NotificationType.majorEarthquake 
              : NotificationType.earthquake;
          
          notifications.add(
            NotificationModel(
              id: notificationId,
              type: notificationType,
              title: eq.magnitude >= 5.0 ? 'major_earthquake_alert' : 'earthquake_detected', // Localization key
              content: 'M${eq.magnitude.toStringAsFixed(1)} earthquake in ${eq.location}', // Will be localized in card
              timeAgo: eq.timeAgo,
              magnitude: 'M${eq.magnitude.toStringAsFixed(1)}',
              badgeColor: null, // Will be set based on magnitude in card
              earthquake: eq,
              isRead: false,
            ),
          );
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


