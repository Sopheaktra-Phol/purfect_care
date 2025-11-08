import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawfect_care/models/pet_model.dart';
import 'package:pawfect_care/providers/reminder_provider.dart';
import 'package:pawfect_care/providers/pet_provider.dart';
import 'package:pawfect_care/widgets/reminder_tile.dart';
import 'package:pawfect_care/screens/add_reminder_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final remProv = context.watch<ReminderProvider>();
    final reminders = remProv.reminders.where((r) => r.petId == pet.id).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (pet.id != null) {
                final provider = context.read<PetProvider>();
                await provider.deletePet(pet.id!);
                if (Navigator.canPop(context)) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: pet.photoPath != null ? FileImage(File(pet.photoPath!)) : null,
                child: pet.photoPath == null ? const Icon(Icons.pets, size: 36) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text('${pet.species} • ${pet.breed}'),
                    if (pet.age >= 0) Text('Age: ${pet.age}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (reminders.isEmpty) const Text('No reminders yet.'),
          ...reminders.map((r) => ReminderTile(reminder: r)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminderScreen(pet: pet))),
        child: const Icon(Icons.alarm_add),
      ),
    );
  }
}
