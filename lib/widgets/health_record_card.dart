import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record_model.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecordModel record;

  const HealthRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(record.title),
        subtitle: Text(DateFormat.yMd().format(record.date)),
        trailing: record.notes != null ? const Icon(Icons.notes) : null,
      ),
    );
  }
}
