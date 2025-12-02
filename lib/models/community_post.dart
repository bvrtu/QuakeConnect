import 'package:flutter/material.dart';

enum CommunityPostType { needHelp, info, safe }

class CommunityPost {
  final String id;
  final String authorName;
  final String handle;
  final CommunityPostType type;
  final String message;
  final String location;
  DateTime timestamp;
  int likes;
  int comments;
  int shares;
  int reposts;
  bool isLiked;
  bool isReposted;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.handle,
    required this.type,
    required this.message,
    required this.location,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.reposts = 0,
    this.isLiked = false,
    this.isReposted = false,
  });

  CommunityPost copyWith({
    String? id,
    String? authorName,
    String? handle,
    CommunityPostType? type,
    String? message,
    String? location,
    DateTime? timestamp,
    int? likes,
    int? comments,
    int? shares,
    int? reposts,
    bool? isLiked,
    bool? isReposted,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      handle: handle ?? this.handle,
      type: type ?? this.type,
      message: message ?? this.message,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      reposts: reposts ?? this.reposts,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'authorName': authorName,
      'authorHandle': handle,
      'type': type.toString().split('.').last,
      'message': message,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'reposts': reposts,
    };
  }

  /// Create from Firestore map
  factory CommunityPost.fromFirestore(Map<String, dynamic> map, String id) {
    final typeStr = map['type'] as String? ?? 'info';
    final type = CommunityPostType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => CommunityPostType.info,
    );
    
    return CommunityPost(
      id: id,
      authorName: map['authorName'] as String? ?? 'Unknown',
      handle: map['authorHandle'] as String? ?? '@unknown',
      type: type,
      message: map['message'] as String? ?? '',
      location: map['location'] as String? ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      likes: (map['likes'] as int?) ?? 0,
      comments: (map['comments'] as int?) ?? 0,
      shares: (map['shares'] as int?) ?? 0,
      reposts: (map['reposts'] as int?) ?? 0,
      isLiked: false,
      isReposted: false,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }

  String get badgeLabel {
    switch (type) {
      case CommunityPostType.needHelp:
        return 'Need Help';
      case CommunityPostType.info:
        return 'Info';
      case CommunityPostType.safe:
        return "I'm Safe";
    }
  }

  Color get badgeColor {
    switch (type) {
      case CommunityPostType.needHelp:
        return const Color(0xFFE53935); // Red
      case CommunityPostType.info:
        return const Color(0xFF1E88E5); // Blue
      case CommunityPostType.safe:
        return const Color(0xFF2E7D32); // Green
    }
  }

  Color get badgeBackground {
    switch (type) {
      case CommunityPostType.needHelp:
        return const Color(0xFFFCE8E7);
      case CommunityPostType.info:
        return const Color(0xFFE3F2FD);
      case CommunityPostType.safe:
        return const Color(0xFFE8F5E9);
    }
  }

  static List<CommunityPost> sampleData() {
    return [
      CommunityPost(
        id: 'post-1',
        authorName: 'Ayşe Yılmaz',
        handle: '@ayseyilmaz',
        type: CommunityPostType.safe,
        message: 'Electricity is out in our neighborhood. Everyone is safe.',
        location: 'Kadıköy, İstanbul',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        likes: 24,
        comments: 5,
        shares: 3,
        reposts: 1,
      ),
      CommunityPost(
        id: 'post-2',
        authorName: 'Mehmet Demir',
        handle: '@mehmetdemir',
        type: CommunityPostType.needHelp,
        message:
            'Road to hospital blocked due to debris. Seeking alternate route.',
        location: 'Maltepe, İstanbul',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        likes: 45,
        comments: 12,
        shares: 8,
        reposts: 6,
      ),
      CommunityPost(
        id: 'post-3',
        authorName: 'Can Y.',
        handle: '@cany',
        type: CommunityPostType.info,
        message:
            'Minor damage to some buildings. Emergency services arrived quickly.',
        location: 'Kartal, İstanbul',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        likes: 18,
        comments: 3,
        shares: 2,
        reposts: 0,
      ),
      CommunityPost(
        id: 'post-4',
        authorName: 'Zeynep A.',
        handle: '@zeynepa',
        type: CommunityPostType.safe,
        message: 'All family members are safe. No visible damage in our area.',
        location: 'Üsküdar, İstanbul',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 67,
        comments: 8,
        shares: 4,
        reposts: 2,
      ),
      CommunityPost(
        id: 'post-5',
        authorName: 'Selim Kara',
        handle: '@selimkara',
        type: CommunityPostType.needHelp,
        message:
            'We need volunteers to help distribute supplies at the community center.',
        location: 'Kartal, İstanbul',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 2, minutes: 10),
        ),
        likes: 32,
        comments: 6,
        shares: 5,
        reposts: 3,
      ),
      CommunityPost(
        id: 'post-6',
        authorName: 'Deniz C.',
        handle: '@denizc',
        type: CommunityPostType.info,
        message:
            'Police have cleared most roads in the area. Traffic is flowing again.',
        location: 'Ataşehir, İstanbul',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 41,
        comments: 4,
        shares: 7,
        reposts: 4,
      ),
    ];
  }
}
