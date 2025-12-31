import 'package:flutter/material.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class PetProvider extends ChangeNotifier {
  List<PetModel> pets = [];
  // Map to store Firestore document IDs for each pet
  final Map<int, String> _petFirestoreIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDeleting = false; // Guard to prevent multiple simultaneous deletes
  
  /// Clear all pets and mappings (used on logout)
  void clearPets() {
    pets.clear();
    _petFirestoreIds.clear();
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📦 PetProvider.loadPets called');
      // Get pets with their Firestore document IDs
      final petsWithIds = await FirestoreDatabaseService.getAllPetsWithIds();
      print('📦 Got ${petsWithIds.length} pets from Firestore');
      pets = petsWithIds.map((entry) {
        final pet = entry['pet'] as PetModel;
        final firestoreId = entry['firestoreId'] as String;
        // Store the mapping
        if (pet.id != null) {
          _petFirestoreIds[pet.id!] = firestoreId;
        }
        return pet;
      }).toList();
      _errorMessage = null;
      print('📦 Loaded ${pets.length} pets with Firestore IDs');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load pets.';
      print('❌ Error loading pets: $e');
      print('❌ Stack trace: $stackTrace');
      pets = [];
      _petFirestoreIds.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPet(PetModel pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📦 PetProvider.addPet called');
      print('📦 Pet name: ${pet.name}');
      
      final id = await FirestoreDatabaseService.addPet(pet);
      print('📦 Firestore returned ID: $id');
      
      // Store Firestore ID as string, but keep int for compatibility
      // Generate a unique int ID for the pet (use timestamp or hash)
      pet.id = DateTime.now().millisecondsSinceEpoch % 1000000000; // Use timestamp as int ID
      // Store the mapping between int ID and Firestore document ID
      _petFirestoreIds[pet.id!] = id;
      pets.add(pet);
      _errorMessage = null;
      print('📦 Pet added to local list, total pets: ${pets.length}');
      print('📦 Mapped pet ID ${pet.id} to Firestore ID $id');
    } catch (e, stackTrace) {
      print('❌ PetProvider error adding pet: $e');
      print('❌ Stack trace: $stackTrace');
      // Provide more specific error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('not authenticated') || errorString.contains('sign in')) {
        _errorMessage = 'Please sign in to add pets.';
      } else if (errorString.contains('permission-denied') || errorString.contains('permission denied')) {
        _errorMessage = 'Permission denied. Please check your Firebase security rules.';
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        _errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
        _errorMessage = 'Request timed out. Please check your internet connection.';
      } else {
        _errorMessage = 'Failed to add pet: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print('📦 PetProvider.addPet completed, isLoading: $_isLoading, error: $_errorMessage');
    }
  }

  Future<void> updatePet(int id, PetModel pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📦 PetProvider.updatePet called with id: $id');
      
      // Get the Firestore document ID from our mapping
      final firestoreId = _petFirestoreIds[id];
      
      if (firestoreId == null) {
        print('⚠️ No Firestore ID mapping found for pet ID $id, trying to find it...');
        // Try to find the pet in Firestore by querying
        final allPetsWithIds = await FirestoreDatabaseService.getAllPetsWithIds();
        final matchingEntry = allPetsWithIds.firstWhere(
          (entry) {
            final p = entry['pet'] as PetModel;
            return p.id == id;
          },
          orElse: () => throw Exception('Pet not found in Firestore'),
        );
        final foundFirestoreId = matchingEntry['firestoreId'] as String;
        print('📦 Found Firestore ID: $foundFirestoreId');
        await FirestoreDatabaseService.updatePet(foundFirestoreId, pet);
        // Update the mapping for future use
        _petFirestoreIds[id] = foundFirestoreId;
      } else {
        print('📦 Using mapped Firestore ID: $firestoreId');
        await FirestoreDatabaseService.updatePet(firestoreId, pet);
      }
      
      // Update the pet in the local list
      final idx = pets.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        pets[idx] = pet;
        _errorMessage = null;
        print('✅ Pet updated successfully');
        print('✅ Updated pet photoPath: ${pet.photoPath}');
        print('✅ Pet in list now has photoPath: ${pets[idx].photoPath}');
        
        // Reload pets from Firestore to ensure we have the latest data
        // This ensures the UI shows the updated photoPath
        print('🔄 Reloading pets from Firestore to sync latest data...');
        await loadPets();
        print('✅ Pets reloaded from Firestore');
      } else {
        print('⚠️ Pet with id $id not found in local list');
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update pet.';
      print('Error updating pet: $e');
      print('❌ Stack trace: $stackTrace');
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('not found')) {
        _errorMessage = 'Pet not found. It may have been deleted.';
      } else if (errorString.contains('permission-denied') || errorString.contains('permission denied')) {
        _errorMessage = 'Permission denied. Please check your Firebase security rules.';
      } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
        _errorMessage = 'Update operation timed out. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePet(int id) async {
    // Prevent multiple simultaneous delete operations
    if (_isDeleting || _isLoading) {
      print('⚠️ Delete operation already in progress, ignoring duplicate request');
      print('⚠️ _isDeleting: $_isDeleting, _isLoading: $_isLoading');
      return;
    }
    
    print('🔒 Setting delete guard...');
    _isDeleting = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📦 PetProvider.deletePet called with id: $id');
      
      // Get the Firestore document ID from our mapping
      final firestoreId = _petFirestoreIds[id];
      
      if (firestoreId == null) {
        print('⚠️ No Firestore ID mapping found for pet ID $id, trying to find it...');
        // Try to find the pet in Firestore by querying
        final allPetsWithIds = await FirestoreDatabaseService.getAllPetsWithIds();
        final matchingEntry = allPetsWithIds.firstWhere(
          (entry) {
            final pet = entry['pet'] as PetModel;
            return pet.id == id;
          },
          orElse: () => throw Exception('Pet not found in Firestore'),
        );
        final foundFirestoreId = matchingEntry['firestoreId'] as String;
        print('📦 Found Firestore ID: $foundFirestoreId');
        await FirestoreDatabaseService.deletePet(foundFirestoreId, id);
        // Update the mapping for future use
        _petFirestoreIds[id] = foundFirestoreId;
      } else {
        print('📦 Using mapped Firestore ID: $firestoreId');
        await FirestoreDatabaseService.deletePet(firestoreId, id);
      }
      
      // Remove from local list and mapping
      pets.removeWhere((p) => p.id == id);
      _petFirestoreIds.remove(id);
      _errorMessage = null;
      print('✅ Pet deleted successfully from provider');
      
      // Note: Related data (reminders, health records, etc.) is already deleted from Firestore
      // The providers will automatically update when they reload data from Firestore
    } catch (e, stackTrace) {
      print('❌ PetProvider error deleting pet: $e');
      print('❌ Stack trace: $stackTrace');
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('not found')) {
        _errorMessage = 'Pet not found. It may have already been deleted.';
      } else if (errorString.contains('permission-denied') || errorString.contains('permission denied')) {
        _errorMessage = 'Permission denied. Please check your Firebase security rules.';
      } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
        _errorMessage = 'Delete operation timed out. Please try again.';
      } else {
        _errorMessage = 'Failed to delete pet: ${e.toString()}';
      }
    } finally {
      _isDeleting = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
