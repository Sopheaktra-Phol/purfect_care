import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pet_model.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: pet.photoPath != null ? FileImage(File(pet.photoPath!)) : null,
          child: pet.photoPath == null ? const Icon(Icons.pets) : null,
        ),
        title: Text(pet.name),
        subtitle: Text('${pet.species} • ${pet.breed}'),
      ),
    );
  }
}