import 'package:flutter/material.dart';
import 'package:forty_days/main.dart';

class Box {
  final Color color;
  DateTime? completionDate;
  bool isComplete;
  int lines;
  int tasks;

  Box({
    this.completionDate,
    this.isComplete = false,
    this.lines = 0,
    required this.tasks,
  }) : color = theme.colorScheme.surfaceTint;

  bool get isToday => completionDate?.day == DateTime.now().day;

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
