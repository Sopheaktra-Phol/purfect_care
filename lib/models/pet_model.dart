import 'package:hive/hive.dart';

class PetModel {
  int? id;
  String name;
  String species;
  String gender;
  int age;
  String breed;
  String? photoPath;
  String? notes;
  String? weight;
  String? height;
  String? color;

  PetModel({
    this.id,
    required this.name,
    required this.species,
    required this.gender,
    required this.age,
    required this.breed,
    this.photoPath,
    this.notes,
    this.weight,
    this.height,
    this.color,
  });
}

// Manual Hive TypeAdapter (typeId = 0)
class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 0;

  @override
  PetModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return PetModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      species: map['species'] as String,
      gender: map['gender'] as String? ?? 'Unknown', // Backward compatibility: handle null for old data
      age: map['age'] as int,
      breed: map['breed'] as String,
      photoPath: map['photoPath'] as String?,
      notes: map['notes'] as String?,
      weight: map['weight'] as String?,
      height: map['height'] as String?,
      color: map['color'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer.write({
      'id': obj.id,
      'name': obj.name,
      'species': obj.species,
      'gender': obj.gender,
      'age': obj.age,
      'breed': obj.breed,
      'photoPath': obj.photoPath,
      'notes': obj.notes,
      'weight': obj.weight,
      'height': obj.height,
      'color': obj.color,
    });
  }
}
