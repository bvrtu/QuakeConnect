class Earthquake {
  final double magnitude;
  final String location;
  final String timeAgo;
  final double depth; // in km
  final double distance; // in km from user

  Earthquake({
    required this.magnitude,
    required this.location,
    required this.timeAgo,
    required this.depth,
    required this.distance,
  });

  // Test data generator
  static List<Earthquake> getSampleData() {
    return [
      Earthquake(
        magnitude: 5.2,
        location: "Ege Denizi, İzmir",
        timeAgo: "2 min ago",
        depth: 12.5,
        distance: 45.0,
      ),
      Earthquake(
        magnitude: 4.8,
        location: "Marmara Denizi, Tekirdağ",
        timeAgo: "1 hour ago",
        depth: 8.2,
        distance: 78.0,
      ),
      Earthquake(
        magnitude: 3.9,
        location: "Kütahya, Simav",
        timeAgo: "2 hours ago",
        depth: 15.6,
        distance: 320.0,
      ),
      Earthquake(
        magnitude: 4.3,
        location: "Muğla, Datça Açıkları",
        timeAgo: "3 hours ago",
        depth: 6.8,
        distance: 520.0,
      ),
      Earthquake(
        magnitude: 2.8,
        location: "Denizli, Acıpayam",
        timeAgo: "4 hours ago",
        depth: 9.2,
        distance: 410.0,
      ),
      Earthquake(
        magnitude: 3.2,
        location: "Manisa, Akhisar",
        timeAgo: "5 hours ago",
        depth: 11.5,
        distance: 280.0,
      ),
      Earthquake(
        magnitude: 5.6,
        location: "Ege Denizi, Gökova Körfezi",
        timeAgo: "6 hours ago",
        depth: 14.3,
        distance: 480.0,
      ),
      Earthquake(
        magnitude: 4.1,
        location: "Balıkesir, Edremit Körfezi",
        timeAgo: "7 hours ago",
        depth: 7.9,
        distance: 195.0,
      ),
      Earthquake(
        magnitude: 3.5,
        location: "Çanakkale, Ayvacık",
        timeAgo: "8 hours ago",
        depth: 10.1,
        distance: 340.0,
      ),
      Earthquake(
        magnitude: 2.9,
        location: "Bolu, Düzce",
        timeAgo: "9 hours ago",
        depth: 13.7,
        distance: 220.0,
      ),
      Earthquake(
        magnitude: 4.5,
        location: "Antalya, Kaş",
        timeAgo: "10 hours ago",
        depth: 5.3,
        distance: 650.0,
      ),
      Earthquake(
        magnitude: 3.8,
        location: "Bursa, Nilüfer",
        timeAgo: "11 hours ago",
        depth: 9.8,
        distance: 150.0,
      ),
      Earthquake(
        magnitude: 2.5,
        location: "Ankara, Çankaya",
        timeAgo: "12 hours ago",
        depth: 11.2,
        distance: 180.0,
      ),
      Earthquake(
        magnitude: 4.9,
        location: "Muğla, Bodrum",
        timeAgo: "13 hours ago",
        depth: 8.7,
        distance: 550.0,
      ),
      Earthquake(
        magnitude: 3.3,
        location: "İzmir, Bornova",
        timeAgo: "14 hours ago",
        depth: 12.1,
        distance: 60.0,
      ),
    ];
  }
}
