import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          ? const Icon(FontAwesomeIcons.faceSmile)
              .animate()
              .fadeOut(duration: Duration(seconds: 1))
          : box.isComplete
              ? const Icon(FontAwesomeIcons.faceSmile)
                  .animate()
                  .fade(duration: Duration(seconds: 1))
              : CustomPaint(
                  foregroundPainter: LinePainter(lines: box.lines),
                ).animate().fadeIn(duration: Duration(seconds: 1)),
    );
  }
}

class LinePainter extends CustomPainter {
  int lines;

  LinePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < lines; i++) {
      canvas.drawLine(
        Offset(size.width / (lines + 1) * (i + 1), size.height / 6),
        Offset(size.width / (lines + 1) * (i + 1), size.height * 5 / 6),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
