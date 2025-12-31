import 'package:hive/hive.dart';

class VaccinationModel {
  int? id;
  int petId;
  String vaccineName;
  DateTime dateGiven;
  DateTime? nextDueDate;
  String? vetName;
  String? notes;
  int? reminderId; // ID of the reminder created for next due date

  VaccinationModel({
    this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateGiven,
    this.nextDueDate,
    this.vetName,
    this.notes,
    this.reminderId,
  });
}

// Manual Hive TypeAdapter (typeId = 5)
class VaccinationModelAdapter extends TypeAdapter<VaccinationModel> {
  @override
  final int typeId = 5;

  @override
  VaccinationModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return VaccinationModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      vaccineName: map['vaccineName'] as String,
      dateGiven: DateTime.parse(map['dateGiven'] as String),
      nextDueDate: map['nextDueDate'] != null ? DateTime.parse(map['nextDueDate'] as String) : null,
      vetName: map['vetName'] as String?,
      notes: map['notes'] as String?,
      reminderId: map['reminderId'] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'vaccineName': obj.vaccineName,
      'dateGiven': obj.dateGiven.toIso8601String(),
      'nextDueDate': obj.nextDueDate?.toIso8601String(),
      'vetName': obj.vetName,
      'notes': obj.notes,
      'reminderId': obj.reminderId,
    });
  }
}

