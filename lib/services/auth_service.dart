import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

/// Handles all authentication logic and user profile CRUD.
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user (nullable)
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Auth state change stream
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // ── Sign Up ─────────────────────────────────────────────
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(displayName);

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        totalCoins: AppConstants.defaultCoins,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw Exception('Sign-up failed. Please try again.');
    }
  }

  // ── Login ───────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .update({'lastLogin': DateTime.now()});

      return await _fetchUserProfile(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // ── Google Sign-In ──────────────────────────────────────
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Check if user doc exists; if not, create it
      final doc =
          await _firestore.collection(AppConstants.usersCollection).doc(uid).get();

      if (!doc.exists) {
        final newUser = UserModel(
          uid: uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? 'Player',
          photoUrl: userCredential.user!.photoURL,
          totalCoins: AppConstants.defaultCoins,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(newUser.toMap());
        return newUser;
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'lastLogin': DateTime.now()});

      return await _fetchUserProfile(uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // ── Forgot Password ─────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Fetch User Profile ─────────────────────────────────
  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(uid).get();

    if (!doc.exists) {
      throw Exception('User profile not found.');
    }

    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Public fetch (for providers)
  Future<UserModel> fetchUserProfile(String uid) => _fetchUserProfile(uid);

  // ── Update Profile ──────────────────────────────────────
  Future<UserModel> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(updates);

    return await _fetchUserProfile(uid);
  }

  // ── Exception Mapper ────────────────────────────────────
  Exception _mapAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('This email is already registered.');
      case 'weak-password':
        return Exception('Password is too weak. Use at least 6 characters.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
