import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return null;
    return _saveFile(File(x.path));
  }

  Future<File?> takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x == null) return null;
    return _saveFile(File(x.path));
  }

  Future<File> _saveFile(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    return file.copy(path);
  }
}