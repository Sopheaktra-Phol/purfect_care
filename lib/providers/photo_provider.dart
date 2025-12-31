import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purfect_care/models/pet_photo_model.dart';
import 'package:purfect_care/services/image_service.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class PhotoProvider extends ChangeNotifier {
  final Map<int, List<PetPhotoModel>> _photos = {}; // petId -> list of photos
  bool _isLoading = false;
  String? _errorMessage;
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ImageService _imageService = ImageService();

  List<PetPhotoModel> getPhotos(int petId) {
    return _photos[petId] ?? [];
  }

  bool hasLoadedPhotos(int petId) {
    return _photos.containsKey(petId);
  }

  // Get primary photo for a pet
  PetPhotoModel? getPrimaryPhoto(int petId) {
    final photos = _photos[petId];
    if (photos == null || photos.isEmpty) return null;
    return photos.firstWhere(
      (p) => p.isPrimary,
      orElse: () => photos.first, // Return first photo if no primary set
    );
  }

  Future<void> loadPhotos(int petId) async {
    // Don't reload if we've already loaded photos for this pet (even if empty)
    if (_photos.containsKey(petId)) {
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photos = await FirestoreDatabaseService.getPhotosForPet(petId.toString());
      _photos[petId] = photos;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load photos.';
      print('Error loading photos: $e');
      _photos[petId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPhoto(File imageFile, int petId, {String? caption, bool isPrimary = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📸 PhotoProvider.addPhoto called for pet $petId');
      print('📸 Image file: ${imageFile.path}');
      
      // Upload photo to Firebase Storage
      print('📸 Starting Firebase Storage upload...');
      final photoUrl = await _imageService.uploadPhotoToFirebase(imageFile, petId.toString());
      
      if (photoUrl == null) {
        _errorMessage = 'Failed to upload photo to Firebase Storage. Please check your internet connection and try again.';
        print('❌ Photo upload failed - photoUrl is null');
        print('❌ Check console logs above for detailed error messages');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      print('✅ Photo uploaded successfully! URL: $photoUrl');

      // If setting as primary, unset other primary photos
      if (isPrimary) {
        final existingPhotos = _photos[petId] ?? [];
        for (var photo in existingPhotos) {
          if (photo.isPrimary) {
            photo.isPrimary = false;
          }
        }
      }

      // Create photo model
      final photo = PetPhotoModel(
        petId: petId,
        photoUrl: photoUrl,
        dateTaken: DateTime.now(),
        caption: caption,
        isPrimary: isPrimary,
      );

      final id = await FirestoreDatabaseService.addPhoto(photo);
      photo.id = int.tryParse(id) ?? 0;
      _photos[petId] ??= [];
      _photos[petId]!.add(photo);
      // Sort by date taken descending
      _photos[petId]!.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add photo.';
      print('Error adding photo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePhoto(int petId, int id, PetPhotoModel photo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // If setting as primary, unset other primary photos
      if (photo.isPrimary) {
        final existingPhotos = _photos[petId] ?? [];
        for (var existingPhoto in existingPhotos) {
          if (existingPhoto.isPrimary && existingPhoto.id != id) {
            existingPhoto.isPrimary = false;
          }
        }
      }

      await FirestoreDatabaseService.updatePhoto(id.toString(), photo);
      final photos = _photos[petId] ?? [];
      final idx = photos.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        photos[idx] = photo;
        // Sort by date taken descending
        photos.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update photo.';
      print('Error updating photo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePhoto(int petId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get photo to delete (to delete from Firebase Storage and local file)
      final photo = _photos[petId]?.firstWhere((p) => p.id == id);
      
      // Delete from Firestore first
      await FirestoreDatabaseService.deletePhoto(id.toString());
      
      // Delete from Firebase Storage if it's a Firebase URL
      if (photo != null) {
        // Try to delete from Firebase Storage
        await _imageService.deletePhotoFromFirebase(photo.photoUrl);
        
        // Also try to delete local file if it exists (for backward compatibility)
        await _imageService.deleteImage(photo.photoUrl);
      }
      
      _photos[petId]?.removeWhere((p) => p.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete photo.';
      print('Error deleting photo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPrimaryPhoto(int petId, int id) async {
    final photos = _photos[petId];
    if (photos == null) return;

    final photo = photos.firstWhere((p) => p.id == id);
    if (photo.isPrimary) return; // Already primary

    // Unset other primary photos
    for (var p in photos) {
      if (p.isPrimary && p.id != id) {
        p.isPrimary = false;
      }
    }

    // Set this photo as primary
    photo.isPrimary = true;
    await updatePhoto(petId, id, photo);
  }

  // Clear all photos for a pet (used when pet is deleted)
  void deleteAllPhotosForPet(int petId) {
    _photos.remove(petId);
    notifyListeners();
  }
}

