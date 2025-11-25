import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/email_validator.dart';

/// Simple user model for local auth
class LocalUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;

  LocalUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });
}

class AuthProvider extends ChangeNotifier {
  LocalUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  LocalUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Check if user was previously logged in
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedEmail = prefs.getString('userEmail');
    final savedUid = prefs.getString('userId');
    final isAnonymous = prefs.getBool('isAnonymous') ?? false;
    
    if (isLoggedIn && savedUid != null) {
      _user = LocalUser(
        uid: savedUid,
        email: savedEmail,
        isAnonymous: isAnonymous || savedEmail == null,
      );
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validate email format
    final emailError = EmailValidator.validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mock authentication - accept any valid email/password
    // In a real app, you'd validate against a backend
    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters long.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _user = LocalUser(
      uid: email.hashCode.abs().toString(),
      email: email,
      displayName: email.split('@')[0],
      isAnonymous: false,
    );
    
    await _saveLoginState(true, email: email);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validate email format
    final emailError = EmailValidator.validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple validation
    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters long.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock account creation - always succeeds
    _user = LocalUser(
      uid: email.hashCode.abs().toString(),
      email: email,
      displayName: email.split('@')[0],
      isAnonymous: false,
    );
    
    await _saveLoginState(true, email: email);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock Google sign-in - always succeeds
    _user = LocalUser(
      uid: 'google_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      displayName: 'Google User',
      isAnonymous: false,
    );
    
    await _saveLoginState(true, email: 'user@gmail.com');
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock anonymous sign-in - always succeeds
    _user = LocalUser(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: null,
      displayName: 'Guest',
      isAnonymous: true,
    );
    
    await _saveLoginState(true, email: null, isAnonymous: true);
        _isLoading = false;
        notifyListeners();
        return true;
  }

  Future<void> signOut() async {
    await _saveLoginState(false);
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveLoginState(bool isLoggedIn, {String? email, bool isAnonymous = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    if (isLoggedIn) {
      // Save userId for both email and anonymous users
      if (_user?.uid != null) {
        await prefs.setString('userId', _user!.uid);
      }
      // Save email only if provided (not for anonymous users)
      if (email != null) {
        await prefs.setString('userEmail', email);
      } else {
        await prefs.remove('userEmail');
      }
      // Save anonymous flag
      await prefs.setBool('isAnonymous', isAnonymous);
    } else {
      await prefs.remove('userEmail');
      await prefs.remove('userId');
      await prefs.remove('isAnonymous');
    }
  }

  Future<bool> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
