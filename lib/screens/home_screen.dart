import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';
import 'add_pet_screen.dart';
import 'pet_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pawfect Care')),
      body: petProv.pets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No pets yet.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
                    child: const Text('Add Pet'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: petProv.pets.length,
              itemBuilder: (context, i) {
                final pet = petProv.pets[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet))),
                  child: PetCard(pet: pet),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
