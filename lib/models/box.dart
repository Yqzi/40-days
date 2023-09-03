import 'package:flutter/material.dart';

class Box {
  final Color color;
  final DateTime? completionDate;
  int lines;
  int tasks;

  Box({
    this.completionDate,
    this.color = Colors.orange,
    this.lines = 0,
    required this.tasks,
  });

  bool get isToday => completionDate?.day == DateTime.now().day;
  bool get isComplete => lines == tasks;

  @override
  String toString() {
    return "${super.toString()} + $completionDate + $lines";
  }

  @override
  bool operator ==(Object other) {
    if (other is! Box) return false;
    return toString() == other.toString() && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => toString().hashCode;
}
