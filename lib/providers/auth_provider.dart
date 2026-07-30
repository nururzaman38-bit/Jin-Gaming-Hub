import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Manages authentication state and user profile data.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // ── Getters ─────────────────────────────────────────────
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  // ── Auth State Stream ───────────────────────────────────
  /// Listen to Firebase auth state and auto-fetch the user profile.
  void listenToAuthState() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          _user = await _authService.fetchUserProfile(firebaseUser.uid);
        } catch (_) {
          _user = null;
        }
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // ── Sign Up ─────────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ───────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.login(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Google Sign-In ──────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.signInWithGoogle();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Forgot Password ─────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Profile ──────────────────────────────────────
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.updateProfile(
        uid: _user!.uid,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ─────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
