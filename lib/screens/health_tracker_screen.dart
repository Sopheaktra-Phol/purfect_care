import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/health_record_provider.dart';
import '../widgets/health_record_card.dart';
import 'add_health_record_screen.dart';

class HealthTrackerScreen extends StatelessWidget {
  final PetModel pet;

  const HealthTrackerScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final healthRecordProv = context.watch<HealthRecordProvider>();
    final healthRecords = healthRecordProv.healthRecords.where((r) => r.petId == pet.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${pet.name}\'s Health Records')),
      body: healthRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No health records yet.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddHealthRecordScreen(pet: pet)),
                    ),
                    child: const Text('Add Health Record'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: healthRecords.length,
              itemBuilder: (context, i) {
                final record = healthRecords[i];
                return HealthRecordCard(record: record);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddHealthRecordScreen(pet: pet)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
