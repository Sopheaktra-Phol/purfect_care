import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Get the images directory, creating it if it doesn't exist
  Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'pet_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Pick an image from gallery and save it permanently
  Future<File?> pickImageFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return null;
    return await _saveFile(File(x.path));
  }

  /// Take a photo and save it permanently
  Future<File?> takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x == null) return null;
    return await _saveFile(File(x.path));
  }

  /// Save file to permanent storage in the images directory
  Future<File> _saveFile(File sourceFile) async {
    final imagesDir = await _getImagesDirectory();
    // Get file extension from original file
    final extension = path.extension(sourceFile.path);
    // Create unique filename with timestamp
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final destPath = path.join(imagesDir.path, fileName);
    final destFile = File(destPath);
    
    // Copy the file to permanent location
    await sourceFile.copy(destPath);
    return destFile;
  }

  /// Delete an image file by its path
  Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      // Log error but don't throw
      print('Error deleting image: $e');
    }
    return false;
  }

  /// Check if an image file exists
  Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get a File object for an image path, or null if it doesn't exist
  Future<File?> getImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = File(imagePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}