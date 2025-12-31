import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';
import '../models/vaccination_model.dart';
import '../models/activity_model.dart';
import '../models/expense_model.dart';
import '../models/pet_photo_model.dart';
import '../models/weight_entry_model.dart';
import '../models/milestone_model.dart';

class FirestoreDatabaseService {
  // Use the named Firestore database "purfectcare" instead of default
  static FirebaseFirestore get _firestore {
    try {
      return FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'purfectcare',
      );
    } catch (e) {
      // Fallback to default if named database doesn't exist or Firebase not initialized
      print('⚠️ Could not access "purfectcare" database, using default: $e');
      return FirebaseFirestore.instance;
    }
  }
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Initialize Firestore with persistence enabled
  static void enablePersistence() {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✓ Firestore persistence enabled');
    } catch (e) {
      print('⚠ Could not enable Firestore persistence: $e');
    }
  }
  
  /// Test Firestore connectivity
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing Firestore connection...');
      final testDoc = _firestore.collection('_test').doc('connection');
      await testDoc.set({'test': DateTime.now().toIso8601String()})
          .timeout(const Duration(seconds: 5));
      await testDoc.delete().timeout(const Duration(seconds: 2));
      print('✅ Firestore connection test successful');
      return true;
    } catch (e) {
      print('❌ Firestore connection test failed: $e');
      return false;
    }
  }

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  static void _checkAuth() {
    if (currentUserId == null) {
      throw Exception('User not authenticated. Please sign in to access data.');
    }
  }

  // ========== COLLECTION HELPERS ==========

  static CollectionReference<Map<String, dynamic>> _petsCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('pets');
  }

  static CollectionReference<Map<String, dynamic>> _remindersCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('reminders');
  }

  static CollectionReference<Map<String, dynamic>> _healthRecordsCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('healthRecords');
  }

  static CollectionReference<Map<String, dynamic>> _vaccinationsCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('vaccinations');
  }

  static CollectionReference<Map<String, dynamic>> _activitiesCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('activities');
  }

  static CollectionReference<Map<String, dynamic>> _expensesCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('expenses');
  }

  static CollectionReference<Map<String, dynamic>> _photosCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('photos');
  }

  static CollectionReference<Map<String, dynamic>> _weightEntriesCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('weightEntries');
  }

  static CollectionReference<Map<String, dynamic>> _milestonesCollection() {
    _checkAuth();
    return _firestore.collection('users').doc(currentUserId).collection('milestones');
  }

  // ========== PETS ==========

  static Future<String> addPet(PetModel pet) async {
    try {
      print('🔥 FirestoreDatabaseService.addPet called');
      print('🔥 Current user ID: ${currentUserId}');
      
      if (currentUserId == null) {
        print('❌ No user ID - user not authenticated');
        throw Exception('User not authenticated. Please sign in to access data.');
      }
      
      final petMap = _petToMap(pet);
      print('🔥 Pet map to save: $petMap');
      print('🔥 Collection path: users/$currentUserId/pets');
      
      final collection = _petsCollection();
      print('🔥 Collection reference obtained');
      
      // Attempt to write to Firestore
      try {
        print('🔥 Attempting to write to Firestore...');
        print('🔥 User ID: $currentUserId');
        print('🔥 Collection: users/$currentUserId/pets');
        
        // Write the pet document
        final docRef = await collection
            .add(petMap)
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                print('❌ Firestore addPet timed out after 20 seconds');
                throw Exception(
                  'Request timed out. This indicates a network or connectivity issue.\n\n'
                  'Please check:\n'
                  '1. Internet connection is active\n'
                  '2. Firestore database is enabled in Firebase Console\n'
                  '3. Try testing on a physical device instead of simulator\n'
                  '4. Check if firewall/VPN is blocking Firestore connections\n'
                  '5. Verify security rules are published (not just saved)'
                );
              },
            );
        
        print('✅ Pet added successfully to Firestore!');
        print('✅ Document ID: ${docRef.id}');
        print('✅ Full path: users/$currentUserId/pets/${docRef.id}');
        
        return docRef.id;
      } on FirebaseException catch (e) {
        print('❌ FirebaseException: ${e.code} - ${e.message}');
        if (e.code == 'permission-denied') {
          throw Exception('Permission denied. Please check your Firestore security rules.');
        } else if (e.code == 'unavailable') {
          throw Exception('Firestore is unavailable. Please check your internet connection.');
        } else {
          throw Exception('Firestore error: ${e.message}');
        }
      } on PlatformException catch (e) {
        print('❌ PlatformException: ${e.code} - ${e.message}');
        throw Exception('Platform error: ${e.message ?? e.code}');
      }
    } catch (e, stackTrace) {
      print('❌ Firestore addPet error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<PetModel>> getAllPets() async {
    final snapshot = await _petsCollection().get();
    return snapshot.docs.map((doc) => _petFromMap(doc.id, doc.data())).toList();
  }

  /// Get all pets with their Firestore document IDs
  static Future<List<Map<String, dynamic>>> getAllPetsWithIds() async {
    _checkAuth();
    final snapshot = await _petsCollection().get();
    return snapshot.docs.map((doc) {
      return {
        'pet': _petFromMap(doc.id, doc.data()),
        'firestoreId': doc.id,
      };
    }).toList();
  }

  static Stream<List<PetModel>> streamAllPets() {
    return _petsCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _petFromMap(doc.id, doc.data())).toList();
    });
  }

  static Future<void> updatePet(String petId, PetModel pet) async {
    await _petsCollection().doc(petId).update(_petToMap(pet));
  }

  static Future<void> deletePet(String firestorePetId, int? integerPetId) async {
    try {
      print('🗑️ FirestoreDatabaseService.deletePet called');
      print('🗑️ Firestore Pet ID: $firestorePetId');
      print('🗑️ Integer Pet ID: $integerPetId');
      print('🗑️ Current user ID: ${currentUserId}');
      
      _checkAuth();
      
      // First, verify the pet document exists (with longer timeout)
      final petDocRef = _petsCollection().doc(firestorePetId);
      final petDoc = await petDocRef.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('❌ Timeout checking if pet document exists');
          throw Exception('Timeout checking pet document. Please check your internet connection.');
        },
      );
      
      if (!petDoc.exists) {
        print('❌ Pet document does not exist: $firestorePetId');
        throw Exception('Pet not found. It may have already been deleted.');
      }
      
      print('✅ Pet document found, proceeding with deletion...');
      
      // Delete all related data
      final batch = _firestore.batch();
      int totalDeletions = 0;
      
      // Delete reminders - use integer pet ID if available, otherwise try both
      print('🗑️ Deleting reminders...');
      List<QueryDocumentSnapshot<Map<String, dynamic>>> remindersToDelete = [];
      
      if (integerPetId != null) {
        // Query by integer pet ID (stored as string in Firestore)
        final remindersSnapshot = await _remindersCollection()
            .where('petId', isEqualTo: integerPetId.toString())
            .get()
            .timeout(const Duration(seconds: 10));
        remindersToDelete = remindersSnapshot.docs;
        print('🗑️ Found ${remindersSnapshot.docs.length} reminders to delete (by integer ID)');
      } else {
        // Fallback: get all reminders and filter (less efficient but works)
        print('⚠️ No integer pet ID provided, fetching all reminders to filter...');
        final allReminders = await _remindersCollection().get().timeout(const Duration(seconds: 10));
        remindersToDelete = allReminders.docs.where((doc) {
          final data = doc.data();
          final reminderPetId = data['petId'] as String?;
          // Try to match - this is a fallback
          return reminderPetId == firestorePetId || reminderPetId == integerPetId?.toString();
        }).toList();
        print('🗑️ Found ${remindersToDelete.length} reminders to delete (by fallback)');
      }
      
      for (var doc in remindersToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }

      // Delete health records
      print('🗑️ Deleting health records...');
      final healthRecordsSnapshot = integerPetId != null
          ? await _healthRecordsCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _healthRecordsCollection().get().timeout(const Duration(seconds: 10));
      
      final healthRecordsToDelete = integerPetId != null
          ? healthRecordsSnapshot.docs
          : healthRecordsSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in healthRecordsToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${healthRecordsToDelete.length} health records to delete');

      // Delete vaccinations
      print('🗑️ Deleting vaccinations...');
      final vaccinationsSnapshot = integerPetId != null
          ? await _vaccinationsCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _vaccinationsCollection().get().timeout(const Duration(seconds: 10));
      
      final vaccinationsToDelete = integerPetId != null
          ? vaccinationsSnapshot.docs
          : vaccinationsSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in vaccinationsToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${vaccinationsToDelete.length} vaccinations to delete');

      // Delete activities
      print('🗑️ Deleting activities...');
      final activitiesSnapshot = integerPetId != null
          ? await _activitiesCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _activitiesCollection().get().timeout(const Duration(seconds: 10));
      
      final activitiesToDelete = integerPetId != null
          ? activitiesSnapshot.docs
          : activitiesSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in activitiesToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${activitiesToDelete.length} activities to delete');

      // Delete expenses
      print('🗑️ Deleting expenses...');
      final expensesSnapshot = integerPetId != null
          ? await _expensesCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _expensesCollection().get().timeout(const Duration(seconds: 10));
      
      final expensesToDelete = integerPetId != null
          ? expensesSnapshot.docs
          : expensesSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in expensesToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${expensesToDelete.length} expenses to delete');

      // Delete photos
      print('🗑️ Deleting photos...');
      final photosSnapshot = integerPetId != null
          ? await _photosCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _photosCollection().get().timeout(const Duration(seconds: 10));
      
      final photosToDelete = integerPetId != null
          ? photosSnapshot.docs
          : photosSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in photosToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${photosToDelete.length} photos to delete');

      // Delete weight entries
      print('🗑️ Deleting weight entries...');
      final weightEntriesSnapshot = integerPetId != null
          ? await _weightEntriesCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 20))
          : await _weightEntriesCollection().get().timeout(const Duration(seconds: 20));
      
      final weightEntriesToDelete = integerPetId != null
          ? weightEntriesSnapshot.docs
          : weightEntriesSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in weightEntriesToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${weightEntriesToDelete.length} weight entries to delete');

      // Delete milestones
      print('🗑️ Deleting milestones...');
      final milestonesSnapshot = integerPetId != null
          ? await _milestonesCollection()
              .where('petId', isEqualTo: integerPetId.toString())
              .get()
              .timeout(const Duration(seconds: 10))
          : await _milestonesCollection().get().timeout(const Duration(seconds: 10));
      
      final milestonesToDelete = integerPetId != null
          ? milestonesSnapshot.docs
          : milestonesSnapshot.docs.where((doc) {
              final data = doc.data();
              return data['petId'] == integerPetId?.toString();
            }).toList();
      
      for (var doc in milestonesToDelete) {
        batch.delete(doc.reference);
        totalDeletions++;
      }
      print('🗑️ Found ${milestonesToDelete.length} milestones to delete');

      // Delete the pet document itself
      batch.delete(petDocRef);
      totalDeletions++;
      
      print('🗑️ Committing batch delete ($totalDeletions total deletions)...');
      await batch.commit().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Batch commit timed out after 30 seconds');
          throw Exception('Delete operation timed out. This may be due to slow network connection. Please try again.');
        },
      );
      
      print('✅ Pet and all related data deleted successfully!');
    } on FirebaseException catch (e) {
      print('❌ FirebaseException during delete: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Check your Firestore security rules.');
      } else if (e.code == 'not-found') {
        throw Exception('Pet not found. It may have already been deleted.');
      } else {
        throw Exception('Firestore error: ${e.message}');
      }
    } on PlatformException catch (e) {
      print('❌ PlatformException during delete: ${e.code} - ${e.message}');
      throw Exception('Platform error: ${e.message ?? e.code}');
    } catch (e, stackTrace) {
      print('❌ Error deleting pet: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ========== REMINDERS ==========

  static Future<String> addReminder(ReminderModel reminder) async {
    final docRef = await _remindersCollection().add(_reminderToMap(reminder));
    return docRef.id;
  }

  static Future<List<ReminderModel>> getAllReminders() async {
    final snapshot = await _remindersCollection().get();
    return snapshot.docs
        .map((doc) => _reminderFromMap(doc.id, doc.data()))
        .toList();
  }

  static Stream<List<ReminderModel>> streamAllReminders() {
    return _remindersCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _reminderFromMap(doc.id, doc.data()))
          .toList();
    });
  }

  static Future<List<ReminderModel>> getRemindersForPet(String petId) async {
    final snapshot = await _remindersCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _reminderFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateReminder(String reminderId, ReminderModel reminder) async {
    await _remindersCollection().doc(reminderId).update(_reminderToMap(reminder));
  }

  static Future<void> deleteReminder(String reminderId) async {
    await _remindersCollection().doc(reminderId).delete();
  }

  // ========== HEALTH RECORDS ==========

  static Future<String> addHealthRecord(HealthRecordModel record) async {
    final docRef = await _healthRecordsCollection().add(_healthRecordToMap(record));
    return docRef.id;
  }

  static Future<List<HealthRecordModel>> getAllHealthRecords() async {
    final snapshot = await _healthRecordsCollection().get();
    return snapshot.docs
        .map((doc) => _healthRecordFromMap(doc.id, doc.data()))
        .toList();
  }

  static Stream<List<HealthRecordModel>> streamAllHealthRecords() {
    return _healthRecordsCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _healthRecordFromMap(doc.id, doc.data()))
          .toList();
    });
  }

  static Future<List<HealthRecordModel>> getHealthRecordsForPet(String petId) async {
    final snapshot = await _healthRecordsCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _healthRecordFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateHealthRecord(String recordId, HealthRecordModel record) async {
    await _healthRecordsCollection().doc(recordId).update(_healthRecordToMap(record));
  }

  static Future<void> deleteHealthRecord(String recordId) async {
    await _healthRecordsCollection().doc(recordId).delete();
  }

  // ========== VACCINATIONS ==========

  static Future<String> addVaccination(VaccinationModel vaccination) async {
    final docRef = await _vaccinationsCollection().add(_vaccinationToMap(vaccination));
    return docRef.id;
  }

  static Future<List<VaccinationModel>> getAllVaccinations() async {
    final snapshot = await _vaccinationsCollection().get();
    return snapshot.docs
        .map((doc) => _vaccinationFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<VaccinationModel>> getVaccinationsForPet(String petId) async {
    final snapshot = await _vaccinationsCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _vaccinationFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateVaccination(String vaccinationId, VaccinationModel vaccination) async {
    await _vaccinationsCollection().doc(vaccinationId).update(_vaccinationToMap(vaccination));
  }

  static Future<void> deleteVaccination(String vaccinationId) async {
    await _vaccinationsCollection().doc(vaccinationId).delete();
  }

  // ========== ACTIVITIES ==========

  static Future<String> addActivity(ActivityModel activity) async {
    final docRef = await _activitiesCollection().add(_activityToMap(activity));
    return docRef.id;
  }

  static Future<List<ActivityModel>> getAllActivities() async {
    final snapshot = await _activitiesCollection().get();
    return snapshot.docs
        .map((doc) => _activityFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<ActivityModel>> getActivitiesForPet(String petId) async {
    final snapshot = await _activitiesCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _activityFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateActivity(String activityId, ActivityModel activity) async {
    await _activitiesCollection().doc(activityId).update(_activityToMap(activity));
  }

  static Future<void> deleteActivity(String activityId) async {
    await _activitiesCollection().doc(activityId).delete();
  }

  // ========== EXPENSES ==========

  static Future<String> addExpense(ExpenseModel expense) async {
    final docRef = await _expensesCollection().add(_expenseToMap(expense));
    return docRef.id;
  }

  static Future<List<ExpenseModel>> getAllExpenses() async {
    final snapshot = await _expensesCollection().get();
    return snapshot.docs
        .map((doc) => _expenseFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<ExpenseModel>> getExpensesForPet(String petId) async {
    final snapshot = await _expensesCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _expenseFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateExpense(String expenseId, ExpenseModel expense) async {
    await _expensesCollection().doc(expenseId).update(_expenseToMap(expense));
  }

  static Future<void> deleteExpense(String expenseId) async {
    await _expensesCollection().doc(expenseId).delete();
  }

  // ========== PHOTOS ==========

  static Future<String> addPhoto(PetPhotoModel photo) async {
    final docRef = await _photosCollection().add(_photoToMap(photo));
    return docRef.id;
  }

  static Future<List<PetPhotoModel>> getAllPhotos() async {
    final snapshot = await _photosCollection().get();
    return snapshot.docs
        .map((doc) => _photoFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<PetPhotoModel>> getPhotosForPet(String petId) async {
    final snapshot = await _photosCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _photoFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updatePhoto(String photoId, PetPhotoModel photo) async {
    await _photosCollection().doc(photoId).update(_photoToMap(photo));
  }

  static Future<void> deletePhoto(String photoId) async {
    await _photosCollection().doc(photoId).delete();
  }

  // ========== WEIGHT ENTRIES ==========

  static Future<String> addWeightEntry(WeightEntryModel weightEntry) async {
    final docRef = await _weightEntriesCollection().add(_weightEntryToMap(weightEntry));
    return docRef.id;
  }

  static Future<List<WeightEntryModel>> getAllWeightEntries() async {
    final snapshot = await _weightEntriesCollection().get();
    return snapshot.docs
        .map((doc) => _weightEntryFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<WeightEntryModel>> getWeightEntriesForPet(String petId) async {
    final snapshot = await _weightEntriesCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _weightEntryFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateWeightEntry(String weightEntryId, WeightEntryModel weightEntry) async {
    await _weightEntriesCollection().doc(weightEntryId).update(_weightEntryToMap(weightEntry));
  }

  static Future<void> deleteWeightEntry(String weightEntryId) async {
    await _weightEntriesCollection().doc(weightEntryId).delete();
  }

  // ========== MILESTONES ==========

  static Future<String> addMilestone(MilestoneModel milestone) async {
    final docRef = await _milestonesCollection().add(_milestoneToMap(milestone));
    return docRef.id;
  }

  static Future<List<MilestoneModel>> getAllMilestones() async {
    final snapshot = await _milestonesCollection().get();
    return snapshot.docs
        .map((doc) => _milestoneFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<MilestoneModel>> getMilestonesForPet(String petId) async {
    final snapshot = await _milestonesCollection()
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs
        .map((doc) => _milestoneFromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> updateMilestone(String milestoneId, MilestoneModel milestone) async {
    await _milestonesCollection().doc(milestoneId).update(_milestoneToMap(milestone));
  }

  static Future<void> deleteMilestone(String milestoneId) async {
    await _milestonesCollection().doc(milestoneId).delete();
  }

  // ========== CONVERSION HELPERS ==========

  static Map<String, dynamic> _petToMap(PetModel pet) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': pet.id, // Store the integer ID in Firestore
      'name': pet.name,
      'species': pet.species,
      'gender': pet.gender,
      'age': pet.age,
      'breed': pet.breed,
      'photoPath': pet.photoPath,
      'notes': pet.notes,
      'weight': pet.weight,
      'height': pet.height,
      'color': pet.color,
      'birthDate': pet.birthDate?.toIso8601String(),
      'adoptionDate': pet.adoptionDate?.toIso8601String(),
      'createdAt': now,
      'updatedAt': now,
    };
  }

  static PetModel _petFromMap(String id, Map<String, dynamic> map) {
    // Get the integer ID from the map (stored in Firestore), fallback to parsing document ID
    int? petId;
    if (map['id'] != null) {
      // ID is stored in Firestore document
      petId = map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString());
    } else {
      // Fallback: try to parse Firestore document ID (for backward compatibility)
      petId = int.tryParse(id);
    }
    
    return PetModel(
      id: petId,
      name: map['name'] as String,
      species: map['species'] as String,
      gender: map['gender'] as String? ?? 'Unknown',
      age: map['age'] as int,
      breed: map['breed'] as String,
      photoPath: map['photoPath'] as String?,
      notes: map['notes'] as String?,
      weight: map['weight'] as String?,
      height: map['height'] as String?,
      color: map['color'] as String?,
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : null,
      adoptionDate: map['adoptionDate'] != null
          ? DateTime.parse(map['adoptionDate'] as String)
          : null,
    );
  }

  static Map<String, dynamic> _reminderToMap(ReminderModel reminder) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': reminder.petId.toString(),
      'title': reminder.title,
      'time': reminder.time.toIso8601String(),
      'repeat': reminder.repeat,
      'notificationId': reminder.notificationId,
      'isCompleted': reminder.isCompleted,
      'createdAt': now,
      'updatedAt': now,
    };
  }

  static ReminderModel _reminderFromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      repeat: map['repeat'] as String? ?? 'none',
      notificationId: map['notificationId'] as int?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _healthRecordToMap(HealthRecordModel record) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': record.petId.toString(),
      'title': record.title,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
      'createdAt': now,
      'updatedAt': now,
    };
  }

  static HealthRecordModel _healthRecordFromMap(String id, Map<String, dynamic> map) {
    return HealthRecordModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  static Map<String, dynamic> _vaccinationToMap(VaccinationModel vaccination) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': vaccination.petId.toString(),
      'vaccineName': vaccination.vaccineName,
      'dateGiven': vaccination.dateGiven.toIso8601String(),
      'nextDueDate': vaccination.nextDueDate?.toIso8601String(),
      'vetName': vaccination.vetName,
      'notes': vaccination.notes,
      'reminderId': vaccination.reminderId?.toString(),
      'createdAt': now,
      'updatedAt': now,
    };
  }

  static VaccinationModel _vaccinationFromMap(String id, Map<String, dynamic> map) {
    return VaccinationModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      vaccineName: map['vaccineName'] as String,
      dateGiven: DateTime.parse(map['dateGiven'] as String),
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.parse(map['nextDueDate'] as String)
          : null,
      vetName: map['vetName'] as String?,
      notes: map['notes'] as String?,
      reminderId: map['reminderId'] != null ? int.parse(map['reminderId'] as String) : null,
    );
  }

  static Map<String, dynamic> _activityToMap(ActivityModel activity) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': activity.petId.toString(),
      'type': activity.type,
      'duration': activity.duration,
      'date': activity.date.toIso8601String(),
      'notes': activity.notes,
      'distance': activity.distance,
      'createdAt': now,
    };
  }

  static ActivityModel _activityFromMap(String id, Map<String, dynamic> map) {
    return ActivityModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      type: map['type'] as String,
      duration: map['duration'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      distance: map['distance'] != null ? (map['distance'] as num).toDouble() : null,
    );
  }

  static Map<String, dynamic> _expenseToMap(ExpenseModel expense) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': expense.petId.toString(),
      'category': expense.category,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'description': expense.description,
      'receiptUrl': expense.receiptUrl,
      'createdAt': now,
    };
  }

  static ExpenseModel _expenseFromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      receiptUrl: map['receiptUrl'] as String?,
    );
  }

  static Map<String, dynamic> _photoToMap(PetPhotoModel photo) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': photo.petId.toString(),
      'photoUrl': photo.photoUrl,
      'thumbnailUrl': photo.thumbnailUrl,
      'dateTaken': photo.dateTaken.toIso8601String(),
      'caption': photo.caption,
      'isPrimary': photo.isPrimary,
      'createdAt': now,
    };
  }

  static PetPhotoModel _photoFromMap(String id, Map<String, dynamic> map) {
    return PetPhotoModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      photoUrl: map['photoUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      dateTaken: DateTime.parse(map['dateTaken'] as String),
      caption: map['caption'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _weightEntryToMap(WeightEntryModel weightEntry) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': weightEntry.petId.toString(),
      'weight': weightEntry.weight,
      'date': weightEntry.date.toIso8601String(),
      'notes': weightEntry.notes,
      'createdAt': now,
    };
  }

  static WeightEntryModel _weightEntryFromMap(String id, Map<String, dynamic> map) {
    return WeightEntryModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  static Map<String, dynamic> _milestoneToMap(MilestoneModel milestone) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': milestone.petId.toString(),
      'title': milestone.title,
      'date': milestone.date.toIso8601String(),
      'type': milestone.type,
      'notes': milestone.notes,
      'createdAt': now,
    };
  }

  static MilestoneModel _milestoneFromMap(String id, Map<String, dynamic> map) {
    return MilestoneModel(
      id: int.tryParse(id) ?? 0,
      petId: int.parse(map['petId'] as String),
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      notes: map['notes'] as String?,
    );
  }
}

