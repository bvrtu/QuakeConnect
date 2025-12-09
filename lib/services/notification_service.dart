import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import '../models/earthquake.dart';
import '../data/settings_repository.dart';
import '../firebase_options.dart';
import 'auth_service.dart';

// Top-level function for background message handling
// This must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized in the background isolate
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase might already be initialized
    print('Firebase initialization in background handler: $e');
  }
  
  print('Handling background message: ${message.messageId}');
  
  // Show local notification for background messages
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_quakeconnectnotextnobg');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  await localNotifications.initialize(initSettings);
  
  final notification = message.notification;
  if (notification != null) {
    final androidDetails = AndroidNotificationDetails(
      message.data['channel'] ?? 'earthquake_channel',
      message.data['channelName'] ?? 'Earthquake Alerts',
      channelDescription: message.data['channelDescription'] ?? 'Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_stat_quakeconnectnotextnobg',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Notification',
      notification.body ?? '',
      details,
      payload: message.data['payload'] ?? message.data['postId'] != null ? 'post:${message.data['postId']}' : null,
    );
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  final _notificationTapController = StreamController<String?>.broadcast();
  String? _fcmToken;
  
  // Expose notifications plugin for permission requests
  FlutterLocalNotificationsPlugin get notifications => _notifications;
  Stream<String?> get onNotificationTap => _notificationTapController.stream;
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_quakeconnectnotextnobg');
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

    // Initialize Firebase Cloud Messaging
    await _initializeFCM();

    _initialized = true;
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
    
    // Save token to Firestore for current user
    await saveTokenToFirestore(_fcmToken);

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
      saveTokenToFirestore(newToken);
    });

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up background message handler (must be top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Save FCM token to Firestore
  Future<void> saveTokenToFirestore(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM token saved to Firestore');
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    final settings = SettingsRepository.instance;
    if (!settings.pushNotifications) return;

    // Show local notification for foreground messages
    final notification = message.notification;
    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        message.data['channel'] ?? 'earthquake_channel',
        message.data['channelName'] ?? 'Earthquake Alerts',
        channelDescription: message.data['channelDescription'] ?? 'Notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_stat_quakeconnectnotextnobg',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notification.hashCode,
        notification.title ?? 'Notification',
        notification.body ?? '',
        details,
        payload: message.data['payload'] ?? message.data['postId'] != null ? 'post:${message.data['postId']}' : null,
      );
    }
  }

  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    final postId = message.data['postId'];
    if (postId != null) {
      _notificationTapController.add('post:$postId');
    } else {
      final payload = message.data['payload'];
      if (payload != null) {
        _notificationTapController.add(payload);
      }
    }
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
      icon: '@drawable/ic_stat_quakeconnectnotextnobg',
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
      icon: '@drawable/ic_stat_quakeconnectnotextnobg',
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
      icon: "@drawable/ic_stat_quakeconnectnotextnobg",
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
