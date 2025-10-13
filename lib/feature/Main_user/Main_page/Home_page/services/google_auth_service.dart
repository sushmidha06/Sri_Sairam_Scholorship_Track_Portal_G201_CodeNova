import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship/feature/Main_user/Main_page/Home_page/services/firebase_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Start Google Sign-In without pre-signing out (this can cause issues)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Get authentication details - simplified approach
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Validate tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain valid authentication tokens');
      }

      print('Authentication tokens obtained successfully');

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase authentication successful for user: ${userCredential.user?.email}');
      
      // Save user profile to Firestore
      if (userCredential.user != null) {
        try {
          await FirestoreService.saveGoogleUserProfile(userCredential.user!);
          print('User profile saved to Firestore successfully');
        } catch (e) {
          print('Firestore save error: $e');
          // Don't throw - authentication was successful
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('Google Sign-In error: ${e.toString()}');
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign out from Google and Firebase
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Check if user is currently signed in with Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user
  static GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }

  /// Handle Firebase Auth exceptions
  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this project.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this account.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}