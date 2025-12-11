import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/earthquake.dart';
import '../models/earthquake_news.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/formatters.dart';
import '../data/earthquake_news_repository.dart';

class EarthquakeCard extends StatefulWidget {
  final Earthquake earthquake;
  final VoidCallback? onTap;

  const EarthquakeCard({super.key, required this.earthquake, this.onTap});

  @override
  State<EarthquakeCard> createState() => _EarthquakeCardState();
}

class _EarthquakeCardState extends State<EarthquakeCard> {
  List<EarthquakeNews>? _news;
  bool _isLoadingNews = false;
  bool _showNews = false;

  bool get hasNews => _news != null && _news!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Load news if earthquakeId is available
    if (widget.earthquake.earthquakeId != null && widget.earthquake.earthquakeId!.isNotEmpty) {
      _loadNews();
    }
  }

  @override
  void didUpdateWidget(EarthquakeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload news if earthquake changed or widget was rebuilt
    if (widget.earthquake.earthquakeId != null && 
        widget.earthquake.earthquakeId!.isNotEmpty &&
        (oldWidget.earthquake.earthquakeId != widget.earthquake.earthquakeId || 
         oldWidget.key != widget.key)) {
      _loadNews();
    }
  }

  Future<void> _loadNews() async {
    if (_isLoadingNews) return;
    
    setState(() {
      _isLoadingNews = true;
    });

    try {
      print('EarthquakeCard: Loading news for earthquake ${widget.earthquake.earthquakeId}');
      final news = await EarthquakeNewsRepository.instance.getNewsForEarthquake(widget.earthquake.earthquakeId);
      print('EarthquakeCard: Loaded ${news.length} news articles for earthquake ${widget.earthquake.earthquakeId}');
      if (mounted) {
        setState(() {
          _news = news;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      print('EarthquakeCard: Error loading news for ${widget.earthquake.earthquakeId}: $e');
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
      }
    }
  }

  Future<void> _openNewsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // Try to launch URL directly, canLaunchUrl can be unreliable on Android
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenLink)),
        );
      }
    } catch (e) {
      print('Error opening URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenLink)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final magnitudeColor = AppTheme.getMagnitudeColor(widget.earthquake.magnitude);
    final borderColor = AppTheme.getMagnitudeBorderColor(widget.earthquake.magnitude);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Blend a magnitude tint onto the surface so it works on both themes
    final backgroundColor = Color.alphaBlend(
      magnitudeColor.withValues(alpha: isDark ? 0.18 : 0.10),
      surface,
    );

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
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
                      widget.earthquake.magnitude.toStringAsFixed(1),
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
                        widget.earthquake.location,
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
                                  translateRelativeFromEnglish(context, widget.earthquake.timeAgo),
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
                                  "${widget.earthquake.depth.toStringAsFixed(1)} km ${AppLocalizations.of(context).deepSuffix}",
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
                              widget.earthquake.distance > 0
                                  ? "${widget.earthquake.distance.toStringAsFixed(0)} km ${AppLocalizations.of(context).awaySuffix}"
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
          // News Section
          if (hasNews || _isLoadingNews) _buildNewsSection(isDark, onSurface),
        ],
      ),
      ),
    );
  }

  Widget _buildNewsSection(bool isDark, Color onSurface) {
    final t = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        InkWell(
          onTap: () {
            setState(() {
              _showNews = !_showNews;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLoadingNews 
                      ? t.loadingNews
                      : hasNews 
                          ? '${_news!.length} ${t.newsArticles}'
                          : t.noNewsAvailable,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showNews ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
        if (_showNews && hasNews) _buildNewsList(isDark, onSurface),
      ],
    );
  }

  Widget _buildNewsList(bool isDark, Color onSurface) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _news!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final news = _news![index];
        return _buildNewsCard(news, isDark, onSurface);
      },
    );
  }

  Widget _buildNewsCard(EarthquakeNews news, bool isDark, Color onSurface) {
    return InkWell(
      onTap: () => _openNewsUrl(news.url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.article,
                color: Color(0xFF1E88E5),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // News Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.source,
                        size: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
