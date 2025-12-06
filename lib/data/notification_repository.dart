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
  // User-specific tracking maps: userId -> Set of IDs
  final Map<String, Set<String>> _deletedIdsByUser = {}; // Track deleted notification IDs per user
  final Map<String, Set<String>> _shownNotificationIdsByUser = {}; // Track shown notifications per user
  final Map<String, Set<String>> _shownPostIdsByUser = {}; // Track shown posts per user
  final Map<String, bool> _isInitialLoadByUser = {}; // Track initial load state per user

  List<NotificationModel> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Timer? _monitoringTimer;
  DateTime _lastPostCheckTime = DateTime.now();
  StreamSubscription? _postSubscription;
  StreamSubscription? _authSubscription;
  StreamSubscription? _userNotificationsSubscription;
  String? _currentUserId;
  String? _previousUserId; // Track previous user to detect changes

  void startMonitoring() {
    if (_monitoringTimer != null) return;
    
    _currentUserId = AuthService.instance.currentUserId;
    _previousUserId = _currentUserId;
    
    _authSubscription ??= AuthService.instance.authStateChanges.listen((user) {
      final newUserId = user?.uid;
      
      // If user changed, clear all data and reload
      if (_previousUserId != newUserId) {
        _onUserChanged(_previousUserId, newUserId);
      }
      
      _previousUserId = newUserId;
      _currentUserId = newUserId;
      
      // Restart monitoring for new user
      _startUserNotificationsMonitoring();
      _startPostMonitoring();
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

  void _onUserChanged(String? oldUserId, String? newUserId) {
    // Clear all notifications for the old user
    _items.clear();
    
    // Reset initial load flag for new user
    if (newUserId != null) {
      _isInitialLoadByUser[newUserId] = true;
    }
    
    // Cancel existing subscriptions
    _userNotificationsSubscription?.cancel();
    _userNotificationsSubscription = null;
    _postSubscription?.cancel();
    _postSubscription = null;
    
    // Clear shown IDs for old user (optional, can keep for memory efficiency)
    // We'll keep them per user in the maps
    
    debugPrint('User changed from $oldUserId to $newUserId - cleared notifications');
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

    final userId = _currentUserId!; // Capture current user ID
    
    // Get user-specific sets
    final deletedIds = _deletedIdsByUser.putIfAbsent(userId, () => <String>{});
    final shownNotificationIds = _shownNotificationIdsByUser.putIfAbsent(userId, () => <String>{});
    
    // Reset initial load flag for this user
    _isInitialLoadByUser[userId] = true;

    _userNotificationsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      // Check if user changed during async operation
      if (_currentUserId != userId) {
        return; // User changed, ignore this snapshot
      }
      
      bool hasUpdates = false;
      final isInitialLoad = _isInitialLoadByUser[userId] ?? false;
      
      // On initial load, load all existing notifications
      if (isInitialLoad) {
        _isInitialLoadByUser[userId] = false;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data == null) continue;

          final id = doc.id;
          if (deletedIds.contains(id)) continue;
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

          _items.add(notification);
          hasUpdates = true;
        }
      } else {
        // For subsequent updates, only process new changes
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;

            final id = change.doc.id;
            if (deletedIds.contains(id)) continue;
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
                if (!shownNotificationIds.contains(id)) {
                  shownNotificationIds.add(id);
                  NotificationService.instance.showRemoteNotification(title, body, payload: 'post:$postId');
                }
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
    if (_currentUserId == null) return;
    
    final userId = _currentUserId!; // Capture current user ID
    
    // Get user-specific shown post IDs
    final shownPostIds = _shownPostIdsByUser.putIfAbsent(userId, () => <String>{});
    
    _postSubscription = PostRepository.instance.getAllPosts(null).listen((posts) async {
      // Check if user changed during async operation
      if (_currentUserId != userId) return;
      
      final settings = SettingsRepository.instance;
      if (!settings.communityUpdates) return;

      // Get list of followed users
      Set<String>? followingIds;
      try {
        final followingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('following')
            .get();
        followingIds = followingSnapshot.docs.map((doc) => doc.id).toSet();
      } catch (e) {
        followingIds = <String>{};
      }

      for (final post in posts) {
        if (shownPostIds.contains(post.id)) continue;
        shownPostIds.add(post.id);

        // Skip if it's their own post
        if (post.authorId == userId) continue;

        // Only show notifications for posts from followed users
        if (followingIds == null || !followingIds.contains(post.authorId)) {
          continue;
        }

        _addCommunityNotification(post);

        if (settings.pushNotifications) {
          final categoryName = post.type == CommunityPostType.safe ? 'Safety Report' : 'New Community Update';
          final message = post.message.trim();
          final body = message.isEmpty
              ? post.authorName
              : '${post.authorName}: ${message.length > 80 ? '${message.substring(0, 80)}...' : message}';
          NotificationService.instance.showCommunityUpdateNotification(categoryName, body, payload: 'post:${post.id}');
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
    
    // Fetch posts (only from followed users)
    if (SettingsRepository.instance.communityUpdates) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Get list of followed users
          final followingSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('following')
              .get();
          final followingIds = followingSnapshot.docs.map((doc) => doc.id).toSet();
          
          if (followingIds.isNotEmpty) {
            final posts = await PostRepository.instance.getAllPosts(null).first;
            for (final post in posts) {
              // Only show notifications for posts from followed users
              if (followingIds.contains(post.authorId) && 
                  post.timestamp.isAfter(lastCheck) &&
                  post.authorId != user.uid) {
                NotificationService.instance.showCommunityUpdateNotification(
                  'New Community Update',
                  '${post.authorName}: ${post.message}',
                  payload: 'post:${post.id}',
                );
              }
            }
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
        // Earthquakes are global, but deleted IDs should be per user
        final deletedIds = _currentUserId != null 
            ? _deletedIdsByUser.putIfAbsent(_currentUserId!, () => <String>{})
            : <String>{};
        if (deletedIds.contains(notificationId)) {
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

        // Earthquakes are global, but shown IDs should be per user
        final shownNotificationIds = _currentUserId != null
            ? _shownNotificationIdsByUser.putIfAbsent(_currentUserId!, () => <String>{})
            : <String>{};
        if (settings.pushNotifications && shouldNotify && !shownNotificationIds.contains(notificationId)) {
          shownNotificationIds.add(notificationId);
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
    if (_currentUserId != null) {
      final deletedIds = _deletedIdsByUser.putIfAbsent(_currentUserId!, () => <String>{});
      deletedIds.add(id);
    }
    // Optionally delete from Firestore for user notifications
    if (_currentUserId != null && !id.startsWith('post_') && !id.contains('_')) {
      // Likely a user notification (like, comment, etc.)
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('notifications')
          .doc(id)
          .delete()
          .catchError((e) {});
    }
  }

  void clearShownEarthquakeCache() {
    if (_currentUserId != null) {
      _shownNotificationIdsByUser[_currentUserId!]?.clear();
    }
  }
  
  void clearAll() {
    if (_currentUserId != null) {
      final deletedIds = _deletedIdsByUser.putIfAbsent(_currentUserId!, () => <String>{});
      for (final n in _items) {
        deletedIds.add(n.id);
      }
    }
    _items.clear();
  }
}
