import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../models/earthquake.dart';
import '../models/community_post.dart';
import '../services/earthquake_api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../data/settings_repository.dart';
import '../data/post_repository.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

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

  Timer? _monitoringTimer;
  DateTime _lastPostCheckTime = DateTime.now();
  final Set<String> _shownPostIds = {};
  StreamSubscription? _postSubscription;
  StreamSubscription? _authSubscription;
  StreamSubscription? _userNotificationsSubscription;
  String? _currentUserId;

  void startMonitoring() {
    if (_monitoringTimer != null) return;
    
    _currentUserId = AuthService.instance.currentUserId;
    _authSubscription ??= AuthService.instance.authStateChanges.listen((user) {
      _currentUserId = user?.uid;
      _startUserNotificationsMonitoring();
    });
    
    // Initial fetch
    _loadNotificationsFromAPI();
    
    // Start periodic polling for earthquakes (every 1 minute)
    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _loadNotificationsFromAPI();
    });
    
    // Listen for community updates
    _startPostMonitoring();
    _startUserNotificationsMonitoring();
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _postSubscription?.cancel();
    _postSubscription = null;
    _authSubscription?.cancel();
    _authSubscription = null;
    _userNotificationsSubscription?.cancel();
    _userNotificationsSubscription = null;
  }

  void _startUserNotificationsMonitoring() {
    _userNotificationsSubscription?.cancel();
    if (_currentUserId == null) return;

    _userNotificationsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      bool hasUpdates = false;
      
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final id = change.doc.id;
          if (_deletedIds.contains(id)) continue;
          if (_items.any((n) => n.id == id)) continue;

          final typeStr = data['type'] as String? ?? 'info';
          NotificationType type;
          switch (typeStr) {
            case 'like':
              type = NotificationType.like;
              break;
            case 'comment':
              type = NotificationType.comment;
              break;
            case 'repost':
              type = NotificationType.repost;
              break;
            case 'reply':
              type = NotificationType.reply;
              break;
            default:
              type = NotificationType.communityUpdate;
          }

          final title = data['title'] as String? ?? 'Notification';
          final body = data['body'] as String? ?? '';
          final postId = data['postId'] as String?;
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          final isRead = data['isRead'] as bool? ?? false;

          final notification = NotificationModel(
            id: id,
            type: type,
            title: title,
            content: body,
            isRead: isRead,
            createdAt: timestamp,
            postId: postId,
          );

          _items.insert(0, notification);
          hasUpdates = true;

          if (!isRead && DateTime.now().difference(timestamp).inMinutes < 1) {
            if (SettingsRepository.instance.pushNotifications) {
              if (!_shownNotificationIds.contains(id)) {
                _shownNotificationIds.add(id);
                NotificationService.instance.showRemoteNotification(title, body, payload: 'post:$postId');
              }
            }
          }
        }
      }
      
      if (hasUpdates) {
        _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (_items.length > 200) {
          _items = _items.sublist(0, 200);
        }
      }
    });
  }

  void _startPostMonitoring() {
    _postSubscription?.cancel();
    _postSubscription = PostRepository.instance.getAllPosts(null).listen((posts) {
      final settings = SettingsRepository.instance;
      if (!settings.communityUpdates) return;

      for (final post in posts) {
        if (_shownPostIds.contains(post.id)) continue;
        _shownPostIds.add(post.id);

        // Skip if user is not logged in or it's their own post
        if (_currentUserId == null) continue;
        if (post.authorId == _currentUserId) continue;

        _addCommunityNotification(post);

        if (settings.pushNotifications) {
          final categoryName = post.type == CommunityPostType.safe ? 'Safety Report' : 'New Community Update';
          final message = post.message.trim();
          final body = message.isEmpty
              ? post.authorName
              : '${post.authorName}: ${message.length > 80 ? '${message.substring(0, 80)}...' : message}';
          NotificationService.instance.showCommunityUpdateNotification(categoryName, body, payload: post.id);
        }
      }

      _lastPostCheckTime = DateTime.now();
    });
  }

  void _addCommunityNotification(CommunityPost post) {
    final type = post.type == CommunityPostType.safe
        ? NotificationType.safetyReport
        : NotificationType.communityUpdate;
    final title = type == NotificationType.safetyReport ? 'Safety Report' : 'Community Update';
    final trimmedMessage = post.message.trim();
    final snippet = trimmedMessage.isEmpty
        ? ''
        : (trimmedMessage.length > 140 ? '${trimmedMessage.substring(0, 140)}...' : trimmedMessage);
    final content = snippet.isEmpty ? post.authorName : '${post.authorName}: $snippet';

    final notification = NotificationModel(
      id: 'post_${post.id}',
      type: type,
      title: title,
      content: content,
      isRead: false,
      createdAt: post.timestamp,
      postId: post.id,
    );

    _items.insert(0, notification);
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_items.length > 200) {
      _items = _items.sublist(0, 200);
    }
  }

  Future<void> checkUpdatesInBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckMillis = prefs.getInt('last_background_check') ?? DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch;
    final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMillis);
    
    // Fetch earthquakes
    await _loadNotificationsFromAPI(lastCheckTime: lastCheck);
    
    // Fetch posts
    if (SettingsRepository.instance.communityUpdates) {
      try {
        final posts = await PostRepository.instance.getAllPosts(null).first;
        for (final post in posts) {
          if (post.timestamp.isAfter(lastCheck)) {
             NotificationService.instance.showCommunityUpdateNotification(
              'New Community Update',
              '${post.authorName}: ${post.message}',
              payload: 'post:${post.id}',
            );
          }
        }
      } catch (e) {
        debugPrint('Background post check error: $e');
      }
    }

    // Fetch user notifications (likes, comments, etc.)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && SettingsRepository.instance.pushNotifications) {
       try {
         final snapshot = await FirebaseFirestore.instance
             .collection('users')
             .doc(user.uid)
             .collection('notifications')
             .where('timestamp', isGreaterThan: Timestamp.fromDate(lastCheck))
             .get();
             
         for (final doc in snapshot.docs) {
            final data = doc.data();
            final title = data['title'] as String? ?? 'Notification';
            final body = data['body'] as String? ?? '';
            final postId = data['postId'] as String?;
            NotificationService.instance.showRemoteNotification(title, body, payload: 'post:$postId');
         }
       } catch (e) {
         debugPrint('Background user notification check error: $e');
       }
    }

    await prefs.setInt('last_background_check', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _loadNotificationsFromAPI({DateTime? lastCheckTime}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final earthquakes = await EarthquakeApiService.fetchRecentEarthquakes(limit: 100);
      final settings = SettingsRepository.instance;
      
      Position? userLocation;
      double? calculatedDistance;
      if (settings.locationServices) {
        userLocation = await LocationService.getCurrentLocation();
      }
      
      final earthquakeNotifications = <NotificationModel>[];

      for (final eq in earthquakes) {
        if (lastCheckTime != null && eq.dateTime.isBefore(lastCheckTime)) continue;

        final notificationId = eq.earthquakeId ?? '${eq.latitude}_${eq.longitude}_${eq.dateTime.millisecondsSinceEpoch}';
        if (_deletedIds.contains(notificationId)) {
          continue;
        }

        if (userLocation != null) {
          calculatedDistance = LocationService.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            eq.latitude,
            eq.longitude,
          );
        } else {
          calculatedDistance = eq.distance > 0 ? eq.distance : null;
        }

        bool shouldNotify = false;
        if (eq.magnitude >= settings.minMagnitude) {
          shouldNotify = true;
        }
        if (settings.nearbyAlerts && calculatedDistance != null && calculatedDistance <= 200) {
          shouldNotify = true;
        }

        // FILTER: Don't add to list if magnitude is too low
        if (eq.magnitude < settings.minMagnitude) {
           continue;
        }

        final notificationType = eq.magnitude >= 5.0
            ? NotificationType.majorEarthquake
            : NotificationType.earthquake;

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

        earthquakeNotifications.add(
          NotificationModel(
            id: notificationId,
            type: notificationType,
            title: eq.magnitude >= 5.0 ? 'major_earthquake_alert' : 'earthquake_detected',
            content: 'M${eq.magnitude.toStringAsFixed(1)} earthquake in ${eq.location}',
            magnitude: 'M${eq.magnitude.toStringAsFixed(1)}',
            badgeColor: null,
            earthquake: earthquakeWithDistance,
            createdAt: eq.dateTime,
          ),
        );

        if (settings.pushNotifications && shouldNotify && !_shownNotificationIds.contains(notificationId)) {
          _shownNotificationIds.add(notificationId);
          Future.delayed(const Duration(milliseconds: 100), () {
            NotificationService.instance.showEarthquakeNotification(earthquakeWithDistance);
          });
        }
      }

      final otherItems = _items.where((n) => n.type != NotificationType.earthquake && n.type != NotificationType.majorEarthquake).toList();
      otherItems.addAll(earthquakeNotifications);
      otherItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _items = otherItems.length > 200 ? otherItems.sublist(0, 200) : otherItems;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _items = [];
    }
  }

  Future<void> refresh() async {
    await _loadNotificationsFromAPI();
  }

  void markRead(String id) {
    for (final n in _items) {
      if (n.id == id) {
        n.isRead = true;
        // Also update in Firestore if it's a user notification
        if (n.type != NotificationType.earthquake && n.type != NotificationType.majorEarthquake && n.type != NotificationType.communityUpdate && n.type != NotificationType.safetyReport) {
             if (_currentUserId != null) {
                 FirebaseFirestore.instance
                   .collection('users')
                   .doc(_currentUserId)
                   .collection('notifications')
                   .doc(id)
                   .update({'isRead': true})
                   .catchError((e) {});
             }
        }
        break;
      }
    }
  }

  void markUnread(String id) {
    for (final n in _items) {
      if (n.id == id) {
        n.isRead = false;
         if (n.type != NotificationType.earthquake && n.type != NotificationType.majorEarthquake && n.type != NotificationType.communityUpdate && n.type != NotificationType.safetyReport) {
             if (_currentUserId != null) {
                 FirebaseFirestore.instance
                   .collection('users')
                   .doc(_currentUserId)
                   .collection('notifications')
                   .doc(id)
                   .update({'isRead': false})
                   .catchError((e) {});
             }
        }
        break;
      }
    }
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    _deletedIds.add(id);
    // Optionally delete from Firestore
  }

  void clearShownEarthquakeCache() {
    _shownNotificationIds.clear();
  }
  void clearAll() {
    for (final n in _items) {
      _deletedIds.add(n.id);
    }
    _items.clear();
  }
}
