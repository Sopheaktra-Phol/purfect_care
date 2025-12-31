import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/email_validator.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Set initial user
    try {
      _user = _auth.currentUser;
      print('AuthProvider initialized with Firebase Auth');
    } catch (e) {
      print('Warning: Could not get current user during initialization: $e');
      _user = null;
    }
    
    // Delay auth state listener to ensure Firebase is fully initialized
    // This prevents platform channel errors during initialization
    Future.delayed(const Duration(milliseconds: 800), () {
      _initializeAuthListener();
    });
  }
  
  void _initializeAuthListener() {
    try {
      // Check if Firebase is available
      if (Firebase.apps.isEmpty) {
        print('Warning: Firebase apps not available, retrying auth listener setup...');
        Future.delayed(const Duration(seconds: 1), () => _initializeAuthListener());
        return;
      }
      
      // Listen to auth state changes
      _auth.authStateChanges().listen(
        (User? user) {
          _user = user;
          notifyListeners();
        },
        onError: (error) {
          print('Auth state listener error: $error');
        },
      );
      print('✓ Auth state listener registered successfully');
    } catch (e) {
      print('Warning: Could not register auth state listener: $e');
      // Retry after a delay
      Future.delayed(const Duration(seconds: 1), () => _initializeAuthListener());
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    // Clear any existing user before attempting login to prevent using cached session
    final previousUser = _user;
    _user = null;
    notifyListeners();

    try {
      // Validate email format
      final emailError = EmailValidator.validateEmail(email);
      if (emailError != null) {
        _errorMessage = emailError;
        _isLoading = false;
        // Restore previous user if validation fails (might be from cached session)
        _user = previousUser;
        notifyListeners();
        return false;
      }

      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Only set user if login was successful and email matches
      if (userCredential.user != null && userCredential.user!.email?.toLowerCase() == email.trim().toLowerCase()) {
        _user = userCredential.user;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Login didn't return expected user
        _isLoading = false;
        _errorMessage = 'Sign in failed. Please try again.';
        _user = null;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      // Ensure user is cleared on authentication failure
      _user = null;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          _errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          _errorMessage = 'Sign in failed: ${e.message ?? 'Unknown error'}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      // Ensure user is cleared on any error
      _user = null;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate email format
      final emailError = EmailValidator.validateEmail(email);
      if (emailError != null) {
        _errorMessage = emailError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password length
      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters long.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create account with Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _user = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Password is too weak.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email address.';
          break;
        default:
          _errorMessage = 'Sign up failed: ${e.message ?? 'Unknown error'}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    // Clear any existing user before attempting Google sign in
    _user = null;
    notifyListeners();

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        _errorMessage = null;
        _user = null;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _isLoading = false;
        _errorMessage = 'Google sign in failed: Missing authentication tokens.';
        _user = null;
        notifyListeners();
        return false;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Verify we got a valid user
      if (userCredential.user == null) {
        _isLoading = false;
        _errorMessage = 'Google sign in failed: No user returned.';
        _user = null;
        notifyListeners();
        return false;
      }
      
      _user = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _user = null;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _errorMessage = 'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          _errorMessage = 'Invalid Google sign-in credentials.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Google sign-in is not enabled. Please contact support.';
          break;
        default:
          _errorMessage = 'Google sign in failed: ${e.message ?? 'Unknown error'}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _user = null;
      print('Google Sign-In error: $e');
      _errorMessage = 'Google sign in failed. Please check your configuration and try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign in anonymously with Firebase
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = 'Anonymous sign in failed: ${e.message ?? 'Unknown error'}';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to sign in anonymously.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out.';
      notifyListeners();
    }
  }
}
