import 'package:hive/hive.dart';

class PetPhotoModel {
  int? id;
  int petId;
  String photoUrl; // Firebase Storage URL
  String? thumbnailUrl; // Optional thumbnail URL
  DateTime dateTaken;
  String? caption;
  bool isPrimary; // Whether this is the primary photo for the pet

  PetPhotoModel({
    this.id,
    required this.petId,
    required this.photoUrl,
    this.thumbnailUrl,
    required this.dateTaken,
    this.caption,
    this.isPrimary = false,
  });
}

// Manual Hive TypeAdapter (typeId = 6)
class PetPhotoModelAdapter extends TypeAdapter<PetPhotoModel> {
  @override
  final int typeId = 6;

  @override
  PetPhotoModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return PetPhotoModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      photoUrl: map['photoUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      dateTaken: DateTime.parse(map['dateTaken'] as String),
      caption: map['caption'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, PetPhotoModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'photoUrl': obj.photoUrl,
      'thumbnailUrl': obj.thumbnailUrl,
      'dateTaken': obj.dateTaken.toIso8601String(),
      'caption': obj.caption,
      'isPrimary': obj.isPrimary,
    });
  }
}

