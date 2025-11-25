import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';
import 'database_service.dart';
import 'firebase_database_service.dart';

/// Hybrid service that saves to both local (Hive) and Firebase
class HybridDatabaseService {
  static final HybridDatabaseService _instance = HybridDatabaseService._internal();
  factory HybridDatabaseService() => _instance;
  HybridDatabaseService._internal();

  final _firebaseDb = FirebaseDatabaseService();
  bool _useFirebase = false;

  /// Initialize Firebase connection
  Future<void> initialize() async {
    try {
      if (!_firebaseDb.isAuthenticated) {
        final result = await _firebaseDb.signInAnonymously();
        _useFirebase = result != null;
        
        if (!_useFirebase) {
          print('⚠️ Firebase authentication failed. App will work in local-only mode.');
          print('To enable Firebase sync:');
          print('1. Go to Firebase Console → Authentication → Sign-in method');
          print('2. Enable "Anonymous" authentication');
          print('3. Restart the app');
        } else {
          print('✅ Firebase connected successfully');
        }
      } else {
        _useFirebase = true;
        print('✅ Firebase already authenticated');
      }
    } catch (e) {
      print('Firebase initialization failed, using local only: $e');
      _useFirebase = false;
    }
  }

  bool get isFirebaseEnabled => _useFirebase && _firebaseDb.isAuthenticated;

  // ============================================
  // PETS
  // ============================================

  Future<int> addPet(PetModel pet) async {
    // Always save locally first
    final localId = await DatabaseService.addPet(pet);
    pet.id = localId;

    // Also save to Firebase if available
    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.addPet(pet);
      } catch (e) {
        print('Failed to save pet to Firebase: $e');
      }
    }

    return localId;
  }

  List<PetModel> getAllPets() {
    // Always return from local (faster, works offline)
    return DatabaseService.getAllPets();
  }

  Future<void> updatePet(int id, PetModel pet) async {
    // Update locally
    await DatabaseService.updatePet(id, pet);

    // Update Firebase if available
    if (isFirebaseEnabled) {
      try {
        // Try to find the pet in Firebase by matching data, or create if not exists
        final firebasePets = await _firebaseDb.getAllPets();
        final firebasePet = firebasePets.firstWhere(
          (p) => p.id == id,
          orElse: () => PetModel(name: '', species: '', gender: '', age: 0, breed: ''),
        );
        
        if (firebasePet.id != null) {
          // Pet exists in Firebase, update it
          await _firebaseDb.updatePet(id.toString(), pet);
        } else {
          // Pet doesn't exist in Firebase, add it
          await _firebaseDb.addPet(pet);
        }
      } catch (e) {
        print('Failed to update pet in Firebase: $e');
        // If update fails, try to add it
        try {
          await _firebaseDb.addPet(pet);
        } catch (addError) {
          print('Failed to add pet to Firebase: $addError');
        }
      }
    }
  }

  Future<void> deletePet(int id) async {
    // Delete locally
    await DatabaseService.deletePet(id);

    // Delete from Firebase if available
    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.deletePet(id.toString());
      } catch (e) {
        print('Failed to delete pet from Firebase: $e');
      }
    }
  }

  // ============================================
  // REMINDERS
  // ============================================

  Future<int> addReminder(ReminderModel reminder) async {
    // Always save locally first
    final localId = await DatabaseService.addReminder(reminder);
    reminder.id = localId;

    // Also save to Firebase if available
    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.addReminder(reminder);
      } catch (e) {
        print('Failed to save reminder to Firebase: $e');
      }
    }

    return localId;
  }

  List<ReminderModel> getAllReminders() {
    return DatabaseService.getAllReminders();
  }

  Future<void> updateReminder(int id, ReminderModel reminder) async {
    await DatabaseService.updateReminder(id, reminder);

    if (isFirebaseEnabled) {
      try {
        final firebaseReminders = await _firebaseDb.getAllReminders();
        final exists = firebaseReminders.any((r) => r.id == id);
        if (exists) {
          await _firebaseDb.updateReminder(id.toString(), reminder);
        } else {
          await _firebaseDb.addReminder(reminder);
        }
      } catch (e) {
        print('Failed to update reminder in Firebase: $e');
        try {
          await _firebaseDb.addReminder(reminder);
        } catch (addError) {
          print('Failed to add reminder to Firebase: $addError');
        }
      }
    }
  }

  Future<void> deleteReminder(int id) async {
    await DatabaseService.deleteReminder(id);

    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.deleteReminder(id.toString());
      } catch (e) {
        print('Failed to delete reminder from Firebase: $e');
      }
    }
  }

  // ============================================
  // HEALTH RECORDS
  // ============================================

  Future<int> addHealthRecord(HealthRecordModel record) async {
    final localId = await DatabaseService.addHealthRecord(record);
    record.id = localId;

    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.addHealthRecord(record);
      } catch (e) {
        print('Failed to save health record to Firebase: $e');
      }
    }

    return localId;
  }

  List<HealthRecordModel> getAllHealthRecords() {
    return DatabaseService.getAllHealthRecords();
  }

  Future<void> updateHealthRecord(int id, HealthRecordModel record) async {
    await DatabaseService.updateHealthRecord(id, record);

    if (isFirebaseEnabled) {
      try {
        final firebaseRecords = await _firebaseDb.getAllHealthRecords();
        final exists = firebaseRecords.any((r) => r.id == id);
        if (exists) {
          await _firebaseDb.updateHealthRecord(id.toString(), record);
        } else {
          await _firebaseDb.addHealthRecord(record);
        }
      } catch (e) {
        print('Failed to update health record in Firebase: $e');
        try {
          await _firebaseDb.addHealthRecord(record);
        } catch (addError) {
          print('Failed to add health record to Firebase: $addError');
        }
      }
    }
  }

  Future<void> deleteHealthRecord(int id) async {
    await DatabaseService.deleteHealthRecord(id);

    if (isFirebaseEnabled) {
      try {
        await _firebaseDb.deleteHealthRecord(id.toString());
      } catch (e) {
        print('Failed to delete health record from Firebase: $e');
      }
    }
  }
}

