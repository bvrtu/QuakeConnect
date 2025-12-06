import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';

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
    
    // For earthquake notifications, use red color for border (not magnitude-based)
    Color highlight = notification.iconColor;
    Color? badgeColor = notification.badgeColor;
    
    if (notification.type == NotificationType.earthquake || notification.type == NotificationType.majorEarthquake) {
      // Border color is always red for earthquake notifications
      highlight = Colors.red;
      
      // Badge color is based on magnitude (same as earthquake cards)
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
        badgeColor = AppTheme.getMagnitudeColor(mag);
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
                        // Localize title if it's a key, otherwise use as-is
                        notification.title == 'major_earthquake_alert' 
                            ? AppLocalizations.of(context).majorEarthquakeAlert
                            : notification.title == 'earthquake_detected'
                                ? AppLocalizations.of(context).earthquakeDetected
                                : notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    if (notification.magnitude != null && badgeColor != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
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
                  _buildLocalizedContent(context, notification),
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
                  formatTimeAgo(context, notification.createdAt),
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

  String _buildLocalizedContent(BuildContext context, NotificationModel notification) {
    final loc = AppLocalizations.of(context);
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    
    if (notification.type == NotificationType.earthquake || notification.type == NotificationType.majorEarthquake) {
      if (notification.earthquake != null) {
        final eq = notification.earthquake!;
        String distanceText = '';
        
        if (eq.distance > 0) {
          distanceText = ' - ${eq.distance.toStringAsFixed(0)}km ${loc.fromYourLocation}';
        } else {
          // Show "?" or "Unknown" if distance cannot be calculated
          final unknownText = isTurkish ? ' (mesafe bilinmiyor)' : ' (distance unknown)';
          distanceText = unknownText;
        }
        
        if (isTurkish) {
          // Turkish: "M2.9 deprem ILICA-SINDIRGI (BALIKESIR) - 49km konumunuzdan"
          return 'M${eq.magnitude.toStringAsFixed(1)} ${loc.earthquakeIn} ${eq.location}$distanceText';
        } else {
          // English: "M2.9 earthquake in ILICA-SINDIRGI (BALIKESIR) - 49km from your location"
          return 'M${eq.magnitude.toStringAsFixed(1)} ${loc.earthquakeIn} ${eq.location}$distanceText';
        }
      }
    }
    
    return notification.content;
  }
}
