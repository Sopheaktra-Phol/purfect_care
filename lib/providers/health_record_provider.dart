import 'package:flutter/material.dart';
import '../models/health_record_model.dart';
import '../services/firestore_database_service.dart';

class HealthRecordProvider extends ChangeNotifier {
  List<HealthRecordModel> healthRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHealthRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      healthRecords = await FirestoreDatabaseService.getAllHealthRecords();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load health records.';
      print('Error loading health records: $e');
      healthRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHealthRecord(HealthRecordModel record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await FirestoreDatabaseService.addHealthRecord(record);
      record.id = int.tryParse(id) ?? 0;
      healthRecords.add(record);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add health record.';
      print('Error adding health record: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHealthRecord(int id, HealthRecordModel record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.updateHealthRecord(id.toString(), record);
      final i = healthRecords.indexWhere((e) => e.id == id);
      if (i >= 0) {
        healthRecords[i] = record;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update health record.';
      print('Error updating health record: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHealthRecord(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.deleteHealthRecord(id.toString());
      healthRecords.removeWhere((e) => e.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete health record.';
      print('Error deleting health record: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
