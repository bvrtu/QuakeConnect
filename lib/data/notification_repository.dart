import '../models/notification_model.dart';

class NotificationRepository {
  static final NotificationRepository instance = NotificationRepository._();
  NotificationRepository._() {
    _items = NotificationModel.getSampleNotifications();
  }

  late List<NotificationModel> _items;

  List<NotificationModel> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

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
  }
}


