import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfect_care/models/reminder_model.dart';
import 'package:provider/provider.dart';

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
    final pet = context.read<PetProvider>().pets.firstWhere((p) => p.id == widget.reminder.petId);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            widget.reminder.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: widget.reminder.isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            final reminderProv = context.read<ReminderProvider>();
            reminderProv.toggleReminderStatus(widget.reminder.id!, !widget.reminder.isCompleted);
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
