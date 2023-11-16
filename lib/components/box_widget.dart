import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/box.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.box, required this.index});

  final Box box;
  final int index;

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
              .shake(duration: const Duration(milliseconds: 600))
              .then()
              .swap(
                  delay: Duration(milliseconds: 50 * (39 - index)),
                  duration: const Duration(milliseconds: 200),
                  builder: (BuildContext context, _) {
                    return const Icon(FontAwesomeIcons.smog);
                  })
              .then()
              .fadeOut(duration: const Duration(seconds: 1))
          : box.isComplete
              ? const Icon(FontAwesomeIcons.faceSmile)
                  .animate()
                  .fade(duration: const Duration(seconds: 2))
              : CustomPaint(
                  foregroundPainter: LinePainter(lines: box.lines),
                ),
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
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
