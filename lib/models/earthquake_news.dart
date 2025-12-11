import 'package:cloud_firestore/cloud_firestore.dart';

class EarthquakeNews {
  final String id;
  final String title;
  final String url;
  final String source; // e.g., "BBC Türkçe", "CNN Türk", "AA"
  final DateTime publishedAt;
  final String? imageUrl; // Optional thumbnail image

  EarthquakeNews({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
  });

  /// Factory constructor to create EarthquakeNews from Firestore document
  factory EarthquakeNews.fromFirestore(Map<String, dynamic> data, String id) {
    return EarthquakeNews(
      id: id,
      title: data['title'] as String? ?? '',
      url: data['url'] as String? ?? '',
      source: data['source'] as String? ?? 'Unknown',
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'url': url,
      'source': source,
      'publishedAt': Timestamp.fromDate(publishedAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

