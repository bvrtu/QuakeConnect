import 'earthquake_news.dart';

class Earthquake {
  final double magnitude;
  final String location;
  final String timeAgo;
  final double depth; // in km
  final double distance; // in km from user
  final double latitude;
  final double longitude;
  final String? earthquakeId;
  final String? provider;
  final DateTime dateTime;
  final List<EarthquakeNews>? news; // News articles related to this earthquake

  Earthquake({
    required this.magnitude,
    required this.location,
    required this.timeAgo,
    required this.depth,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.earthquakeId,
    this.provider,
    required this.dateTime,
    this.news,
  });

  /// Factory constructor to create Earthquake from API JSON
  factory Earthquake.fromApiJson(Map<String, dynamic> json) {
    // Parse coordinates from geojson (format: [longitude, latitude])
    final coordinates = json['geojson']?['coordinates'] as List<dynamic>?;
    final longitude = coordinates != null && coordinates.length >= 1 
        ? (coordinates[0] as num).toDouble() 
        : 0.0;
    final latitude = coordinates != null && coordinates.length >= 2 
        ? (coordinates[1] as num).toDouble() 
        : 0.0;

    // Parse date_time
    DateTime parsedDateTime;
    try {
      if (json['date_time'] != null) {
        parsedDateTime = DateTime.parse(json['date_time']);
      } else if (json['date'] != null) {
        // Parse format: "2024.01.08 11:45:23"
        final dateStr = json['date'] as String;
        final parts = dateStr.split(' ');
        final dateParts = parts[0].split('.');
        final timeParts = parts.length > 1 ? parts[1].split(':') : ['0', '0', '0'];
        parsedDateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );
      } else {
        parsedDateTime = DateTime.now();
      }
    } catch (e) {
      parsedDateTime = DateTime.now();
    }

    // Calculate timeAgo
    final now = DateTime.now();
    final difference = now.difference(parsedDateTime);
    String timeAgoStr;
    if (difference.inMinutes < 1) {
      timeAgoStr = 'now';
    } else if (difference.inMinutes < 60) {
      timeAgoStr = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeAgoStr = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgoStr = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }

    // Get distance from closestCity if available
    final closestCity = json['location_properties']?['closestCity'];
    final distance = closestCity != null && closestCity['distance'] != null
        ? (closestCity['distance'] as num).toDouble() / 1000.0 // Convert from meters to km
        : 0.0;

    // Normalize location string to match Kandilli format (all uppercase)
    String location = json['title'] as String? ?? 'Unknown';
    final provider = json['provider'] as String?;
    
    // If provider is AFAD, convert to uppercase format like Kandilli
    if (provider != null && provider.toLowerCase() == 'afad') {
      location = _convertToKandilliFormat(location);
    }
    // Kandilli format is already uppercase, so no change needed

