import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/earthquake_news.dart';

/// Repository for managing earthquake news articles in Firestore
class EarthquakeNewsRepository {
  static final EarthquakeNewsRepository _instance = EarthquakeNewsRepository._internal();
  factory EarthquakeNewsRepository() => _instance;
  EarthquakeNewsRepository._internal();

  static EarthquakeNewsRepository get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'earthquake_news';

  /// Get news articles for a specific earthquake by earthquakeId
  /// News are stored in: earthquake_news/{earthquakeId}/articles/{newsId}
  Future<List<EarthquakeNews>> getNewsForEarthquake(String? earthquakeId) async {
    if (earthquakeId == null || earthquakeId.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(earthquakeId)
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .limit(5) // Limit to 5 most recent news articles
          .get();

      return snapshot.docs.map((doc) {
        return EarthquakeNews.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching news for earthquake $earthquakeId: $e');
      return [];
    }
  }

  /// Stream news articles for a specific earthquake (real-time updates)
  Stream<List<EarthquakeNews>> streamNewsForEarthquake(String? earthquakeId) {
    if (earthquakeId == null || earthquakeId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .doc(earthquakeId)
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EarthquakeNews.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Add a news article for an earthquake (admin function)
  /// This would typically be called from a backend/admin panel
  Future<void> addNewsArticle({
    required String earthquakeId,
    required String title,
    required String url,
    required String source,
    String? imageUrl,
    DateTime? publishedAt,
  }) async {
    try {
      final newsRef = _firestore
          .collection(_collection)
          .doc(earthquakeId)
          .collection('articles')
          .doc();

      await newsRef.set({
        'title': title,
        'url': url,
        'source': source,
        'publishedAt': Timestamp.fromDate(publishedAt ?? DateTime.now()),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      print('News article added for earthquake $earthquakeId');
    } catch (e) {
      print('Error adding news article: $e');
      rethrow;
    }
  }
}

