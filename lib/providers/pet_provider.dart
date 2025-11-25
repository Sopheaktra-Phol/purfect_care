import 'package:flutter/material.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/services/database_service.dart';

class PetProvider extends ChangeNotifier {
  List<PetModel> pets = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void loadPets() {
    pets = DatabaseService.getAllPets();
    notifyListeners();
  }

  Future<void> addPet(PetModel pet) async {
    final id = await DatabaseService.addPet(pet);
    pet.id = id;
    pets.add(pet);
    notifyListeners();
  }

  Future<void> updatePet(int id, PetModel pet) async {
    await DatabaseService.updatePet(id, pet);
    final idx = pets.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      pets[idx] = pet;
      notifyListeners();
    }
  }

  Future<void> deletePet(int id) async {
    await DatabaseService.deletePet(id);
    pets.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}