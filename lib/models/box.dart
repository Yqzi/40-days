import 'package:flutter/material.dart';

class Box {
  final Color color;
  final DateTime? completionDate;
  bool complete;
  int lines;
  int tasks;

  Box({
    this.completionDate,
    this.complete = false,
    this.color = Colors.orange,
    this.lines = 0,
    this.tasks = 0,
  });

  bool get isToday => completionDate?.day == DateTime.now().day;

  @override
  bool operator ==(Object other) {
    if (other is! Box) return false;
    return other.lines == lines && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => lines.hashCode;
}
