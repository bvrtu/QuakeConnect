import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';

class EarthquakeCard extends StatelessWidget {
  final Earthquake earthquake;
  final VoidCallback? onTap;

  const EarthquakeCard({super.key, required this.earthquake, this.onTap});

  @override
  Widget build(BuildContext context) {
    final magnitudeColor = AppTheme.getMagnitudeColor(earthquake.magnitude);
    final borderColor = AppTheme.getMagnitudeBorderColor(earthquake.magnitude);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Blend a magnitude tint onto the surface so it works on both themes
    final backgroundColor = Color.alphaBlend(
      magnitudeColor.withValues(alpha: isDark ? 0.18 : 0.10),
      surface,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Magnitude Box
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: magnitudeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  earthquake.magnitude.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Location
                  Text(
                    earthquake.location,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Time and Depth Row
                  Wrap(
                    spacing: 20,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 16, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              translateRelativeFromEnglish(context, earthquake.timeAgo),
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.layers, size: 16, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "${earthquake.depth.toStringAsFixed(1)} km ${AppLocalizations.of(context).deepSuffix}",
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Distance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          earthquake.distance > 0
                              ? "${earthquake.distance.toStringAsFixed(0)} km ${AppLocalizations.of(context).awaySuffix}"
                              : AppLocalizations.of(context).distanceUnknown,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
