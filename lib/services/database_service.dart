import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pet_model.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static const String petsBox = 'pets';
  static const String remindersBox = 'reminders';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    // register adapters
    Hive.registerAdapter(PetModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    await Hive.openBox(petsBox);
    await Hive.openBox(remindersBox);
    _initialized = true;
  }

  // Pets
  static Box get _pets => Hive.box(petsBox);
  static Box get _reminders => Hive.box(remindersBox);

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
    // delete reminders for pet
    final reminders = _reminders.values.cast<ReminderModel>().where((r) => r.petId == key).toList();
    for (var r in reminders) {
      if (r.id != null) await deleteReminder(r.id!);
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
}