import 'package:flutter/material.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class ActivityProvider extends ChangeNotifier {
  final Map<int, List<ActivityModel>> _activities = {}; // petId -> list of activities
  final Set<int> _loadingPetIds = {}; // Track which pet IDs are currently loading
  bool _isLoading = false;
  String? _errorMessage;
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool isLoadingForPet(int petId) => _loadingPetIds.contains(petId);

  List<ActivityModel> getActivities(int petId) {
    return _activities[petId] ?? [];
  }

  bool hasLoadedActivities(int petId) {
    return _activities.containsKey(petId);
  }

  // Get activities for a specific date range
  List<ActivityModel> getActivitiesForDateRange(int petId, DateTime startDate, DateTime endDate) {
    final activities = _activities[petId] ?? [];
    return activities.where((a) => 
      a.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
      a.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  // Get today's activities
  List<ActivityModel> getTodayActivities(int petId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getActivitiesForDateRange(petId, startOfDay, endOfDay);
  }

  // Get this week's activities
  List<ActivityModel> getWeekActivities(int petId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfDay = startOfDay.add(const Duration(days: 7));
    return getActivitiesForDateRange(petId, startOfDay, endOfDay);
  }

  // Calculate total duration for activities
  int getTotalDuration(List<ActivityModel> activities) {
    return activities.fold(0, (sum, activity) => sum + activity.duration);
  }

  // Calculate total distance for activities (walks)
  double getTotalDistance(List<ActivityModel> activities) {
    return activities
        .where((a) => a.distance != null)
        .fold(0.0, (sum, activity) => sum + (activity.distance ?? 0.0));
  }

  // Get activity breakdown by type
  Map<String, int> getActivityBreakdown(List<ActivityModel> activities) {
    final breakdown = <String, int>{};
    for (var activity in activities) {
      breakdown[activity.type] = (breakdown[activity.type] ?? 0) + activity.duration;
    }
    return breakdown;
  }

  Future<void> loadActivities(int petId) async {
    // Prevent multiple simultaneous loads for the same pet
    if (_loadingPetIds.contains(petId)) {
      print('⚠️ Already loading activities for pet $petId, skipping...');
      return;
    }
    
    // Don't reload if we've already loaded activities for this pet (even if empty)
    if (_activities.containsKey(petId)) {
      print('⚠️ Activities already loaded for pet $petId (${_activities[petId]!.length} items), skipping...');
      return;
    }
    
    _loadingPetIds.add(petId);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📥 Loading activities for pet $petId...');
      final activities = await FirestoreDatabaseService.getActivitiesForPet(petId.toString());
      _activities[petId] = activities;
      _errorMessage = null;
      print('✅ Loaded ${activities.length} activities for pet $petId');
    } catch (e) {
      _errorMessage = 'Failed to load activities.';
      print('❌ Error loading activities: $e');
      _activities[petId] = [];
    } finally {
      _loadingPetIds.remove(petId);
      _isLoading = _loadingPetIds.isNotEmpty;
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await FirestoreDatabaseService.addActivity(activity);
      activity.id = int.tryParse(id) ?? 0;
      _activities[activity.petId] ??= [];
      _activities[activity.petId]!.add(activity);
      // Sort by date descending
      _activities[activity.petId]!.sort((a, b) => b.date.compareTo(a.date));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add activity.';
      print('Error adding activity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActivity(int petId, int id, ActivityModel activity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.updateActivity(id.toString(), activity);
      final activities = _activities[petId] ?? [];
      final idx = activities.indexWhere((a) => a.id == id);
      if (idx >= 0) {
        activities[idx] = activity;
        // Sort by date descending
        activities.sort((a, b) => b.date.compareTo(a.date));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update activity.';
      print('Error updating activity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(int petId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.deleteActivity(id.toString());
      _activities[petId]?.removeWhere((a) => a.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete activity.';
      print('Error deleting activity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all activities for a pet (used when pet is deleted)
  void deleteAllActivitiesForPet(int petId) {
    _activities.remove(petId);
    notifyListeners();
  }
}

