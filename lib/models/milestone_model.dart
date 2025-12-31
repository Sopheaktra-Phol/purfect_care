import 'package:hive/hive.dart';

class MilestoneModel {
  int? id;
  int petId;
  String title;
  DateTime date;
  String type; // 'birthday', 'adoption', 'custom'
  String? notes;

  MilestoneModel({
    this.id,
    required this.petId,
    required this.title,
    required this.date,
    required this.type,
    this.notes,
  });
}

// Manual Hive TypeAdapter (typeId = 4)
class MilestoneModelAdapter extends TypeAdapter<MilestoneModel> {
  @override
  final int typeId = 4;

  @override
  MilestoneModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return MilestoneModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      notes: map['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MilestoneModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'title': obj.title,
      'date': obj.date.toIso8601String(),
      'type': obj.type,
      'notes': obj.notes,
    });
  }
}

