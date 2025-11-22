import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationModel.getSampleNotifications();
    final unreadCount = 2; // From the image, there are 2 unread notifications

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Notifications title with badge
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).notificationsTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, size: 28, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(notification: notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

