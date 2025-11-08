import 'package:hive/hive.dart';

class HealthRecordModel {
  int? id;
  int petId;
  String title;
  DateTime date;
  String? notes;

  HealthRecordModel({
    this.id,
    required this.petId,
    required this.title,
    required this.date,
    this.notes,
  });
}

// Manual Hive TypeAdapter (typeId = 2)
class HealthRecordModelAdapter extends TypeAdapter<HealthRecordModel> {
  @override
  final int typeId = 2;

  @override
  HealthRecordModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return HealthRecordModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecordModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'title': obj.title,
      'date': obj.date.toIso8  01String(),
      'notes': obj.notes,
    });
  }
}
