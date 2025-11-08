import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];

  void loadReminders() {
    reminders = DatabaseService.getAllReminders();
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel r) async {
    final notificationId = await NotificationService().scheduleNotification(
      title: r.title,
      body: 'Reminder for pet',
      scheduledDate: r.time,
      repeat: r.repeat,
    );
    r.notificationId = notificationId;
    final id = await DatabaseService.addReminder(r);
    r.id = id;
    reminders.add(r);
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