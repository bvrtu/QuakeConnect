import 'package:flutter/material.dart';
import 'earthquake.dart';

enum NotificationType {
  majorEarthquake,
  earthquake,
  safetyReport,
  communityUpdate,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String timeAgo;
  final String? magnitude;
  final Color? badgeColor;
  bool isRead;
  final Earthquake? earthquake;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.timeAgo,
    this.magnitude,
    this.badgeColor,
    this.isRead = false,
    this.earthquake,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.majorEarthquake:
      case NotificationType.earthquake:
        return Icons.warning;
      case NotificationType.safetyReport:
        return Icons.check_circle;
      case NotificationType.communityUpdate:
        return Icons.info;
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
        timeAgo: '2 min ago',
        magnitude: 'M5.2',
        badgeColor: Colors.red,
        earthquake: byMag(5.2),
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.safetyReport,
        title: 'Safety Report',
        content: 'Ayşe Yılmaz marked themselves as safe in Kadıköy',
        timeAgo: '5 min ago',
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.earthquake,
        title: 'Earthquake Detected',
        content: 'M4.8 earthquake in Marmara Denizi, Tekirdağ',
        timeAgo: '1 hour ago',
        magnitude: 'M4.8',
        badgeColor: Colors.orange,
        earthquake: byMag(4.8),
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.communityUpdate,
        title: 'Community Update',
        content: 'New safety tips posted for earthquake preparedness',
        timeAgo: '3 hours ago',
      ),
      NotificationModel(
        id: 'n5',
        type: NotificationType.majorEarthquake,
        title: 'Major Earthquake Alert',
        content: 'M5.6 earthquake in Ege Denizi, Gökova Körfezi',
        timeAgo: '6 hours ago',
        magnitude: 'M5.6',
        badgeColor: Colors.red,
        earthquake: byMag(5.6),
      ),
    ];
  }
}

