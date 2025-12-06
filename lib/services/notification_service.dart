import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import '../models/earthquake.dart';
import '../data/settings_repository.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  final _notificationTapController = StreamController<String?>.broadcast();
  
  // Expose notifications plugin for permission requests
  FlutterLocalNotificationsPlugin get notifications => _notifications;
  Stream<String?> get onNotificationTap => _notificationTapController.stream;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() != null) {
      await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _notificationTapController.add(response.payload);
    }
  }

  /// Show earthquake notification
  Future<void> showEarthquakeNotification(Earthquake earthquake) async {
    final settings = SettingsRepository.instance;
    
    // Only show if push notifications are enabled
    if (!settings.pushNotifications) {
      return;
    }

    // Check if notification should be shown based on filters
    bool shouldShow = false;
    
    // Check minimum magnitude
    if (earthquake.magnitude >= settings.minMagnitude) {
      shouldShow = true;
    }
    
    // Check nearby alerts
    if (settings.nearbyAlerts && earthquake.distance > 0 && earthquake.distance <= 200) {
      shouldShow = true;
    }
    
    if (!shouldShow) {
      return;
    }

    final isMajor = earthquake.magnitude >= 5.0;
    final title = isMajor ? 'Major Earthquake Alert' : 'Earthquake Detected';
    final body = earthquake.distance > 0
        ? 'M${earthquake.magnitude.toStringAsFixed(1)} earthquake in ${earthquake.location} - ${earthquake.distance.toStringAsFixed(0)}km away'
        : 'M${earthquake.magnitude.toStringAsFixed(1)} earthquake in ${earthquake.location}';

    const androidDetails = AndroidNotificationDetails(
      'earthquake_channel',
      'Earthquake Alerts',
      channelDescription: 'Notifications for earthquake alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      earthquake.earthquakeId?.hashCode ?? earthquake.dateTime.millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: 'eq:${earthquake.earthquakeId}',
    );
  }

  /// Show community update notification
  Future<void> showCommunityUpdateNotification(String title, String body, {String? payload}) async {
    final settings = SettingsRepository.instance;
    
    // Only show if community updates are enabled
    if (!settings.communityUpdates) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'community_channel',
      'Community Updates',
      channelDescription: 'Notifications for community updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showRemoteNotification(String title, String body, {String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      "remote_channel",
      "General Notifications",
      channelDescription: "Notifications for QuakeConnect updates",
      importance: Importance.high,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
