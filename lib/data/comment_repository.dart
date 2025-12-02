import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String handle;
  final String text;
  final DateTime timestamp;
  final String? parentCommentId; // For nested replies
  final List<String> likes;
  final int likesCount;
  final int repliesCount; // Number of direct replies to this comment

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.handle,
    required this.text,
    required this.timestamp,
    this.parentCommentId,
    List<String>? likes,
    this.likesCount = 0,
    this.repliesCount = 0,
  }) : likes = likes ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'handle': handle,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'parentCommentId': parentCommentId,
      'likes': likes,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      handle: map['handle'] as String,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      parentCommentId: map['parentCommentId'] as String?,
      likes: (map['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      likesCount: map['likesCount'] as int? ?? 0,
      repliesCount: map['repliesCount'] as int? ?? 0,
    );
  }

  Comment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? handle,
    String? text,
    DateTime? timestamp,
    String? parentCommentId,
    List<String>? likes,
    int? likesCount,
    int? repliesCount,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      handle: handle ?? this.handle,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }

  String get timeAgo {
    final d = DateTime.now().difference(timestamp);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class CommentRepository {
  static final CommentRepository instance = CommentRepository._();
  CommentRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _postsCollection = 'posts';
  final String _commentsCollection = 'comments';

  /// Add a comment to a post
  Future<String> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    UserModel? user,
  }) async {
    final userId = user?.id ?? AuthService.instance.currentUserId ?? 'anonymous';
    final authorName = user?.displayName ?? 'Anonymous';
    final handle = user?.username ?? '@anonymous';

    final commentRef = _firestore
        .collection(_postsCollection)
        .doc(postId)
        .collection(_commentsCollection)
        .doc();

    final commentData = {
      'authorId': userId,
      'authorName': authorName,
      'handle': handle,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'parentCommentId': parentCommentId,
      'likes': <String>[],
      'likesCount': 0,
      'repliesCount': 0,
    };

    final batch = _firestore.batch();
    batch.set(commentRef, commentData);
    
    // Update post comment count
    batch.update(_firestore.collection(_postsCollection).doc(postId), {
      'comments': FieldValue.increment(1),
    });
    
    // If this is a reply to a comment, increment the parent comment's replies count
    if (parentCommentId != null) {
      batch.update(
        _firestore
            .collection(_postsCollection)
            .doc(postId)
            .collection(_commentsCollection)
            .doc(parentCommentId),
        {
          'repliesCount': FieldValue.increment(1),
        },
      );
    }

    await batch.commit();
    return commentRef.id;
  }

  /// Get comments for a post (real-time stream)
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection(_postsCollection)
        .doc(postId)
        .collection(_commentsCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _commentFromDoc(doc)).toList();
    });
  }

  /// Like a comment
  Future<void> likeComment(String postId, String commentId, String userId) async {
    final commentRef = _firestore
        .collection(_postsCollection)
        .doc(postId)
        .collection(_commentsCollection)
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) return;

    final data = commentDoc.data()!;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      // Unlike
      likes.remove(userId);
      await commentRef.update({
        'likes': likes,
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      likes.add(userId);
      await commentRef.update({
        'likes': likes,
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    final batch = _firestore.batch();
    
    // Delete the comment
    batch.delete(_firestore
        .collection(_postsCollection)
        .doc(postId)
        .collection(_commentsCollection)
        .doc(commentId));
    
    // Update post comment count
    batch.update(_firestore.collection(_postsCollection).doc(postId), {
      'comments': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Convert Firestore document to Comment
  Comment _commentFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Timestamp? timestamp;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        timestamp = data['timestamp'] as Timestamp;
      } else if (data['timestamp'] is Map) {
        // Handle server timestamp placeholder
        timestamp = null;
      }
    }
    
    return Comment(
      id: doc.id,
      authorId: data['authorId'] as String? ?? 'anonymous',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      handle: data['handle'] as String? ?? '@anonymous',
      text: data['text'] as String? ?? '',
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      parentCommentId: data['parentCommentId'] as String?,
      likes: (data['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      likesCount: (data['likesCount'] as int?) ?? 0,
      repliesCount: (data['repliesCount'] as int?) ?? 0,
    );
  }
}

