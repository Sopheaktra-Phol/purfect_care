import 'package:hive/hive.dart';

class ExpenseModel {
  int? id;
  int petId;
  String category; // 'vet', 'food', 'grooming', 'toys', 'medication', 'other'
  double amount;
  DateTime date;
  String description;
  String? receiptUrl; // Optional Firebase Storage URL for receipt photo

  ExpenseModel({
    this.id,
    required this.petId,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.receiptUrl,
  });
}

// Manual Hive TypeAdapter (typeId = 8)
class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 8;

  @override
  ExpenseModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read());
    return ExpenseModel(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      receiptUrl: map['receiptUrl'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer.write({
      'id': obj.id,
      'petId': obj.petId,
      'category': obj.category,
      'amount': obj.amount,
      'date': obj.date.toIso8601String(),
      'description': obj.description,
      'receiptUrl': obj.receiptUrl,
    });
  }
}

