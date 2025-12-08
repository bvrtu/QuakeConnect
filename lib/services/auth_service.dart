import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import '../models/user_model.dart';
import '../data/user_repository.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // iOS specific configuration - use serverClientId from GoogleService-Info.plist
    // Android doesn't need serverClientId, it uses the OAuth client from google-services.json
    serverClientId: Platform.isIOS 
        ? '430371063688-aeaq1ri8opbmllmkc1c4buo4i96vlq30.apps.googleusercontent.com'
        : null,
    hostedDomain: null,
    signInOption: SignInOption.standard,
  );
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

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user document in Firestore
      // Username will be set during onboarding, use email-based default for now
      final defaultUsername = '@${email.split('@')[0]}';
      final userModel = UserModel.fromFirebaseAuth(
        userCredential.user!.uid,
        email,
        displayName,
        userCredential.user!.photoURL,
      ).copyWith(
        username: defaultUsername,
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

  /// Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    if (user.emailVerified) {
      throw Exception('Email already verified');
    }
    await user.sendEmailVerification();
  }

  /// Reload user to check if email is verified
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    await user.reload();
  }

  /// Check if email is verified (reloads user first)
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // For iOS, ensure we sign out any previous session first
      if (Platform.isIOS) {
        await _googleSignIn.signOut();
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Ensure we have both accessToken and idToken
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication failed: Missing tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign-in failed');
      }

      final user = userCredential.user!;
      
      // Check if user already exists in Firestore
      UserModel? userModel = await _userRepo.getUser(user.uid);
      
      if (userModel == null) {
        // New user - create user document in Firestore
        final defaultUsername = '@${user.email?.split('@')[0] ?? 'user'}';
        userModel = UserModel.fromFirebaseAuth(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'User',
          user.photoURL,
        ).copyWith(
          username: defaultUsername,
        );
        
        await _userRepo.createUser(userModel);
      } else {
        // Existing user - update photoURL if it changed
        if (user.photoURL != null && user.photoURL != userModel.photoURL) {
          final updatedUser = userModel.copyWith(photoURL: user.photoURL);
          await _userRepo.updateUser(updatedUser);
          userModel = updatedUser;
        }
      }

      return userModel;
    } catch (e) {
      // Sign out from Google Sign In on error to prevent stuck state
      if (Platform.isIOS) {
        await _googleSignIn.signOut();
      }
      throw Exception('Google sign-in failed: $e');
    }
  }
}

