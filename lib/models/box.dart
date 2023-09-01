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
    this.tasks = 0,
  });

  Container createBox() {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: completionDate == null
          ? null
          : CustomPaint(
              foregroundPainter: LinePainter(lines: lines, tasks: tasks),
            ),
    );
  }

  bool get isToday => completionDate?.day == DateTime.now().day;
}

class LinePainter extends CustomPainter {
  int lines;
  int tasks;

  LinePainter({required this.lines, required this.tasks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

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
