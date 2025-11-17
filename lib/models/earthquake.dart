class Earthquake {
  final double magnitude;
  final String location;
  final String timeAgo;
  final double depth; // in km
  final double distance; // in km from user
  final double latitude;
  final double longitude;

  Earthquake({
    required this.magnitude,
    required this.location,
    required this.timeAgo,
    required this.depth,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  // Test data generator with coordinates
  static List<Earthquake> getSampleData() {
    return [
      Earthquake(
        magnitude: 5.2,
        location: "Ege Denizi, İzmir",
        timeAgo: "2 min ago",
        depth: 12.5,
        distance: 45.0,
        latitude: 38.4192,
        longitude: 27.1287,
      ),
      Earthquake(
        magnitude: 4.8,
        location: "Marmara Denizi, Tekirdağ",
        timeAgo: "1 hour ago",
        depth: 8.2,
        distance: 78.0,
        latitude: 40.9781,
        longitude: 27.5117,
      ),
      Earthquake(
        magnitude: 3.9,
        location: "Kütahya, Simav",
        timeAgo: "2 hours ago",
        depth: 15.6,
        distance: 320.0,
        latitude: 39.4242,
        longitude: 29.9833,
      ),
      Earthquake(
        magnitude: 4.3,
        location: "Muğla, Datça Açıkları",
        timeAgo: "3 hours ago",
        depth: 6.8,
        distance: 520.0,
        latitude: 36.735,
        longitude: 27.7186,
      ),
      Earthquake(
        magnitude: 2.8,
        location: "Denizli, Acıpayam",
        timeAgo: "4 hours ago",
        depth: 9.2,
        distance: 410.0,
        latitude: 37.7765,
        longitude: 29.0864,
      ),
      Earthquake(
        magnitude: 3.2,
        location: "Manisa, Akhisar",
        timeAgo: "5 hours ago",
        depth: 11.5,
        distance: 280.0,
        latitude: 38.6191,
        longitude: 27.4297,
      ),
      Earthquake(
        magnitude: 5.6,
        location: "Ege Denizi, Gökova Körfezi",
        timeAgo: "6 hours ago",
        depth: 14.3,
        distance: 480.0,
        latitude: 37.0,
        longitude: 28.0,
      ),
      Earthquake(
        magnitude: 4.1,
        location: "Balıkesir, Edremit Körfezi",
        timeAgo: "7 hours ago",
        depth: 7.9,
        distance: 195.0,
        latitude: 39.5925,
        longitude: 26.8614,
      ),
      Earthquake(
        magnitude: 3.5,
        location: "Çanakkale, Ayvacık",
        timeAgo: "8 hours ago",
        depth: 10.1,
        distance: 340.0,
        latitude: 39.6,
        longitude: 26.15,
      ),
      Earthquake(
        magnitude: 2.9,
        location: "Bolu, Düzce",
        timeAgo: "9 hours ago",
        depth: 13.7,
        distance: 220.0,
        latitude: 40.7439,
        longitude: 31.6119,
      ),
      Earthquake(
        magnitude: 4.5,
        location: "Antalya, Kaş",
        timeAgo: "10 hours ago",
        depth: 5.3,
        distance: 650.0,
        latitude: 36.2,
        longitude: 29.6,
      ),
      Earthquake(
        magnitude: 3.8,
        location: "Bursa, Nilüfer",
        timeAgo: "11 hours ago",
        depth: 9.8,
        distance: 150.0,
        latitude: 40.2,
        longitude: 29.1,
      ),
      Earthquake(
        magnitude: 2.5,
        location: "Ankara, Çankaya",
        timeAgo: "12 hours ago",
        depth: 11.2,
        distance: 180.0,
        latitude: 39.9,
        longitude: 32.9,
      ),
      Earthquake(
        magnitude: 4.9,
        location: "Muğla, Bodrum",
        timeAgo: "13 hours ago",
        depth: 8.7,
        distance: 550.0,
        latitude: 37.0,
        longitude: 27.4,
      ),
      Earthquake(
        magnitude: 3.3,
        location: "İzmir, Bornova",
        timeAgo: "14 hours ago",
        depth: 12.1,
        distance: 60.0,
        latitude: 38.5,
        longitude: 27.2,
      ),
    ];
  }
}
