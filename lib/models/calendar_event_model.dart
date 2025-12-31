import 'package:flutter/material.dart';

class CalendarEventModel {
  final String id;
  final String type; // 'reminder', 'vaccination', 'health', 'milestone', 'activity', 'expense'
  final String title;
  final DateTime date;
  final TimeOfDay? time;
  final int? petId;
  final Color color;
  final dynamic originalData; // The original model object

  CalendarEventModel({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.time,
    this.petId,
    required this.color,
    this.originalData,
  });
}

