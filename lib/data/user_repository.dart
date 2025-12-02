import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Create a new user document
  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.id).set(user.toMap());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.id).update(
      user.copyWith(updatedAt: DateTime.now()).toMap(),
    );
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection(_collection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final query = await _firestore
        .collection(_collection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    return UserModel.fromMap(query.docs.first.data());
  }

  /// Follow a user
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();
    
    // Add to current user's following list
    batch.update(
      _firestore.collection(_collection).doc(currentUserId),
      {
        'following': FieldValue.increment(1),
      },
    );
    
    // Add to target user's followers list
    batch.update(
      _firestore.collection(_collection).doc(targetUserId),
      {
        'followers': FieldValue.increment(1),
      },
    );
    
    // Add to current user's following subcollection
    batch.set(
      _firestore
          .collection(_collection)
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId),
      {'followedAt': FieldValue.serverTimestamp()},
    );
    
    // Add to target user's followers subcollection
    batch.set(
      _firestore
          .collection(_collection)
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId),
      {'followedAt': FieldValue.serverTimestamp()},
    );
    
    await batch.commit();
  }

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();
    
    // Remove from current user's following list
    batch.update(
      _firestore.collection(_collection).doc(currentUserId),
      {
        'following': FieldValue.increment(-1),
      },
    );
    
    // Remove from target user's followers list
    batch.update(
      _firestore.collection(_collection).doc(targetUserId),
      {
        'followers': FieldValue.increment(-1),
      },
    );
    
    // Remove from current user's following subcollection
    batch.delete(
      _firestore
          .collection(_collection)
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId),
    );
    
    // Remove from target user's followers subcollection
    batch.delete(
      _firestore
          .collection(_collection)
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId),
    );
    
    await batch.commit();
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();
    return doc.exists;
  }

  /// Get followers list
  Stream<List<UserModel>> getFollowers(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('followers')
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      if (userIds.isEmpty) return [];
      
      final users = <UserModel>[];
      for (final id in userIds) {
        final user = await getUser(id);
        if (user != null) users.add(user);
      }
      return users;
    });
  }

  /// Get following list
  Stream<List<UserModel>> getFollowing(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      if (userIds.isEmpty) return [];
      
      final users = <UserModel>[];
      for (final id in userIds) {
        final user = await getUser(id);
        if (user != null) users.add(user);
      }
      return users;
    });
  }
}

