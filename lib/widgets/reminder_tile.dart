import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../providers/pet_provider.dart';
import '../providers/reminder_provider.dart';

class ReminderTile extends StatefulWidget {
  final ReminderModel reminder;
  const ReminderTile({super.key, required this.reminder});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  @override
  Widget build(BuildContext context) {
    final pets = context.read<PetProvider>().pets;
    final pet = pets.firstWhereOrNull((p) => p.id == widget.reminder.petId);
    
    // Handle case where pet is not found (e.g., pet was deleted but reminder still exists)
    if (pet == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.warning, color: Colors.orange),
          title: Text(widget.reminder.title),
          subtitle: Text(
            'Pet not found • ${DateFormat.yMd().add_jm().format(widget.reminder.time)}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (widget.reminder.id != null) {
                context.read<ReminderProvider>().deleteReminder(widget.reminder.id!);
              }
            },
          ),
        ),
      );
    }
    
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            widget.reminder.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: widget.reminder.isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            final reminderProv = context.read<ReminderProvider>();
            // Create a new instance instead of mutating the original
            final updatedReminder = ReminderModel(
              id: widget.reminder.id,
              petId: widget.reminder.petId,
              title: widget.reminder.title,
              time: widget.reminder.time,
              repeat: widget.reminder.repeat,
              notificationId: widget.reminder.notificationId,
              isCompleted: !widget.reminder.isCompleted,
            );
            reminderProv.updateReminder(widget.reminder.id!, updatedReminder, pet);
          },
        ),
        title: Text(widget.reminder.title),
        subtitle: Text(
          'For: ${pet.name} at ${DateFormat.yMd().add_jm().format(widget.reminder.time)}',
        ),
      ),
    );
  }
}
