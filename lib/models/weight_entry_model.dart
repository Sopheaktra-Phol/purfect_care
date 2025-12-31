import 'package:hive/hive.dart';

class WeightEntryModel {
  int? id;
  int petId;
  double weight;
  DateTime date;
  String? notes;

  WeightEntryModel({
    this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
  });
}

// Manual Hive TypeAdapter (typeId = 3)
class WeightEntryModelAdapter extends TypeAdapter<WeightEntryModel> {
  @override
  final int typeId = 3;

  @override
  WeightEntryModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return WeightEntryModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntryModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'weight': obj.weight,
      'date': obj.date.toIso8601String(),
      'notes': obj.notes,
    });
  }
}

