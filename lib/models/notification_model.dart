import 'package:flutter/material.dart';

enum NotificationType {
  majorEarthquake,
  earthquake,
  safetyReport,
  communityUpdate,
}

class NotificationModel {
  final NotificationType type;
  final String title;
  final String content;
  final String timeAgo;
  final String? magnitude;
  final Color? badgeColor;

  NotificationModel({
    required this.type,
    required this.title,
    required this.content,
    required this.timeAgo,
    this.magnitude,
    this.badgeColor,
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
    return [
      NotificationModel(
        type: NotificationType.majorEarthquake,
        title: 'Major Earthquake Alert',
        content: 'M5.2 earthquake detected in Ege Denizi, İzmir - 45km from your location',
        timeAgo: '2 min ago',
        magnitude: 'M5.2',
        badgeColor: Colors.red,
      ),
      NotificationModel(
        type: NotificationType.safetyReport,
        title: 'Safety Report',
        content: 'Ayşe Yılmaz marked themselves as safe in Kadıköy',
        timeAgo: '5 min ago',
      ),
      NotificationModel(
        type: NotificationType.earthquake,
        title: 'Earthquake Detected',
        content: 'M4.8 earthquake in Marmara Denizi, Tekirdağ',
        timeAgo: '1 hour ago',
        magnitude: 'M4.8',
        badgeColor: Colors.orange,
      ),
      NotificationModel(
        type: NotificationType.communityUpdate,
        title: 'Community Update',
        content: 'New safety tips posted for earthquake preparedness',
        timeAgo: '3 hours ago',
      ),
      NotificationModel(
        type: NotificationType.majorEarthquake,
        title: 'Major Earthquake Alert',
        content: 'M5.6 earthquake in Ege Denizi, Gökova Körfezi',
        timeAgo: '6 hours ago',
        magnitude: 'M5.6',
        badgeColor: Colors.red,
      ),
    ];
  }
}

