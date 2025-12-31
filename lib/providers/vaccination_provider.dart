import 'package:flutter/material.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class VaccinationProvider extends ChangeNotifier {
  final Map<int, List<VaccinationModel>> _vaccinations = {}; // petId -> list of vaccinations
  final Set<int> _loadingPetIds = {}; // Track which pet IDs are currently loading
  bool _isLoading = false;
  String? _errorMessage;
  
  bool isLoadingForPet(int petId) => _loadingPetIds.contains(petId);
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<VaccinationModel> getVaccinations(int petId) {
    return _vaccinations[petId] ?? [];
  }

  bool hasLoadedVaccinations(int petId) {
    return _vaccinations.containsKey(petId);
  }

  // Get upcoming vaccinations (next due date within next 30 days)
  List<VaccinationModel> getUpcomingVaccinations({int daysAhead = 30}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));
    return _vaccinations.values.expand((list) => list).where((v) {
      return v.nextDueDate != null && 
             v.nextDueDate!.isAfter(now) && 
             v.nextDueDate!.isBefore(futureDate);
    }).toList()
      ..sort((a, b) => (a.nextDueDate ?? DateTime.now()).compareTo(b.nextDueDate ?? DateTime.now()));
  }

  // Get overdue vaccinations
  List<VaccinationModel> getOverdueVaccinations() {
    final now = DateTime.now();
    return _vaccinations.values.expand((list) => list).where((v) {
      return v.nextDueDate != null && v.nextDueDate!.isBefore(now);
    }).toList()
      ..sort((a, b) => (a.nextDueDate ?? DateTime.now()).compareTo(b.nextDueDate ?? DateTime.now()));
  }

  Future<void> loadVaccinations(int petId) async {
    // Prevent multiple simultaneous loads for the same pet
    if (_loadingPetIds.contains(petId)) {
      print('⚠️ Already loading vaccinations for pet $petId, skipping...');
      return;
    }
    
    // Don't reload if we've already loaded vaccinations for this pet (even if empty)
    if (_vaccinations.containsKey(petId)) {
      print('⚠️ Vaccinations already loaded for pet $petId (${_vaccinations[petId]!.length} items), skipping...');
      return;
    }
    
    _loadingPetIds.add(petId);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📥 Loading vaccinations for pet $petId...');
      final vaccinations = await FirestoreDatabaseService.getVaccinationsForPet(petId.toString());
      _vaccinations[petId] = vaccinations;
      _errorMessage = null;
      print('✅ Loaded ${vaccinations.length} vaccinations for pet $petId');
    } catch (e) {
      _errorMessage = 'Failed to load vaccinations.';
      print('❌ Error loading vaccinations: $e');
      _vaccinations[petId] = [];
    } finally {
      _loadingPetIds.remove(petId);
      _isLoading = _loadingPetIds.isNotEmpty;
      notifyListeners();
    }
  }

  Future<void> addVaccination(VaccinationModel vaccination, ReminderProvider? reminderProvider, PetModel? pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create reminder for next due date if set
      if (vaccination.nextDueDate != null && reminderProvider != null && pet != null) {
        final reminderDate = vaccination.nextDueDate!.subtract(const Duration(days: 7)); // Remind 1 week before
        if (reminderDate.isAfter(DateTime.now())) {
          // Calculate days left from the reminder date (will be 7 days when reminder fires)
          final daysFromReminder = vaccination.nextDueDate!.difference(reminderDate).inDays;
          final daysLeft = daysFromReminder == 1 ? 'due in 1 day' : 'due in $daysFromReminder days';
          final reminder = ReminderModel(
            petId: vaccination.petId,
            title: '${vaccination.vaccineName} $daysLeft',
            time: reminderDate,
            repeat: 'none',
          );
          await reminderProvider.addReminder(reminder, pet);
          // Get the reminder ID from the provider
          final addedReminder = reminderProvider.reminders.firstWhere(
            (r) => r.petId == vaccination.petId && 
                   r.title == reminder.title && 
                   r.time == reminderDate,
            orElse: () => reminder,
          );
          if (addedReminder.id != null) {
            vaccination.reminderId = addedReminder.id;
          }
        }
      }
      
      // Save to Firestore
      final id = await FirestoreDatabaseService.addVaccination(vaccination);
      vaccination.id = int.tryParse(id) ?? 0;
      
      _vaccinations[vaccination.petId] ??= [];
      _vaccinations[vaccination.petId]!.add(vaccination);
      // Sort by date given descending
      _vaccinations[vaccination.petId]!.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add vaccination.';
      print('Error adding vaccination: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVaccination(int petId, int id, VaccinationModel vaccination, ReminderProvider? reminderProvider, PetModel? pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update or create reminder for next due date
      if (vaccination.nextDueDate != null && reminderProvider != null && pet != null) {
        final existingVaccination = _vaccinations[petId]?.firstWhere((v) => v.id == id);
        if (existingVaccination != null) {
          // Delete old reminder if exists
          if (existingVaccination.reminderId != null) {
            try {
              await reminderProvider.deleteReminder(existingVaccination.reminderId!);
            } catch (e) {
              print('Error deleting old reminder: $e');
            }
          }
          
          // Create new reminder
          final reminderDate = vaccination.nextDueDate!.subtract(const Duration(days: 7));
          if (reminderDate.isAfter(DateTime.now())) {
            // Calculate days left from the reminder date (will be 7 days when reminder fires)
            final daysFromReminder = vaccination.nextDueDate!.difference(reminderDate).inDays;
            final daysLeft = daysFromReminder == 1 ? 'due in 1 day' : 'due in $daysFromReminder days';
            final reminder = ReminderModel(
              petId: vaccination.petId,
              title: '${vaccination.vaccineName} $daysLeft',
              time: reminderDate,
              repeat: 'none',
            );
            await reminderProvider.addReminder(reminder, pet);
            // Get the reminder ID from the provider
            final addedReminder = reminderProvider.reminders.firstWhere(
              (r) => r.petId == vaccination.petId && 
                     r.title == reminder.title && 
                     r.time == reminderDate,
              orElse: () => reminder,
            );
            if (addedReminder.id != null) {
              vaccination.reminderId = addedReminder.id;
            }
          }
        }
      }
      
      // Update in Firestore
      await FirestoreDatabaseService.updateVaccination(id.toString(), vaccination);
      final vaccinations = _vaccinations[petId] ?? [];
      final idx = vaccinations.indexWhere((v) => v.id == id);
      if (idx >= 0) {
        vaccinations[idx] = vaccination;
        // Sort by date given descending
        vaccinations.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update vaccination.';
      print('Error updating vaccination: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVaccination(int petId, int id, ReminderProvider? reminderProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete associated reminder if exists
      final vaccination = _vaccinations[petId]?.firstWhere((v) => v.id == id);
      if (vaccination?.reminderId != null && reminderProvider != null) {
        try {
          await reminderProvider.deleteReminder(vaccination!.reminderId!);
        } catch (e) {
          print('Error deleting reminder: $e');
        }
      }
      
      // Delete from Firestore
      await FirestoreDatabaseService.deleteVaccination(id.toString());
      _vaccinations[petId]?.removeWhere((v) => v.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete vaccination.';
      print('Error deleting vaccination: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all vaccinations for a pet (used when pet is deleted)
  void deleteAllVaccinationsForPet(int petId) {
    _vaccinations.remove(petId);
    notifyListeners();
  }
}

