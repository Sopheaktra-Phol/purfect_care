import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pawfect_care/models/pet_model.dart';
import 'package:pawfect_care/models/reminder_model.dart';
import 'package:pawfect_care/providers/reminder_provider.dart';

class AddReminderScreen extends StatefulWidget {
  final PetModel pet;
  const AddReminderScreen({super.key, required this.pet});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  String title = 'Feed';
  DateTime dateTime = DateTime.now().add(const Duration(hours: 1));
  String repeat = 'none';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: title,
              items: const [
                DropdownMenuItem(value: 'Feed', child: Text('Feed')),
                DropdownMenuItem(value: 'Walk', child: Text('Walk')),
                DropdownMenuItem(value: 'Vet', child: Text('Vet Visit')),
                DropdownMenuItem(value: 'Groom', child: Text('Groom')),
                DropdownMenuItem(value: 'Custom', child: Text('Custom')),
              ],
              onChanged: (v) => setState(() => title = v as String),
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            ListTile(
              title: Text('Time: ${DateFormat.yMd().add_jm().format(dateTime)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dt = await showDatePicker(
                  context: context,
                  initialDate: dateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (dt == null) return;
                final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
                if (tm == null) return;
                setState(() => dateTime = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute));
              },
            ),
            DropdownButtonFormField(
              initialValue: repeat,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('One-time')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (v) => setState(() => repeat = v as String),
              decoration: const InputDecoration(labelText: 'Repeat'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final r = ReminderModel(petId: widget.pet.id!, title: title, time: dateTime, repeat: repeat);
                final provider = context.read<ReminderProvider>();
                await provider.addReminder(r);
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}