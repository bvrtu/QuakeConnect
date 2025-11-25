import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const NotificationCard({super.key, required this.notification, this.onTap, this.onLongPress, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isRead = notification.isRead;
    Color highlight = notification.iconColor;
    if (notification.type == NotificationType.earthquake || notification.type == NotificationType.majorEarthquake) {
      double? mag;
      if (notification.earthquake != null) {
        mag = notification.earthquake!.magnitude;
      } else if (notification.magnitude != null) {
        final m = RegExp(r"([0-9]+\.?[0-9]*)").firstMatch(notification.magnitude!);
        if (m != null) {
          mag = double.tryParse(m.group(1)!);
        }
      }
      if (mag != null) {
        highlight = AppTheme.getMagnitudeColor(mag);
      }
    }

    final borderColor = isRead
        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
        : (isDark ? highlight.withValues(alpha: 0.7) : highlight.withValues(alpha: 0.8));
    final cardColor = isRead
        ? surface
        : (isDark ? surface.withValues(alpha: 1.0) : highlight.withValues(alpha: 0.06));
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: isRead ? 1.2 : 1.6),
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification.iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                            ),
                            if (notification.magnitude != null && notification.badgeColor != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: notification.badgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notification.magnitude!,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: -6,
                right: -6,
                child: Material(
                  color: isDark ? const Color(0xFF2A2B2F) : Colors.white,
                  elevation: 2,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close, size: 16, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
            if (!isRead)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
