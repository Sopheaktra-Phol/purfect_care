import 'package:flutter/material.dart';
import 'package:purfect_care/models/weight_entry_model.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class WeightProvider extends ChangeNotifier {
  final Map<int, List<WeightEntryModel>> _weightEntries = {}; // petId -> list of weight entries
  bool _isLoading = false;
  String? _errorMessage;
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<WeightEntryModel> getWeightEntries(int petId) {
    return _weightEntries[petId] ?? [];
  }

  bool hasLoadedWeightEntries(int petId) {
    return _weightEntries.containsKey(petId);
  }

  Future<void> loadWeightEntries(int petId) async {
    // Don't reload if we've already loaded weight entries for this pet (even if empty)
    if (_weightEntries.containsKey(petId)) {
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final entries = await FirestoreDatabaseService.getWeightEntriesForPet(petId.toString());
      _weightEntries[petId] = entries;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load weight entries.';
      print('Error loading weight entries: $e');
      _weightEntries[petId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWeightEntry(WeightEntryModel weightEntry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await FirestoreDatabaseService.addWeightEntry(weightEntry);
      weightEntry.id = int.tryParse(id) ?? 0;
      _weightEntries[weightEntry.petId] ??= [];
      _weightEntries[weightEntry.petId]!.add(weightEntry);
      // Sort by date descending
      _weightEntries[weightEntry.petId]!.sort((a, b) => b.date.compareTo(a.date));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add weight entry.';
      print('Error adding weight entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWeightEntry(int petId, int id, WeightEntryModel weightEntry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.updateWeightEntry(id.toString(), weightEntry);
      final entries = _weightEntries[petId] ?? [];
      final idx = entries.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        entries[idx] = weightEntry;
        // Sort by date descending
        entries.sort((a, b) => b.date.compareTo(a.date));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update weight entry.';
      print('Error updating weight entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWeightEntry(int petId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.deleteWeightEntry(id.toString());
      _weightEntries[petId]?.removeWhere((e) => e.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete weight entry.';
      print('Error deleting weight entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get latest weight entry for a pet
  WeightEntryModel? getLatestWeight(int petId) {
    final entries = _weightEntries[petId];
    if (entries == null || entries.isEmpty) return null;
    return entries.first; // Already sorted by date descending
  }

  // Clear all weight entries for a pet (used when pet is deleted)
  void deleteAllWeightEntriesForPet(int petId) {
    _weightEntries.remove(petId);
    notifyListeners();
  }
}

