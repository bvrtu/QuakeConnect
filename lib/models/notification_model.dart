import 'package:flutter/material.dart';
import 'earthquake.dart';

enum NotificationType {
  majorEarthquake,
  earthquake,
  safetyReport,
  communityUpdate,
  like,
  comment,
  repost,
  reply,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String? magnitude;
  final Color? badgeColor;
  bool isRead;
  final DateTime createdAt;
  final Earthquake? earthquake;
  final String? postId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.magnitude,
    this.badgeColor,
    this.isRead = false,
    this.earthquake,
    this.postId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData get icon {
    switch (type) {
      case NotificationType.majorEarthquake:
      case NotificationType.earthquake:
        return Icons.warning;
      case NotificationType.safetyReport:
        return Icons.check_circle;
      case NotificationType.communityUpdate:
        return Icons.info;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
      case NotificationType.reply:
        return Icons.comment;
      case NotificationType.repost:
        return Icons.repeat;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationType.majorEarthquake:
      case NotificationType.earthquake:
        return Colors.orange;
      case NotificationType.safetyReport:
        return Colors.green;
      case NotificationType.communityUpdate:
        return Colors.blue;
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
      case NotificationType.reply:
        return Colors.blue;
      case NotificationType.repost:
        return Colors.green;
    }
  }

  static List<NotificationModel> getSampleNotifications() {
    final quakes = Earthquake.getSampleData();
    Earthquake? byMag(double m) {
      for (final e in quakes) {
        if (e.magnitude == m) return e;
      }
      return null;
    }

    return [
      NotificationModel(
        id: 'n1',
        type: NotificationType.majorEarthquake,
        title: 'Major Earthquake Alert',
        content: 'M5.2 earthquake detected in Ege Denizi, İzmir - 45km from your location',
        magnitude: 'M5.2',
        badgeColor: Colors.red,
        earthquake: byMag(5.2),
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.safetyReport,
        title: 'Safety Report',
        content: 'Ayşe Yılmaz marked themselves as safe in Kadıköy',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.earthquake,
        title: 'Earthquake Detected',
        content: 'M4.8 earthquake in Marmara Denizi, Tekirdağ',
        magnitude: 'M4.8',
        badgeColor: Colors.orange,
        earthquake: byMag(4.8),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.communityUpdate,
        title: 'Community Update',
        content: 'New safety tips posted for earthquake preparedness',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 'n5',
        type: NotificationType.majorEarthquake,
        title: 'Major Earthquake Alert',
        content: 'M5.6 earthquake in Ege Denizi, Gökova Körfezi',
        magnitude: 'M5.6',
        badgeColor: Colors.red,
        earthquake: byMag(5.6),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
}
