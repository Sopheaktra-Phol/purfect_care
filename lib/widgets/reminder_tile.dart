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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final reminderProv = context.read<ReminderProvider>();
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
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  final reminderProv = context.read<ReminderProvider>();
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
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.reminder.isCompleted 
                          ? const Color(0xFFFB930B) 
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: widget.reminder.isCompleted 
                        ? const Color(0xFFFB930B) 
                        : Colors.transparent,
                  ),
                  child: widget.reminder.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      widget.reminder.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.reminder.isCompleted 
                            ? Colors.grey[400] 
                            : Colors.black,
                        decoration: widget.reminder.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Pet name and date
                    Text(
                      'For: ${pet.name} at ${DateFormat.yMd().format(widget.reminder.time)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.reminder.isCompleted 
                            ? Colors.grey[400] 
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Time
                    Text(
                      DateFormat.jm().format(widget.reminder.time),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.reminder.isCompleted 
                            ? Colors.grey[400] 
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
