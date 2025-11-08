import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pet_model.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
              child: pet.photoPath != null
                  ? Image.file(
                      File(pet.photoPath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      child: const Icon(Icons.pets, size: 48, color: Colors.white),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  pet.breed,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
