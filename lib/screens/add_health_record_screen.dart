import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/providers/health_record_provider.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final PetModel pet;
  final HealthRecordModel? record;

  const AddHealthRecordScreen({super.key, required this.pet, this.record});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _form = GlobalKey<FormState>();
  String title = 'Vet Visit';
  DateTime date = DateTime.now();
  String? notes;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      title = widget.record!.title;
      date = widget.record!.date;
      notes = widget.record!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add Health Record' : 'Edit Health Record'),
        actions: [
          if (widget.record != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final provider = context.read<HealthRecordProvider>();
                await provider.deleteHealthRecord(widget.record!.id!);
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
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => title = v?.trim() ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final dt = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (dt != null) setState(() => date = dt);
                },
              ),
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (v) => notes = v,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  final record = HealthRecordModel(
                    id: widget.record?.id,
                    petId: widget.pet.id!,
                    title: title,
                    date: date,
                    notes: notes,
                  );
                  final provider = context.read<HealthRecordProvider>();
                  if (widget.record == null) {
                    await provider.addHealthRecord(record);
                  } else {
                    await provider.updateHealthRecord(widget.record!.id!, record);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
