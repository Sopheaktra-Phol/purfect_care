import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Centralized Firebase initialization service
class FirebaseInitService {
  static bool _isInitializing = false;
  static bool _isInitialized = false;

  /// Check if Firebase is initialized
  static bool get isInitialized {
    _isInitialized = Firebase.apps.isNotEmpty;
    return _isInitialized;
  }

  /// Initialize Firebase with retry logic
  /// Returns true if successful, false otherwise
  static Future<bool> initialize({int maxRetries = 3}) async {
    // If already initialized, return true
    if (Firebase.apps.isNotEmpty) {
      _isInitialized = true;
      print('✅ Firebase already initialized');
      return true;
    }

    // If already initializing, wait for it
    if (_isInitializing) {
      print('⏳ Firebase initialization already in progress, waiting...');
      int waitCount = 0;
      while (_isInitializing && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (Firebase.apps.isNotEmpty) {
          _isInitialized = true;
          _isInitializing = false;
          return true;
        }
        waitCount++;
      }
      // If we've been waiting too long, reset and try again
      if (_isInitializing) {
        _isInitializing = false;
      }
    }

    _isInitializing = true;
    int retryCount = 0;
    bool isPlatformChannelError = false;

    while (retryCount < maxRetries) {
      try {
        print('🔄 Initializing Firebase (attempt ${retryCount + 1}/$maxRetries)...');
        
        // Add a small delay before first attempt to ensure platform is ready
        if (retryCount == 0) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Wait a moment for initialization to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Verify initialization
        if (Firebase.apps.isNotEmpty) {
          _isInitialized = true;
          _isInitializing = false;
          print('✅ Firebase initialized successfully');
          print('   Project: ${Firebase.apps.first.options.projectId}');
          print('   App ID: ${Firebase.apps.first.options.appId}');
          return true;
        } else {
          throw Exception('Firebase.initializeApp completed but no apps found');
        }
      } catch (e) {
        retryCount++;
        final errorString = e.toString().toLowerCase();
        isPlatformChannelError = errorString.contains('channel') || 
                                  errorString.contains('platformexception');
        
        if (isPlatformChannelError) {
          print('❌ Firebase initialization attempt $retryCount failed: Platform channel error');
          print('⚠️ This usually means the iOS app needs to be rebuilt.');
          if (retryCount < maxRetries) {
            // Wait longer for platform channel errors
            print('   Waiting 3 seconds before retry...');
            await Future.delayed(const Duration(seconds: 3));
          }
        } else {
          print('❌ Firebase initialization attempt $retryCount failed: $e');
          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }
    }

    _isInitializing = false;
    
    if (isPlatformChannelError) {
      print('❌ Failed to initialize Firebase after $maxRetries attempts');
      print('');
      print('🔧 PLATFORM CHANNEL ERROR - iOS Build Fix Required:');
      print('   1. Stop the app completely');
      print('   2. Run: flutter clean');
      print('   3. Run: cd ios && rm -rf Pods Podfile.lock && pod install && cd ..');
      print('   4. Run: flutter pub get');
      print('   5. Restart the iOS simulator');
      print('   6. Run: flutter run');
      print('   OR try building from Xcode: open ios/Runner.xcworkspace');
      print('');
    } else {
      print('❌ Failed to initialize Firebase after $maxRetries attempts');
    }
    
    return false;
  }

  /// Ensure Firebase is initialized, attempting initialization if needed
  /// This is safe to call multiple times
  /// Returns true if initialized, false if it failed
  static Future<bool> ensureInitialized({bool silent = false}) async {
    if (isInitialized) {
      return true;
    }
    
    // Don't retry if we've already failed multiple times
    // This prevents infinite retry loops
    if (!silent && !_isInitializing) {
      return await initialize(maxRetries: 2); // Reduced retries for on-demand init
    }
    
    return false;
  }
}

