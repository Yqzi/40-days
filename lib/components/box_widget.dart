import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/box.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.box});

  final Box box;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: box.color,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: box.completionDate == null
          ? null
          : box.complete == true
              ? const Icon(FontAwesomeIcons.faceSmile)
              : CustomPaint(
                  foregroundPainter:
                      LinePainter(lines: box.lines, tasks: box.tasks),
                ),
    );
  }
}

class LinePainter extends CustomPainter {
  int lines;
  int tasks;

  LinePainter({required this.lines, required this.tasks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    print(lines);

    for (int i = 0; i < lines; i++) {
      canvas.drawLine(
        Offset(size.width / (tasks + 1) * (i + 1), size.height / 6),
        Offset(size.width / (tasks + 1) * (i + 1), size.height * 5 / 6),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
