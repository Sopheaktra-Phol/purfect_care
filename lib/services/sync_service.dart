import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';
import 'database_service.dart';
import 'firebase_database_service.dart';

/// Service to sync data between local (Hive) and cloud (Firebase)
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _firebaseDb = FirebaseDatabaseService();

  /// Initialize and authenticate with Firebase
  Future<bool> initialize() async {
    try {
      // Sign in anonymously if not already authenticated
      if (!_firebaseDb.isAuthenticated) {
        final result = await _firebaseDb.signInAnonymously();
        if (result == null) {
          print('Failed to authenticate with Firebase');
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error initializing Firebase: $e');
      return false;
    }
  }

  /// Sync all data from local to Firebase
  Future<void> syncToFirebase() async {
    if (!_firebaseDb.isAuthenticated) {
      await initialize();
    }

    try {
      // Sync pets
      final localPets = DatabaseService.getAllPets();
      for (var pet in localPets) {
        if (pet.id != null) {
          // Check if pet exists in Firebase
          final firebasePets = await _firebaseDb.getAllPets();
          final exists = firebasePets.any((p) => p.id == pet.id);
          if (!exists) {
            await _firebaseDb.addPet(pet);
          }
        }
      }

      // Sync reminders
      final localReminders = DatabaseService.getAllReminders();
      for (var reminder in localReminders) {
        if (reminder.id != null) {
          final firebaseReminders = await _firebaseDb.getAllReminders();
          final exists = firebaseReminders.any((r) => r.id == reminder.id);
          if (!exists) {
            await _firebaseDb.addReminder(reminder);
          }
        }
      }

      // Sync health records
      final localRecords = DatabaseService.getAllHealthRecords();
      for (var record in localRecords) {
        if (record.id != null) {
          final firebaseRecords = await _firebaseDb.getAllHealthRecords();
          final exists = firebaseRecords.any((r) => r.id == record.id);
          if (!exists) {
            await _firebaseDb.addHealthRecord(record);
          }
        }
      }
    } catch (e) {
      print('Error syncing to Firebase: $e');
    }
  }

  /// Sync all data from Firebase to local
  Future<void> syncFromFirebase() async {
    if (!_firebaseDb.isAuthenticated) {
      await initialize();
    }

    try {
      // Sync pets
      final firebasePets = await _firebaseDb.getAllPets();
      for (var pet in firebasePets) {
        if (pet.id != null) {
          final localPets = DatabaseService.getAllPets();
          final exists = localPets.any((p) => p.id == pet.id);
          if (!exists) {
            await DatabaseService.addPet(pet);
          }
        }
      }

      // Sync reminders
      final firebaseReminders = await _firebaseDb.getAllReminders();
      for (var reminder in firebaseReminders) {
        if (reminder.id != null) {
          final localReminders = DatabaseService.getAllReminders();
          final exists = localReminders.any((r) => r.id == reminder.id);
          if (!exists) {
            await DatabaseService.addReminder(reminder);
          }
        }
      }

      // Sync health records
      final firebaseRecords = await _firebaseDb.getAllHealthRecords();
      for (var record in firebaseRecords) {
        if (record.id != null) {
          final localRecords = DatabaseService.getAllHealthRecords();
          final exists = localRecords.any((r) => r.id == record.id);
          if (!exists) {
            await DatabaseService.addHealthRecord(record);
          }
        }
      }
    } catch (e) {
      print('Error syncing from Firebase: $e');
    }
  }

  /// Two-way sync (merge local and Firebase data)
  Future<void> syncBothWays() async {
    await syncFromFirebase();
    await syncToFirebase();
  }
}

