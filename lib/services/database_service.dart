import 'package:hive/hive.dart';
// Hive is initialized in main.dart via Hive.initFlutter()

import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';
import 'image_service.dart';

class DatabaseService {
  static const String petsBoxPrefix = 'pets_';
  static const String remindersBoxPrefix = 'reminders_';
  static const String healthRecordsBoxPrefix = 'health_records_';

  static bool _initialized = false;
  static String? _currentUserId;
  static Box? _petsBox;
  static Box? _remindersBox;
  static Box? _healthRecordsBox;

  static Future<void> init() async {
    if (_initialized) return;
    // register adapters
    Hive.registerAdapter(PetModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    Hive.registerAdapter(HealthRecordModelAdapter());
    _initialized = true;
  }

  /// Switch to a user's data context. Call this when user logs in.
  static Future<void> switchUser(String userId) async {
    // Close previous user's boxes if they exist
    await closeCurrentUserBoxes();

    // Open new user's boxes
    _currentUserId = userId;
    _petsBox = await Hive.openBox('${petsBoxPrefix}$userId');
    _remindersBox = await Hive.openBox('${remindersBoxPrefix}$userId');
    _healthRecordsBox = await Hive.openBox('${healthRecordsBoxPrefix}$userId');
  }

  /// Clear current user's data and close boxes. Call this when user logs out.
  static Future<void> clearCurrentUserData() async {
    if (_currentUserId == null) return;

    // Clear all data from current user's boxes
    if (_petsBox != null) await _petsBox!.clear();
    if (_remindersBox != null) await _remindersBox!.clear();
    if (_healthRecordsBox != null) await _healthRecordsBox!.clear();

    // Close boxes
    await closeCurrentUserBoxes();
    _currentUserId = null;
  }

  /// Close current user's boxes
  static Future<void> closeCurrentUserBoxes() async {
    if (_petsBox != null && _petsBox!.isOpen) await _petsBox!.close();
    if (_remindersBox != null && _remindersBox!.isOpen) await _remindersBox!.close();
    if (_healthRecordsBox != null && _healthRecordsBox!.isOpen) await _healthRecordsBox!.close();
    
    _petsBox = null;
    _remindersBox = null;
    _healthRecordsBox = null;
  }

  /// Get current user ID
  static String? get currentUserId => _currentUserId;

  // Pets
  static Box get _pets {
    if (_petsBox == null || !_petsBox!.isOpen) {
      throw Exception('User data not initialized. Call switchUser() first.');
    }
    return _petsBox!;
  }

  static Box get _reminders {
    if (_remindersBox == null || !_remindersBox!.isOpen) {
      throw Exception('User data not initialized. Call switchUser() first.');
    }
    return _remindersBox!;
  }

  static Box get _healthRecords {
    if (_healthRecordsBox == null || !_healthRecordsBox!.isOpen) {
      throw Exception('User data not initialized. Call switchUser() first.');
    }
    return _healthRecordsBox!;
  }

  static Future<int> addPet(PetModel pet) async {
    final key = await _pets.add(pet);
    // store id inside model for convenience
    final p = pet;
    p.id = key;
    await _pets.put(key, p);
    return key;
  }

  static List<PetModel> getAllPets() {
    return _pets.values.cast<PetModel>().toList();
  }

  static Future<void> updatePet(int key, PetModel pet) async {
    pet.id = key;
    await _pets.put(key, pet);
  }

  static Future<void> deletePet(int key) async {
    // Get pet to delete its image
    final pet = _pets.get(key) as PetModel?;
    
    // delete reminders for pet
    final reminders = _reminders.values.cast<ReminderModel>().where((r) => r.petId == key).toList();
    for (var r in reminders) {
      if (r.id != null) await deleteReminder(r.id!);
    }
    
    // Delete pet's image file if it exists
    if (pet?.photoPath != null) {
      final imageService = ImageService();
      await imageService.deleteImage(pet!.photoPath);
    }
    
    await _pets.delete(key);
  }

  // Reminders
  static Future<int> addReminder(ReminderModel reminder) async {
    final key = await _reminders.add(reminder);
    reminder.id = key;
    await _reminders.put(key, reminder);
    return key;
  }

  static List<ReminderModel> getAllReminders() {
    return _reminders.values.cast<ReminderModel>().toList();
  }

  static Future<void> updateReminder(int key, ReminderModel rem) async {
    rem.id = key;
    await _reminders.put(key, rem);
  }

  static Future<void> deleteReminder(int key) async {
    await _reminders.delete(key);
  }

  // Health Records
  static Future<int> addHealthRecord(HealthRecordModel record) async {
    final key = await _healthRecords.add(record);
    record.id = key;
    await _healthRecords.put(key, record);
    return key;
  }

  static List<HealthRecordModel> getAllHealthRecords() {
    return _healthRecords.values.cast<HealthRecordModel>().toList();
  }

  static Future<void> updateHealthRecord(int key, HealthRecordModel record) async {
    record.id = key;
    await _healthRecords.put(key, record);
  }

  static Future<void> deleteHealthRecord(int key) async {
    await _healthRecords.delete(key);
  }
}
