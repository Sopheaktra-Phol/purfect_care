import 'package:flutter/material.dart';
import '../models/health_record_model.dart';
import '../services/database_service.dart';

class HealthRecordProvider extends ChangeNotifier {
  List<HealthRecordModel> healthRecords = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void loadHealthRecords() {
    healthRecords = DatabaseService.getAllHealthRecords();
    notifyListeners();
  }

  Future<void> addHealthRecord(HealthRecordModel record) async {
    final id = await DatabaseService.addHealthRecord(record);
    record.id = id;
    healthRecords.add(record);
    notifyListeners();
  }

  Future<void> updateHealthRecord(int id, HealthRecordModel record) async {
    await DatabaseService.updateHealthRecord(id, record);
    final i = healthRecords.indexWhere((e) => e.id == id);
    if (i >= 0) {
    healthRecords[i] = record;
    notifyListeners();
    }
  }

  Future<void> deleteHealthRecord(int id) async {
    await DatabaseService.deleteHealthRecord(id);
    healthRecords.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
