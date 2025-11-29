import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class EarthquakeApiService {
  static const String baseUrl = 'https://api.orhanaydogdu.com.tr';
  
  /// Fetches all earthquakes from the last 24 hours (combined sources)
  /// Returns a list of Earthquake objects
  static Future<List<Earthquake>> fetchRecentEarthquakes({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/deprem')
          .replace(queryParameters: {
        if (skip > 0) 'skip': skip.toString(),
        if (limit != 100) 'limit': limit.toString(),
      });
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true && jsonData['result'] != null) {
          final List<dynamic> earthquakesJson = jsonData['result'];
          return earthquakesJson.map((json) => Earthquake.fromApiJson(json)).toList();
        } else {
          throw Exception('API returned invalid data');
        }
      } else {
        throw Exception('Failed to load earthquakes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching earthquakes: $e');
    }
  }
}

