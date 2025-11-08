import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawfect_care/models/pet_model.dart';
import 'package:pawfect_care/providers/pet_provider.dart';
import 'package:pawfect_care/services/image_service.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _form = GlobalKey<FormState>();
  String name = '';
  String species = 'Dog';
  int age = 0;
  String breed = '';
  String? photoPath;
  String? notes;

  final ImageService _img = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  final f = await _img.pickImageFromGallery();
                  if (f != null) setState(() => photoPath = f.path);
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                  child: photoPath == null ? const Icon(Icons.pets, size: 36) : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v?.trim() ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              DropdownButtonFormField(
                initialValue: species,
                items: const [
                  DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                  DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => species = v as String),
                decoration: const InputDecoration(labelText: 'Species'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (v) => age = int.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Breed'),
                onSaved: (v) => breed = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (v) => notes = v,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  final pet = PetModel(name: name, species: species, age: age, breed: breed, photoPath: photoPath, notes: notes);
                  // avoid using BuildContext across async gap
                  final provider = context.read<PetProvider>();
                  await provider.addPet(pet);
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
