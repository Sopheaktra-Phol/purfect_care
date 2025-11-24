import 'package:purfect_care/services/firebase_database_service.dart';
import 'package:purfect_care/services/hybrid_database_service.dart';

/// Utility to check Firebase connection status
class FirebaseConnectionChecker {
  static Future<Map<String, dynamic>> checkConnection() async {
    final results = <String, dynamic>{
      'firebaseInitialized': false,
      'authenticated': false,
      'userId': null,
      'hybridServiceEnabled': false,
      'errors': <String>[],
    };

    try {
      // Check Firebase Database Service
      final firebaseService = FirebaseDatabaseService();
      results['firebaseInitialized'] = true;
      results['authenticated'] = firebaseService.isAuthenticated;
      results['userId'] = firebaseService.userId;

      // Check Hybrid Service
      final hybridService = HybridDatabaseService();
      results['hybridServiceEnabled'] = hybridService.isFirebaseEnabled;

      // Try to authenticate if not already
      if (!firebaseService.isAuthenticated) {
        final authResult = await firebaseService.signInAnonymously();
        if (authResult != null) {
          results['authenticated'] = true;
          results['userId'] = firebaseService.userId;
        } else {
          results['errors'].add('Failed to authenticate with Firebase');
        }
      }

      // Test Firestore connection by trying to read
      if (firebaseService.isAuthenticated) {
        try {
          await firebaseService.getAllPets();
          results['firestoreReadable'] = true;
        } catch (e) {
          results['errors'].add('Firestore read error: $e');
          results['firestoreReadable'] = false;
        }
      }

      results['success'] = results['authenticated'] == true && 
                          results['hybridServiceEnabled'] == true &&
                          (results['errors'] as List).isEmpty;
    } catch (e) {
      results['errors'].add('Connection check failed: $e');
      results['success'] = false;
    }

    return results;
  }

  static void printConnectionStatus(Map<String, dynamic> status) {
    print('=== Firebase Connection Status ===');
    print('Firebase Initialized: ${status['firebaseInitialized']}');
    print('Authenticated: ${status['authenticated']}');
    print('User ID: ${status['userId']}');
    print('Hybrid Service Enabled: ${status['hybridServiceEnabled']}');
    if (status['firestoreReadable'] != null) {
      print('Firestore Readable: ${status['firestoreReadable']}');
    }
    if ((status['errors'] as List).isNotEmpty) {
      print('Errors:');
      for (var error in status['errors'] as List) {
        print('  - $error');
      }
    }
    print('Overall Status: ${status['success'] ? "✅ CONNECTED" : "❌ NOT CONNECTED"}');
    print('===================================');
  }
}

