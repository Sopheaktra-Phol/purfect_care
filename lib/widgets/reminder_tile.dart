import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pawfect_care/models/reminder_model.dart';
import 'package:pawfect_care/providers/reminder_provider.dart';
import 'package:pawfect_care/services/notification_service.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  const ReminderTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(reminder.title),
        subtitle: Text('${DateFormat.yMd().add_jm().format(reminder.time)} • ${reminder.repeat}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            if (reminder.notificationId != null) {
              await NotificationService().cancelNotification(reminder.notificationId!);
            }
            if (reminder.id != null) {
              await context.read<ReminderProvider>().deleteReminder(reminder.id!);
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
          },
        ),
      ),
    );
  }
}