import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_init_service.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabaseService _instance = FirebaseDatabaseService._internal();
  factory FirebaseDatabaseService() => _instance;
  FirebaseDatabaseService._internal();

  // Lazy initialization to avoid errors if Firebase isn't initialized
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Check if Firebase is initialized
  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  // Lazy getters that check initialization
  FirebaseFirestore? get _firestoreInstance {
    if (!_isFirebaseInitialized) {
      return null;
    }
    return _firestore ??= FirebaseFirestore.instance;
  }

  FirebaseAuth? get _authInstance {
    if (!_isFirebaseInitialized) {
      return null;
    }
    return _auth ??= FirebaseAuth.instance;
  }

  // Get current user ID
  String? get userId {
    if (!_isFirebaseInitialized || _authInstance == null) return null;
    return _authInstance!.currentUser?.uid;
  }
  
  bool get isAuthenticated {
    if (!_isFirebaseInitialized || _authInstance == null) return false;
    return _authInstance!.currentUser != null;
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    // Ensure Firebase is initialized
    final initialized = await FirebaseInitService.ensureInitialized();
    if (!initialized) {
      print('❌ Failed to initialize Firebase. Cannot sign in anonymously.');
      return null;
    }
    
    // Reset instances to get fresh ones after initialization
    _firestore = null;
    _auth = null;
    
    if (_authInstance == null) {
      print('Firebase Auth instance is null. Cannot sign in anonymously.');
      return null;
    }
    
    try {
      return await _authInstance!.signInAnonymously();
    } catch (e) {
      // Log detailed error information
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
        print('Firebase Auth Error Details: ${e.toString()}');
        
        // Check if anonymous auth is not enabled
        if (e.code == 'operation-not-allowed' || 
            e.code == 'auth/operation-not-allowed') {
          print('⚠️ Anonymous authentication is not enabled in Firebase Console!');
          print('Please enable it: Firebase Console → Authentication → Sign-in method → Anonymous → Enable');
        }
      } else {
        print('Error signing in anonymously: $e');
        print('Error type: ${e.runtimeType}');
      }
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    // Ensure Firebase is initialized
    final initialized = await FirebaseInitService.ensureInitialized();
    if (!initialized) {
      throw Exception('Firebase is not initialized. Please restart the app or check your Firebase configuration.');
    }
    
    // Reset instances to get fresh ones after initialization
    _firestore = null;
    _auth = null;
    
    if (_authInstance == null) {
      throw Exception('Firebase Auth instance is null. Cannot sign in.');
    }
    
    try {
      return await _authInstance!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Log the error for debugging
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      } else {
      print('Error signing in: $e');
      }
      // Re-throw the exception so it can be handled by the auth provider
      rethrow;
    }
  }

  /// Create account with email and password
  Future<UserCredential?> createAccount(String email, String password) async {
    // Ensure Firebase is initialized
    final initialized = await FirebaseInitService.ensureInitialized();
    if (!initialized) {
      throw Exception('Firebase is not initialized. Please restart the app or check your Firebase configuration.');
    }
    
    // Reset instances to get fresh ones after initialization
    _firestore = null;
    _auth = null;
    
    if (_authInstance == null) {
      throw Exception('Firebase Auth instance is null. Cannot create account.');
    }
    
    try {
      return await _authInstance!.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Log the error for debugging
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      } else {
      print('Error creating account: $e');
      }
      // Re-throw the exception so it can be handled by the auth provider
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure Firebase is initialized
      final initialized = await FirebaseInitService.ensureInitialized();
      if (!initialized) {
        throw Exception('Firebase is not initialized. Please restart the app or check your Firebase configuration.');
      }
      
      // Reset instances to get fresh ones after initialization
      _firestore = null;
      _auth = null;
      _storage = null;
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
      return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      if (_authInstance == null) {
        throw Exception('Firebase Auth instance is null. Cannot sign in with Google.');
      }
      return await _authInstance!.signInWithCredential(credential);
    } catch (e) {
      // Log the error for debugging
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      } else {
        print('Error signing in with Google: $e');
      }
      // Re-throw the exception so it can be handled by the auth provider
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Sign out from Google
    await _googleSignIn.signOut();
    // Sign out from Firebase
    if (_isFirebaseInitialized && _authInstance != null) {
      await _authInstance!.signOut();
    }
  }

  // ============================================
  // PETS
  // ============================================

  /// Get user's pets collection reference
  CollectionReference? _getPetsCollection() {
    if (!_isFirebaseInitialized || _firestoreInstance == null) {
      return null;
    }
    final uid = userId;
    if (uid == null) return null;
    return _firestoreInstance!.collection('users').doc(uid).collection('pets');
  }

  /// Add pet to Firestore
  Future<String?> addPet(PetModel pet) async {
    final collection = _getPetsCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot add pet.');
      return null;
    }
    try {
      final docRef = await collection.add(_petToMap(pet));
      return docRef.id;
    } catch (e) {
      print('Error adding pet: $e');
      return null;
    }
  }

  /// Get all pets from Firestore
  Future<List<PetModel>> getAllPets() async {
    final collection = _getPetsCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot get pets.');
      return [];
    }
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => _petFromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting pets: $e');
      return [];
    }
  }

  /// Find Firebase document ID by int ID (hash)
  Future<String?> _findPetDocumentId(int intId) async {
    final collection = _getPetsCollection();
    if (collection == null) return null;
    try {
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        final pet = _petFromMap(doc.id, doc.data() as Map<String, dynamic>);
        if (pet.id == intId) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print('Error finding pet document ID: $e');
      return null;
    }
  }

  /// Update pet in Firestore by int ID
  Future<void> updatePet(String petIdOrInt, PetModel pet) async {
    final collection = _getPetsCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot update pet.');
    }
    try {
      // Try to parse as int - if it's an int ID, find the document
      final intId = int.tryParse(petIdOrInt);
      String? documentId;
      
      if (intId != null) {
        // It's an int ID, find the Firebase document ID
        documentId = await _findPetDocumentId(intId);
        if (documentId == null) {
          throw Exception('Pet with ID $intId not found in Firebase');
        }
      } else {
        // It's already a Firebase document ID
        documentId = petIdOrInt;
      }
      
      await collection.doc(documentId).update(_petToMap(pet));
    } catch (e) {
      print('Error updating pet: $e');
      rethrow;
    }
  }

  /// Delete pet from Firestore by int ID
  Future<void> deletePet(String petIdOrInt) async {
    final collection = _getPetsCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot delete pet.');
    }
    try {
      // Try to parse as int - if it's an int ID, find the document
      final intId = int.tryParse(petIdOrInt);
      String? documentId;
      
      if (intId != null) {
        // It's an int ID, find the Firebase document ID
        documentId = await _findPetDocumentId(intId);
        if (documentId == null) {
          throw Exception('Pet with ID $intId not found in Firebase');
        }
      } else {
        // It's already a Firebase document ID
        documentId = petIdOrInt;
      }
      
      await collection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting pet: $e');
      rethrow;
    }
  }

  // ============================================
  // REMINDERS
  // ============================================

  /// Get user's reminders collection reference
  CollectionReference? _getRemindersCollection() {
    if (!_isFirebaseInitialized || _firestoreInstance == null) {
      return null;
    }
    final uid = userId;
    if (uid == null) return null;
    return _firestoreInstance!.collection('users').doc(uid).collection('reminders');
  }

  /// Add reminder to Firestore
  Future<String?> addReminder(ReminderModel reminder) async {
    final collection = _getRemindersCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot add reminder.');
      return null;
    }
    try {
      final docRef = await collection.add(_reminderToMap(reminder));
      return docRef.id;
    } catch (e) {
      print('Error adding reminder: $e');
      return null;
    }
  }

  /// Get all reminders from Firestore
  Future<List<ReminderModel>> getAllReminders() async {
    final collection = _getRemindersCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot get reminders.');
      return [];
    }
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => _reminderFromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting reminders: $e');
      return [];
    }
  }

  /// Find reminder Firebase document ID by int ID
  Future<String?> _findReminderDocumentId(int intId) async {
    final collection = _getRemindersCollection();
    if (collection == null) return null;
    try {
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        final reminder = _reminderFromMap(doc.id, doc.data() as Map<String, dynamic>);
        if (reminder.id == intId) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print('Error finding reminder document ID: $e');
      return null;
    }
  }

  /// Update reminder in Firestore by int ID
  Future<void> updateReminder(String reminderIdOrInt, ReminderModel reminder) async {
    final collection = _getRemindersCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot update reminder.');
    }
    try {
      final intId = int.tryParse(reminderIdOrInt);
      String? documentId;
      
      if (intId != null) {
        documentId = await _findReminderDocumentId(intId);
        if (documentId == null) {
          throw Exception('Reminder with ID $intId not found in Firebase');
        }
      } else {
        documentId = reminderIdOrInt;
      }
      
      await collection.doc(documentId).update(_reminderToMap(reminder));
    } catch (e) {
      print('Error updating reminder: $e');
      rethrow;
    }
  }

  /// Delete reminder from Firestore by int ID
  Future<void> deleteReminder(String reminderIdOrInt) async {
    final collection = _getRemindersCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot delete reminder.');
    }
    try {
      final intId = int.tryParse(reminderIdOrInt);
      String? documentId;
      
      if (intId != null) {
        documentId = await _findReminderDocumentId(intId);
        if (documentId == null) {
          throw Exception('Reminder with ID $intId not found in Firebase');
        }
      } else {
        documentId = reminderIdOrInt;
      }
      
      await collection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }

  // ============================================
  // HEALTH RECORDS
  // ============================================

  /// Get user's health records collection reference
  CollectionReference? _getHealthRecordsCollection() {
    if (!_isFirebaseInitialized || _firestoreInstance == null) {
      return null;
    }
    final uid = userId;
    if (uid == null) return null;
    return _firestoreInstance!.collection('users').doc(uid).collection('healthRecords');
  }

  /// Add health record to Firestore
  Future<String?> addHealthRecord(HealthRecordModel record) async {
    final collection = _getHealthRecordsCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot add health record.');
      return null;
    }
    try {
      final docRef = await collection.add(_healthRecordToMap(record));
      return docRef.id;
    } catch (e) {
      print('Error adding health record: $e');
      return null;
    }
  }

  /// Get all health records from Firestore
  Future<List<HealthRecordModel>> getAllHealthRecords() async {
    final collection = _getHealthRecordsCollection();
    if (collection == null) {
      print('Firebase is not initialized. Cannot get health records.');
      return [];
    }
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => _healthRecordFromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting health records: $e');
      return [];
    }
  }

  /// Find health record Firebase document ID by int ID
  Future<String?> _findHealthRecordDocumentId(int intId) async {
    final collection = _getHealthRecordsCollection();
    if (collection == null) return null;
    try {
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        final record = _healthRecordFromMap(doc.id, doc.data() as Map<String, dynamic>);
        if (record.id == intId) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print('Error finding health record document ID: $e');
      return null;
    }
  }

  /// Update health record in Firestore by int ID
  Future<void> updateHealthRecord(String recordIdOrInt, HealthRecordModel record) async {
    final collection = _getHealthRecordsCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot update health record.');
    }
    try {
      final intId = int.tryParse(recordIdOrInt);
      String? documentId;
      
      if (intId != null) {
        documentId = await _findHealthRecordDocumentId(intId);
        if (documentId == null) {
          throw Exception('Health record with ID $intId not found in Firebase');
        }
      } else {
        documentId = recordIdOrInt;
      }
      
      await collection.doc(documentId).update(_healthRecordToMap(record));
    } catch (e) {
      print('Error updating health record: $e');
      rethrow;
    }
  }

  /// Delete health record from Firestore by int ID
  Future<void> deleteHealthRecord(String recordIdOrInt) async {
    final collection = _getHealthRecordsCollection();
    if (collection == null) {
      throw Exception('Firebase is not initialized. Cannot delete health record.');
    }
    try {
      final intId = int.tryParse(recordIdOrInt);
      String? documentId;
      
      if (intId != null) {
        documentId = await _findHealthRecordDocumentId(intId);
        if (documentId == null) {
          throw Exception('Health record with ID $intId not found in Firebase');
        }
      } else {
        documentId = recordIdOrInt;
      }
      
      await collection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting health record: $e');
      rethrow;
    }
  }

  // ============================================
  // DATA CONVERSION HELPERS
  // ============================================

  Map<String, dynamic> _petToMap(PetModel pet) {
    return {
      'name': pet.name,
      'species': pet.species,
      'gender': pet.gender,
      'age': pet.age,
      'breed': pet.breed,
      'photoPath': pet.photoPath,
      'notes': pet.notes,
    };
  }

  PetModel _petFromMap(String id, Map<String, dynamic> map) {
    // Convert Firebase String ID to int hash for compatibility
    // This ensures we can use the ID as an int in the app
    final intId = id.hashCode.abs();
    return PetModel(
      id: intId,
      name: map['name'] as String,
      species: map['species'] as String,
      gender: map['gender'] as String,
      age: map['age'] as int,
      breed: map['breed'] as String,
      photoPath: map['photoPath'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> _reminderToMap(ReminderModel reminder) {
    return {
      'petId': reminder.petId.toString(),
      'title': reminder.title,
      'time': reminder.time.toIso8601String(),
      'repeat': reminder.repeat,
      'notificationId': reminder.notificationId,
      'isCompleted': reminder.isCompleted,
    };
  }

  ReminderModel _reminderFromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id.hashCode.abs(), // Convert Firebase String ID to int hash
      petId: int.parse(map['petId'] as String),
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      repeat: map['repeat'] as String? ?? 'none',
      notificationId: map['notificationId'] as int?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _healthRecordToMap(HealthRecordModel record) {
    return {
      'petId': record.petId.toString(),
      'title': record.title,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
    };
  }

  HealthRecordModel _healthRecordFromMap(String id, Map<String, dynamic> map) {
    return HealthRecordModel(
      id: id.hashCode.abs(), // Convert Firebase String ID to int hash
      petId: int.parse(map['petId'] as String),
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}

