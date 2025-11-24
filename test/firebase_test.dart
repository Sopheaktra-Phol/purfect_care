import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purfect_care/firebase_options.dart';
import 'package:purfect_care/services/firebase_database_service.dart';
import 'package:purfect_care/services/hybrid_database_service.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/health_record_model.dart';

void main() {
  group('Firebase Database Service Tests', () {
    late FirebaseDatabaseService firebaseService;
    late HybridDatabaseService hybridService;

    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseService = FirebaseDatabaseService();
      hybridService = HybridDatabaseService();
      await hybridService.initialize();
    });

    test('Firebase authentication works', () async {
      // Test anonymous sign in
      final result = await firebaseService.signInAnonymously();
      expect(result, isNotNull);
      expect(firebaseService.isAuthenticated, isTrue);
      expect(firebaseService.userId, isNotNull);
    });

    test('Hybrid service initializes Firebase', () async {
      expect(hybridService.isFirebaseEnabled, isTrue);
    });

    test('Can add and retrieve pet from Firebase', () async {
      final testPet = PetModel(
        name: 'Test Pet',
        species: 'Dog',
        gender: 'Male',
        age: 2,
        breed: 'Golden Retriever',
        notes: 'Test pet for Firebase',
      );

      // Add via hybrid service (saves to both local and Firebase)
      final id = await hybridService.addPet(testPet);
      expect(id, isNotNull);

      // Verify it's in local database
      final localPets = hybridService.getAllPets();
      expect(localPets.any((p) => p.id == id && p.name == 'Test Pet'), isTrue);

      // Verify it's in Firebase
      final firebasePets = await firebaseService.getAllPets();
      expect(firebasePets.any((p) => p.name == 'Test Pet'), isTrue);

      // Cleanup
      await hybridService.deletePet(id);
    });

    test('Can add and retrieve reminder from Firebase', () async {
      final testReminder = ReminderModel(
        petId: 1,
        title: 'Test Reminder',
        time: DateTime.now().add(const Duration(hours: 1)),
        repeat: 'none',
      );

      final id = await hybridService.addReminder(testReminder);
      expect(id, isNotNull);

      final localReminders = hybridService.getAllReminders();
      expect(localReminders.any((r) => r.id == id && r.title == 'Test Reminder'), isTrue);

      // Cleanup
      await hybridService.deleteReminder(id);
    });

    test('Can add and retrieve health record from Firebase', () async {
      final testRecord = HealthRecordModel(
        petId: 1,
        title: 'Test Health Record',
        date: DateTime.now(),
        notes: 'Test notes',
      );

      final id = await hybridService.addHealthRecord(testRecord);
      expect(id, isNotNull);

      final localRecords = hybridService.getAllHealthRecords();
      expect(localRecords.any((r) => r.id == id && r.title == 'Test Health Record'), isTrue);

      // Cleanup
      await hybridService.deleteHealthRecord(id);
    });

    test('Firebase connection status', () {
      expect(firebaseService.isAuthenticated, isTrue);
      expect(firebaseService.userId, isNotNull);
      expect(hybridService.isFirebaseEnabled, isTrue);
    });
  });
}

