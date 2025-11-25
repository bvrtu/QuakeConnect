import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../l10n/app_localizations.dart';
import '../data/notification_repository.dart';
import '../models/earthquake.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onOpenMapTab;
  final VoidCallback? onOpenSafetyTab;
  final void Function(Earthquake earthquake)? onOpenOnMap;

  const NotificationsScreen({super.key, this.onOpenMapTab, this.onOpenSafetyTab, this.onOpenOnMap});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final repo = NotificationRepository.instance;

  int get _unreadCount => repo.unreadCount;

  void _handleTap(NotificationModel n) {
    setState(() {
      repo.markRead(n.id);
    });

    // Navigate to relevant place (earthquake notifications use same flow as home cards)
    switch (n.type) {
      case NotificationType.majorEarthquake:
      case NotificationType.earthquake:
        Navigator.of(context).pop();
        if (n.earthquake != null) {
          widget.onOpenOnMap?.call(n.earthquake!);
        } else {
          widget.onOpenMapTab?.call();
        }
        break;
      case NotificationType.safetyReport:
      case NotificationType.communityUpdate:
        Navigator.of(context).pop();
        widget.onOpenSafetyTab?.call();
        break;
    }
  }

  void _showItemMenu(NotificationModel n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final onSurface = Theme.of(context).colorScheme.onSurface;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: Text('Mark as read', style: TextStyle(color: onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    repo.markRead(n.id);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: Text('Mark as unread', style: TextStyle(color: onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    repo.markUnread(n.id);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          '$_unreadCount',
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
              child: repo.items.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: repo.items.length,
                      itemBuilder: (context, index) {
                        final n = repo.items[index];
                        return NotificationCard(
                          notification: n,
                          onTap: () => _handleTap(n),
                          onLongPress: () => _showItemMenu(n),
                          onDelete: () {
                            setState(() {
                              repo.remove(n.id);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none, size: 40, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noNotificationsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).noNotificationsSubtitle,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

