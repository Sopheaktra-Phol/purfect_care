import 'package:hive/hive.dart';

class ReminderModel {
  int? id;
  int petId;
  String title;
  DateTime time;
  String repeat; // 'none' | 'daily' | 'weekly'
  int? notificationId;
  bool isCompleted;

  ReminderModel({
    this.id,
    required this.petId,
    required this.title,
    required this.time,
    this.repeat = 'none',
    this.notificationId,
    this.isCompleted = false,
  });
}

// Manual Hive TypeAdapter (typeId = 1)
class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 1;

  @override
  ReminderModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return ReminderModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      repeat: map['repeat'] as String,
      notificationId: map['notificationId'] as int?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'title': obj.title,
      'time': obj.time.toIso8601String(),
      'repeat': obj.repeat,
      'notificationId': obj.notificationId,
      'isCompleted': obj.isCompleted,
    });
  }
}
