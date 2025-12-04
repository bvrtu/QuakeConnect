import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_post.dart';
import '../services/auth_service.dart';
import 'user_repository.dart';

class PostRepository {
  static final PostRepository instance = PostRepository._();
  PostRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  /// Create a new post
  Future<String> createPost({
    required CommunityPost post,
    required String userId,
  }) async {
    final docRef = await _firestore.collection(_collection).add({
      'authorId': userId,
      'authorName': post.authorName,
      'authorHandle': post.handle,
      'type': post.type.toString().split('.').last,
      'message': post.message,
      'location': post.location,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
      'shares': 0,
      'reposts': 0,
    });
    return docRef.id;
  }

  /// Get all posts (real-time stream) with like/repost status
  Stream<List<CommunityPost>> getAllPosts(String? userId) {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <CommunityPost>[];
      for (var doc in snapshot.docs) {
        final post = _postFromDoc(doc);
        if (userId != null) {
          final isLiked = await isPostLiked(doc.id, userId);
          final isReposted = await isPostReposted(doc.id, userId);
          posts.add(post.copyWith(isLiked: isLiked, isReposted: isReposted));
        } else {
          posts.add(post);
        }
      }
      return posts;
    });
  }

  /// Get posts by user ID with like/repost status
  /// Uses client-side sorting to avoid Firestore composite index requirement
  Stream<List<CommunityPost>> getPostsByUserId(String userId, String? currentUserId) {
    return _firestore
        .collection(_collection)
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <CommunityPost>[];
      for (var doc in snapshot.docs) {
        final post = _postFromDoc(doc);
        if (currentUserId != null) {
          final isLiked = await isPostLiked(doc.id, currentUserId);
          final isReposted = await isPostReposted(doc.id, currentUserId);
          posts.add(post.copyWith(isLiked: isLiked, isReposted: isReposted));
        } else {
          posts.add(post);
        }
      }
      // Sort by timestamp descending (client-side to avoid index requirement)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    });
  }

  /// Get single post by ID
  Future<CommunityPost?> getPost(String postId) async {
    final doc = await _firestore.collection(_collection).doc(postId).get();
    if (!doc.exists) return null;
    return _postFromDoc(doc);
  }

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    final batch = _firestore.batch();
    
    // Check if already liked
    final likeDoc = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();
    
    if (likeDoc.exists) {
      // Unlike
      batch.delete(_firestore
          .collection(_collection)
          .doc(postId)
          .collection('likes')
          .doc(userId));
      batch.update(_firestore.collection(_collection).doc(postId), {
        'likes': FieldValue.increment(-1),
      });
    } else {
      // Like
      batch.set(_firestore
          .collection(_collection)
          .doc(postId)
          .collection('likes')
          .doc(userId), {
        'likedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_firestore.collection(_collection).doc(postId), {
        'likes': FieldValue.increment(1),
      });
    }
    
    await batch.commit();
  }

  /// Check if user liked a post
  Future<bool> isPostLiked(String postId, String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();
    return doc.exists;
  }

  /// Repost a post
  Future<void> repostPost(String postId, String userId) async {
    final batch = _firestore.batch();
    
    // Check if already reposted
    final repostDoc = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('reposts')
        .doc(userId)
        .get();
    
    if (repostDoc.exists) {
      // Unrepost
      batch.delete(_firestore
          .collection(_collection)
          .doc(postId)
          .collection('reposts')
          .doc(userId));
      batch.update(_firestore.collection(_collection).doc(postId), {
        'reposts': FieldValue.increment(-1),
      });
    } else {
      // Repost
      batch.set(_firestore
          .collection(_collection)
          .doc(postId)
          .collection('reposts')
          .doc(userId), {
        'repostedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_firestore.collection(_collection).doc(postId), {
        'reposts': FieldValue.increment(1),
      });
    }
    
    await batch.commit();
  }

  /// Check if user reposted a post
  Future<bool> isPostReposted(String postId, String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('reposts')
        .doc(userId)
        .get();
    return doc.exists;
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    // Delete all subcollections first
    final likesSnapshot = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('likes')
        .get();
    for (var doc in likesSnapshot.docs) {
      await doc.reference.delete();
    }
    
    final repostsSnapshot = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('reposts')
        .get();
    for (var doc in repostsSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Delete comments subcollection
    final commentsSnapshot = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('comments')
        .get();
    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Delete the post
    await _firestore.collection(_collection).doc(postId).delete();
  }

  /// Convert Firestore document to CommunityPost
  CommunityPost _postFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = data['type'] as String? ?? 'info';
    final type = CommunityPostType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => CommunityPostType.info,
    );
    
    Timestamp? timestamp;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        timestamp = data['timestamp'] as Timestamp;
      } else if (data['timestamp'] is Map) {
        // Handle server timestamp placeholder
        timestamp = null;
      }
    }
    
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      handle: data['authorHandle'] as String? ?? '@unknown',
      type: type,
      message: data['message'] as String? ?? '',
      location: data['location'] as String? ?? '',
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      likes: (data['likes'] as int?) ?? 0,
      comments: (data['comments'] as int?) ?? 0,
      shares: (data['shares'] as int?) ?? 0,
      reposts: (data['reposts'] as int?) ?? 0,
      isLiked: false, // Will be set separately
      isReposted: false, // Will be set separately
    );
  }

  /// Get post with like/repost status for current user
  Future<CommunityPost> getPostWithStatus(String postId, String? userId) async {
    final post = await getPost(postId);
    if (post == null) {
      throw Exception('Post not found');
    }
    
    if (userId != null) {
      final isLiked = await isPostLiked(postId, userId);
      final isReposted = await isPostReposted(postId, userId);
      return post.copyWith(
        isLiked: isLiked,
        isReposted: isReposted,
      );
    }
    
    return post;
  }

  /// Get posts from users that the current user is following
  Stream<List<CommunityPost>> getFollowingPosts(String userId, String? currentUserId) {
    final userRepo = UserRepository.instance;
    
    // Get following list and create a stream that updates when posts change
    return userRepo.getFollowing(userId).asyncExpand((followingUsers) {
      if (followingUsers.isEmpty) {
        return Stream.value(<CommunityPost>[]);
      }
      
      final followingIds = followingUsers.map((u) => u.id).toSet();
      
      // Stream all posts and filter by following list
      return _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(200)
          .snapshots()
          .asyncMap((snapshot) async {
        final filteredPosts = <CommunityPost>[];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final authorId = data['authorId'] as String?;
          if (authorId != null && followingIds.contains(authorId)) {
            final post = _postFromDoc(doc);
            if (currentUserId != null) {
              final isLiked = await isPostLiked(doc.id, currentUserId);
              final isReposted = await isPostReposted(doc.id, currentUserId);
              filteredPosts.add(post.copyWith(isLiked: isLiked, isReposted: isReposted));
            } else {
              filteredPosts.add(post);
            }
          }
        }
        
        // Already sorted by timestamp from Firestore query
        return filteredPosts;
      });
    });
  }

  /// Get popular posts (Twitter-like algorithm)
  /// Considers: likes, reposts, comments, and recency
  Stream<List<CommunityPost>> getPopularPosts(String? userId) {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <CommunityPost>[];
      for (var doc in snapshot.docs) {
        final post = _postFromDoc(doc);
        if (userId != null) {
          final isLiked = await isPostLiked(doc.id, userId);
          final isReposted = await isPostReposted(doc.id, userId);
          posts.add(post.copyWith(isLiked: isLiked, isReposted: isReposted));
        } else {
          posts.add(post);
        }
      }
      
      // Calculate popularity score for each post
      final now = DateTime.now();
      final scoredPosts = posts.map((post) {
        final hoursSincePost = now.difference(post.timestamp).inHours;
        final recencyScore = hoursSincePost < 1 
            ? 2.0 
            : hoursSincePost < 24 
                ? 1.5 
                : hoursSincePost < 168 
                    ? 1.0 
                    : 0.5;
        
        // Weighted engagement score
        final engagementScore = (post.likes * 1.0) + 
                               (post.reposts * 2.0) + 
                               (post.comments * 1.5) + 
                               (post.shares * 0.5);
        
        // Popularity score = engagement * recency
        final popularityScore = engagementScore * recencyScore;
        
        return (post: post, score: popularityScore);
      }).toList();
      
      // Sort by popularity score (descending)
      scoredPosts.sort((a, b) => b.score.compareTo(a.score));
      
      // Return top 50 most popular posts
      return scoredPosts.take(50).map((item) => item.post).toList();
    });
  }
}

