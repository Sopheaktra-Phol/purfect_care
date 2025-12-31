import 'package:hive/hive.dart';

class ActivityModel {
  int? id;
  int petId;
  String type; // 'walk', 'play', 'exercise', 'training', 'other'
  int duration; // Duration in minutes
  DateTime date;
  String? notes;
  double? distance; // Optional distance in miles/km (for walks)

  ActivityModel({
    this.id,
    required this.petId,
    required this.type,
    required this.duration,
    required this.date,
    this.notes,
    this.distance,
  });
}

// Manual Hive TypeAdapter (typeId = 7)
class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 7;

  @override
  ActivityModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return ActivityModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      type: map['type'] as String,
      duration: map['duration'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      distance: map['distance'] != null ? (map['distance'] as num).toDouble() : null,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'type': obj.type,
      'duration': obj.duration,
      'date': obj.date.toIso8601String(),
      'notes': obj.notes,
      'distance': obj.distance,
    });
  }
}

