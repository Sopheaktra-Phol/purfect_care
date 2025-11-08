import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawfect_care/models/pet_model.dart';
import 'package:pawfect_care/providers/pet_provider.dart';
import 'package:pawfect_care/services/image_service.dart';

class AddPetScreen extends StatefulWidget {
  final PetModel? pet;

  const AddPetScreen({super.key, this.pet});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _form = GlobalKey<FormState>();
  String name = '';
  String species = 'Dog';
  String gender = 'Male';
  int age = 0;
  String breed = '';
  String? photoPath;
  String? notes;

  final ImageService _img = ImageService();

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      name = widget.pet!.name;
      species = widget.pet!.species;
      gender = widget.pet!.gender;
      age = widget.pet!.age;
      breed = widget.pet!.breed;
      photoPath = widget.pet!.photoPath;
      notes = widget.pet!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet == null ? 'Add Pet' : 'Edit Pet')),
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
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v?.trim() ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              DropdownButtonFormField(
                value: species,
                items: const [
                  DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                  DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => species = v as String),
                decoration: const InputDecoration(labelText: 'Species'),
              ),
              DropdownButtonFormField(
                value: gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => gender = v as String),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (v) => age = int.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: breed,
                decoration: const InputDecoration(labelText: 'Breed'),
                onSaved: (v) => breed = v ?? '',
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
                  final pet = PetModel(
                    id: widget.pet?.id,
                    name: name,
                    species: species,
                    gender: gender,
                    age: age,
                    breed: breed,
                    photoPath: photoPath,
                    notes: notes,
                  );
                  final provider = context.read<PetProvider>();
                  if (widget.pet == null) {
                    await provider.addPet(pet);
                  } else {
                    await provider.updatePet(widget.pet!.id!, pet);
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
