import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Box {
  final Color color;
  final bool isComplete;

  Box({this.isComplete = false, this.color = Colors.orange});

  Container createBox() {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isComplete == true ? const Icon(FontAwesomeIcons.x) : null,
    );
  }
}
