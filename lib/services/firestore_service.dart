import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference for users
  static CollectionReference get _usersCollection => _firestore.collection('users');

  /// Save or update user profile data in Firestore
  static Future<void> saveUserProfile({
    String? displayName,
    String? email,
    String? photoURL,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user found for Firestore save');
        return;
      }

      print('Attempting to save user profile to Firestore for user: ${user.uid}');

      final userData = {
        'uid': user.uid,
        'email': email ?? user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': photoURL ?? user.photoURL,
        'phoneNumber': phoneNumber ?? user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'authProvider': _getAuthProvider(user),
        ...?additionalData,
      };

      // Use merge: true to create document if it doesn't exist
      await _usersCollection.doc(user.uid).set(userData, SetOptions(merge: true));
      print('✅ User profile saved successfully to Firestore');
      
      // Verify the document was created
      final doc = await _usersCollection.doc(user.uid).get();
      if (doc.exists) {
        print('✅ Document verified in Firestore: ${doc.data()}');
      } else {
        print('❌ Document not found after save attempt');
      }
    } catch (e) {
      print('❌ Failed to save user profile to Firestore: ${e.toString()}');
      // Don't throw error to prevent blocking authentication flow
    }
  }

  /// Get user profile data from Firestore
  static Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _usersCollection.doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Firestore getUserProfile error: ${e.toString()}');
      // Return null instead of throwing to allow graceful fallback
      return null;
    }
  }

  /// Update specific user profile fields
  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(user.uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Save user profile after Google Sign-In
  static Future<void> saveGoogleUserProfile(User user) async {
    try {
      await saveUserProfile(
        displayName: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
        additionalData: {
          'signInMethod': 'google',
          'emailVerified': user.emailVerified,
        },
      );
    } catch (e) {
      throw Exception('Failed to save Google user profile: ${e.toString()}');
    }
  }

  /// Save user profile after email/password registration
  static Future<void> saveEmailUserProfile(User user, String fullName) async {
    try {
      await saveUserProfile(
        displayName: fullName,
        email: user.email,
        additionalData: {
          'signInMethod': 'email',
          'emailVerified': user.emailVerified,
        },
      );
    } catch (e) {
      throw Exception('Failed to save email user profile: ${e.toString()}');
    }
  }

  /// Update user's last sign-in time
  static Future<void> updateLastSignIn() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _usersCollection.doc(user.uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail for last sign-in updates
      print('Failed to update last sign-in: ${e.toString()}');
    }
  }

  /// Get authentication provider
  static String _getAuthProvider(User user) {
    if (user.providerData.isEmpty) return 'unknown';
    
    for (final provider in user.providerData) {
      switch (provider.providerId) {
        case 'google.com':
          return 'google';
        case 'password':
          return 'email';
        case 'facebook.com':
          return 'facebook';
        case 'twitter.com':
          return 'twitter';
        default:
          continue;
      }
    }
    return 'unknown';
  }

  /// Delete user profile (for account deletion)
  static Future<void> deleteUserProfile([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user ID provided');

      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: ${e.toString()}');
    }
  }

  /// Check if user profile exists in Firestore
  static Future<bool> userProfileExists([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) return false;

      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Stream user profile data (for real-time updates)
  static Stream<Map<String, dynamic>?> getUserProfileStream([String? userId]) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _usersCollection.doc(uid).snapshots().map((doc) {
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    });
  }
}
