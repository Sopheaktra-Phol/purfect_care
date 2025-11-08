import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];

  void loadReminders() {
    reminders = DatabaseService.getAllReminders();
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel r, PetModel pet) async {
    final notificationId = await NotificationService().scheduleNotification(
      petName: pet.name,
      title: r.title,
      scheduledDate: r.time,
      repeat: r.repeat,
    );
    r.notificationId = notificationId;
    final id = await DatabaseService.addReminder(r);
    r.id = id;
    reminders.add(r);
    notifyListeners();
  }

  Future<void> updateReminder(int id, ReminderModel r, PetModel pet) async {
    final old = reminders.firstWhere((e) => e.id == id);
    if (old.notificationId != null) await NotificationService().cancelNotification(old.notificationId!);
    final notificationId = await NotificationService().scheduleNotification(
      petName: pet.name,
      title: r.title,
      scheduledDate: r.time,
      repeat: r.repeat,
    );
    r.notificationId = notificationId;
    await DatabaseService.updateReminder(id, r);
    final i = reminders.indexWhere((e) => e.id == id);
    reminders[i] = r;
    notifyListeners();
  }

  Future<void> deleteReminder(int id) async {
    final r = reminders.firstWhere((e) => e.id == id);
    if (r.notificationId != null) await NotificationService().cancelNotification(r.notificationId!);
    await DatabaseService.deleteReminder(id);
    reminders.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
