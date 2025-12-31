import 'package:flutter/material.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class MilestoneProvider extends ChangeNotifier {
  final Map<int, List<MilestoneModel>> _milestones = {}; // petId -> list of milestones
  bool _isLoading = false;
  String? _errorMessage;
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MilestoneModel> getMilestones(int petId) {
    return _milestones[petId] ?? [];
  }

  bool hasLoadedMilestones(int petId) {
    return _milestones.containsKey(petId);
  }

  // Get all milestones across all pets
  List<MilestoneModel> getAllMilestones() {
    return _milestones.values.expand((list) => list).toList();
  }

  // Get upcoming milestones (within next 30 days)
  List<MilestoneModel> getUpcomingMilestones({int daysAhead = 30}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));
    return getAllMilestones().where((m) {
      // Normalize dates to compare only month and day
      final milestoneDate = DateTime(now.year, m.date.month, m.date.day);
      final today = DateTime(now.year, now.month, now.day);
      final future = DateTime(now.year, futureDate.month, futureDate.day);
      
      // Handle year wrap-around
      if (milestoneDate.isBefore(today)) {
        final nextYear = DateTime(now.year + 1, m.date.month, m.date.day);
        return nextYear.isBefore(future) || nextYear.isAtSameMomentAs(future);
      }
      return milestoneDate.isBefore(future) || milestoneDate.isAtSameMomentAs(future);
    }).toList()
      ..sort((a, b) {
        // Sort by next occurrence date
        final today = DateTime(now.year, now.month, now.day);
        final aDate = DateTime(now.year, a.date.month, a.date.day);
        final bDate = DateTime(now.year, b.date.month, b.date.day);
        if (aDate.isBefore(today)) {
          final aNext = DateTime(now.year + 1, a.date.month, a.date.day);
          if (bDate.isBefore(today)) {
            final bNext = DateTime(now.year + 1, b.date.month, b.date.day);
            return aNext.compareTo(bNext);
          }
          return aNext.compareTo(bDate);
        }
        if (bDate.isBefore(today)) {
          final bNext = DateTime(now.year + 1, b.date.month, b.date.day);
          return aDate.compareTo(bNext);
        }
        return aDate.compareTo(bDate);
      });
  }

  Future<void> loadMilestones(int petId) async {
    // Don't reload if we've already loaded milestones for this pet (even if empty)
    if (_milestones.containsKey(petId)) {
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final milestones = await FirestoreDatabaseService.getMilestonesForPet(petId.toString());
      _milestones[petId] = milestones;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load milestones.';
      print('Error loading milestones: $e');
      _milestones[petId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMilestone(MilestoneModel milestone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await FirestoreDatabaseService.addMilestone(milestone);
      milestone.id = int.tryParse(id) ?? 0;
      _milestones[milestone.petId] ??= [];
      _milestones[milestone.petId]!.add(milestone);
      // Sort by date ascending
      _milestones[milestone.petId]!.sort((a, b) => a.date.compareTo(b.date));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add milestone.';
      print('Error adding milestone: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMilestone(int petId, int id, MilestoneModel milestone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.updateMilestone(id.toString(), milestone);
      final milestones = _milestones[petId] ?? [];
      final idx = milestones.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        milestones[idx] = milestone;
        // Sort by date ascending
        milestones.sort((a, b) => a.date.compareTo(b.date));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update milestone.';
      print('Error updating milestone: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMilestone(int petId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.deleteMilestone(id.toString());
      _milestones[petId]?.removeWhere((m) => m.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete milestone.';
      print('Error deleting milestone: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all milestones for a pet (used when pet is deleted)
  void deleteAllMilestonesForPet(int petId) {
    _milestones.remove(petId);
    notifyListeners();
  }
}

