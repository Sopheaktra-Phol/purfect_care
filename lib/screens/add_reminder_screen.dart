import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pawfect_care/models/pet_model.dart';
import 'package:pawfect_care/models/reminder_model.dart';
import 'package:pawfect_care/providers/reminder_provider.dart';

class AddReminderScreen extends StatefulWidget {
  final PetModel pet;
  final ReminderModel? reminder;
  const AddReminderScreen({super.key, required this.pet, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _form = GlobalKey<FormState>();
  String title = 'Feed';
  String customTitle = '';
  DateTime dateTime = DateTime.now().add(const Duration(hours: 1));
  String repeat = 'none';

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      title = widget.reminder!.title;
      dateTime = widget.reminder!.time;
      repeat = widget.reminder!.repeat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
        actions: [
          if (widget.reminder != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final provider = context.read<ReminderProvider>();
                await provider.deleteReminder(widget.reminder!.id!);
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: title,
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
              if (title == 'Custom')
                TextFormField(
                  initialValue: customTitle,
                  decoration: const InputDecoration(labelText: 'Custom Task Name'),
                  onChanged: (v) => customTitle = v,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                value: repeat,
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('One-time')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (v) => setState(() => repeat = v as String),
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  final reminderTitle = title == 'Custom' ? customTitle : title;
                  final r = ReminderModel(
                    id: widget.reminder?.id,
                    petId: widget.pet.id!,
                    title: reminderTitle,
                    time: dateTime,
                    repeat: repeat,
                  );
                  final provider = context.read<ReminderProvider>();
                  if (widget.reminder == null) {
                    await provider.addReminder(r, widget.pet);
                  } else {
                    await provider.updateReminder(widget.reminder!.id!, r, widget.pet);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
