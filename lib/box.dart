import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Box {
  final Color color;
  final DateTime? completionDate;

  Box({this.completionDate, this.color = Colors.orange});

  Container createBox() {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: completionDate == null ? null : const Icon(FontAwesomeIcons.x),
    );
  }

  bool get isToday => completionDate?.day == DateTime.now().day;
}
