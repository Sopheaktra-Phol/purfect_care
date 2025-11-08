import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';
import '../widgets/reminder_tile.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProv = context.watch<ReminderProvider>();
    final completedReminders = reminderProv.reminders.where((r) => r.isCompleted).toList();
    completedReminders.sort((a, b) => b.time.compareTo(a.time));

    final groupedReminders = groupBy(completedReminders, (ReminderModel r) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final reminderDate = DateTime(r.time.year, r.time.month, r.time.day);

      if (reminderDate == today) {
        return 'Today';
      } else if (reminderDate == yesterday) {
        return 'Yesterday';
      } else {
        return 'Earlier';
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: groupedReminders.isEmpty
          ? const Center(child: Text('No completed tasks yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: groupedReminders.length,
              itemBuilder: (context, i) {
                final groupTitle = groupedReminders.keys.elementAt(i);
                final remindersInGroup = groupedReminders[groupTitle]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        groupTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ...remindersInGroup.map((r) => ReminderTile(reminder: r)),
                  ],
                );
              },
            ),
    );
  }
}
