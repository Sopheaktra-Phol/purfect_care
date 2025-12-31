import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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

  /// Upload image to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadPhotoToFirebase(File imageFile, String petId) async {
    try {
      print('📤 Starting Firebase Storage upload...');
      print('📤 Image file path: ${imageFile.path}');
      print('📤 Pet ID: $petId');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user for Firebase Storage upload');
        print('❌ User must be signed in to upload images');
        return null;
      }

      final userId = user.uid;
      print('📤 User ID: $userId');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        print('❌ Image file does not exist: ${imageFile.path}');
        return null;
      }
      
      // Get Firebase Storage instance (uses bucket from GoogleService-Info.plist automatically)
      final storage = FirebaseStorage.instance;
      print('📤 Firebase Storage instance obtained');
      
      // Verify Firebase is initialized
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase is not initialized. Please restart the app.');
      }
      print('✅ Firebase is initialized (${Firebase.apps.length} app(s))');
      
      // Create unique filename with timestamp
      final extension = path.extension(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageId = '$timestamp$extension';
      
      // Storage path: pet_images/{userId}/{petId}/{imageId}
      final storagePath = 'pet_images/$userId/$petId/$imageId';
      final storageRef = storage.ref().child(storagePath);
      
      print('📤 Uploading image to Firebase Storage: $storagePath');
      
      // Determine content type based on extension
      String contentType = 'image/jpeg'; // Default
      final ext = extension.toLowerCase();
      if (ext == '.png') {
        contentType = 'image/png';
      } else if (ext == '.jpg' || ext == '.jpeg') {
        contentType = 'image/jpeg';
      } else if (ext == '.gif') {
        contentType = 'image/gif';
      } else if (ext == '.webp') {
        contentType = 'image/webp';
      }
      
      // Upload the file with timeout
      print('📤 Starting file upload...');
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'petId': petId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Wait for upload to complete with timeout (30 seconds)
      print('📤 Waiting for upload to complete...');
      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask.timeout(
          const Duration(seconds: 30),
        );
      } on TimeoutException {
        print('❌ Upload timeout after 30 seconds');
        // Don't cancel if it might cause channel errors - just let it fail naturally
        try {
          await uploadTask.cancel().timeout(const Duration(seconds: 2));
        } catch (e) {
          print('⚠️ Could not cancel upload task: $e');
        }
        throw Exception('Upload timed out after 30 seconds. Please check your internet connection and Firebase Storage setup.');
      } catch (e) {
        // Catch any other errors during upload
        print('❌ Upload error: $e');
        rethrow;
      }
      
      print('📤 Upload completed, getting download URL...');
      
      // Get download URL with timeout
      String downloadUrl;
      try {
        downloadUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
        );
      } on TimeoutException {
        print('❌ Getting download URL timed out');
        throw Exception('Getting download URL timed out. Please try again.');
      }
      
      print('✅ Image uploaded successfully: $downloadUrl');
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage error: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized') {
        print('❌ Permission denied - check Firebase Storage security rules');
      } else if (e.code == 'canceled') {
        print('❌ Upload was canceled');
      } else if (e.code == 'unknown') {
        print('❌ Unknown error - check network connection');
      }
      return null;
    } on TimeoutException catch (e) {
      print('❌ Upload timeout: $e');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error uploading image to Firebase Storage: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete photo from Firebase Storage
  Future<bool> deletePhotoFromFirebase(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) {
        return false;
      }
      
      // Check if it's a Firebase Storage URL
      if (!photoUrl.contains('firebasestorage.googleapis.com')) {
        // Not a Firebase Storage URL, might be a local path
        print('⚠️ URL is not a Firebase Storage URL, skipping delete: $photoUrl');
        return false;
      }
      
      // Get Firebase Storage instance
      final storage = FirebaseStorage.instance;
      
      // Extract the path from the download URL
      // URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token={token}
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the 'o' segment which indicates the object path
      final oIndex = pathSegments.indexOf('o');
      if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
        print('❌ Could not parse Firebase Storage URL: $photoUrl');
        return false;
      }
      
      // Get the path after 'o' and decode it (URL encoded)
      final encodedPath = pathSegments[oIndex + 1];
      final decodedPath = Uri.decodeComponent(encodedPath);
      
      print('🗑️ Deleting image from Firebase Storage: $decodedPath');
      
      // Delete the file
      final storageRef = storage.ref().child(decodedPath);
      await storageRef.delete();
      
      print('✅ Image deleted successfully from Firebase Storage');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error deleting image from Firebase Storage: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    }
  }
}