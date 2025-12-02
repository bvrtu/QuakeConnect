import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../data/user_repository.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserRepository _userRepo = UserRepository.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Register with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final defaultUsername = '@${email.split('@')[0]}';
      final userModel = UserModel.fromFirebaseAuth(
        userCredential.user!.uid,
        email,
        displayName,
        userCredential.user!.photoURL,
      ).copyWith(
        username: username ?? defaultUsername,
      );

      await _userRepo.createUser(userModel);

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login with email and password
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      // Get user data from Firestore
      final userModel = await _userRepo.getUser(userCredential.user!.uid);
      return userModel;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Sign out (alias for logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    await user.updatePassword(newPassword);
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    
    // Delete user data from Firestore
    await _userRepo.deleteUser(user.uid);
    
    // Delete user from Firebase Auth
    await user.delete();
  }

  /// Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _userRepo.getUser(userId);
  }
}