    return Earthquake(
      earthquakeId: json['earthquake_id'] as String?,
      provider: provider,
      magnitude: (json['mag'] as num?)?.toDouble() ?? 0.0,
      location: location,
      timeAgo: timeAgoStr,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
      distance: distance,
      latitude: latitude,
      longitude: longitude,
      dateTime: parsedDateTime,
      news: null, // News will be loaded separately from Firestore
    );
  }

  /// Converts AFAD location format to Kandilli format (all uppercase)
  /// Example: "Sındırgı (Balıkesir)" -> "SINDIRGI (BALIKESIR)"
  static String _convertToKandilliFormat(String location) {
    // Convert to uppercase with proper Turkish character handling
    return location.toUpperCase();
  }

  // Test data generator with coordinates
  static List<Earthquake> getSampleData() {
    final now = DateTime.now();
    return [
      Earthquake(
        magnitude: 5.2,
        location: "Ege Denizi, İzmir",
        timeAgo: "2 min ago",
        depth: 12.5,
        distance: 45.0,
        latitude: 38.4192,
        longitude: 27.1287,
        dateTime: now.subtract(const Duration(minutes: 2)),
      ),
      Earthquake(
        magnitude: 4.8,
        location: "Marmara Denizi, Tekirdağ",
        timeAgo: "1 hour ago",
        depth: 8.2,
        distance: 78.0,
        latitude: 40.9781,
        longitude: 27.5117,
        dateTime: now.subtract(const Duration(hours: 1)),
      ),
      Earthquake(
        magnitude: 3.9,
        location: "Kütahya, Simav",
        timeAgo: "2 hours ago",
        depth: 15.6,
        distance: 320.0,
        latitude: 39.4242,
        longitude: 29.9833,
        dateTime: now.subtract(const Duration(hours: 2)),
      ),
      Earthquake(
        magnitude: 4.3,
        location: "Muğla, Datça Açıkları",
        timeAgo: "3 hours ago",
        depth: 6.8,
        distance: 520.0,
        latitude: 36.735,
        longitude: 27.7186,
        dateTime: now.subtract(const Duration(hours: 3)),
      ),
      Earthquake(
        magnitude: 2.8,
        location: "Denizli, Acıpayam",
        timeAgo: "4 hours ago",
        depth: 9.2,
        distance: 410.0,
        latitude: 37.7765,
        longitude: 29.0864,
        dateTime: now.subtract(const Duration(hours: 4)),
      ),
      Earthquake(
        magnitude: 3.2,
        location: "Manisa, Akhisar",
        timeAgo: "5 hours ago",
        depth: 11.5,
        distance: 280.0,
        latitude: 38.6191,
        longitude: 27.4297,
        dateTime: now.subtract(const Duration(hours: 5)),
      ),
      Earthquake(
        magnitude: 5.6,
        location: "Ege Denizi, Gökova Körfezi",
        timeAgo: "6 hours ago",
        depth: 14.3,
        distance: 480.0,
        latitude: 37.0,
        longitude: 28.0,
        dateTime: now.subtract(const Duration(hours: 6)),
      ),
      Earthquake(
        magnitude: 4.1,
        location: "Balıkesir, Edremit Körfezi",
        timeAgo: "7 hours ago",
        depth: 7.9,
        distance: 195.0,
        latitude: 39.5925,
        longitude: 26.8614,
        dateTime: now.subtract(const Duration(hours: 7)),
      ),
      Earthquake(
        magnitude: 3.5,
        location: "Çanakkale, Ayvacık",
        timeAgo: "8 hours ago",
        depth: 10.1,
        distance: 340.0,
        latitude: 39.6,
        longitude: 26.15,
        dateTime: now.subtract(const Duration(hours: 8)),
      ),
      Earthquake(
        magnitude: 2.9,
        location: "Bolu, Düzce",
        timeAgo: "9 hours ago",
        depth: 13.7,
        distance: 220.0,
        latitude: 40.7439,
        longitude: 31.6119,
        dateTime: now.subtract(const Duration(hours: 9)),
      ),
      Earthquake(
        magnitude: 4.5,
        location: "Antalya, Kaş",
        timeAgo: "10 hours ago",
        depth: 5.3,
        distance: 650.0,
        latitude: 36.2,
        longitude: 29.6,
        dateTime: now.subtract(const Duration(hours: 10)),
      ),
      Earthquake(
        magnitude: 3.8,
        location: "Bursa, Nilüfer",
        timeAgo: "11 hours ago",
        depth: 9.8,
        distance: 150.0,
        latitude: 40.2,
        longitude: 29.1,
        dateTime: now.subtract(const Duration(hours: 11)),
      ),
      Earthquake(
        magnitude: 2.5,
        location: "Ankara, Çankaya",
        timeAgo: "12 hours ago",
        depth: 11.2,
        distance: 180.0,
        latitude: 39.9,
        longitude: 32.9,
        dateTime: now.subtract(const Duration(hours: 12)),
      ),
      Earthquake(
        magnitude: 4.9,
        location: "Muğla, Bodrum",
        timeAgo: "13 hours ago",
        depth: 8.7,
        distance: 550.0,
        latitude: 37.0,
        longitude: 27.4,
        dateTime: now.subtract(const Duration(hours: 13)),
      ),
      Earthquake(
        magnitude: 3.3,
        location: "İzmir, Bornova",
        timeAgo: "14 hours ago",
        depth: 12.1,
        distance: 60.0,
        latitude: 38.5,
        longitude: 27.2,
        dateTime: now.subtract(const Duration(hours: 14)),
      ),
    ];
  }
}
