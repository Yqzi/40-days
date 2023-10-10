import 'package:flutter/material.dart';

class Slideablewidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onSlide;
  final double actionThreshold;

  const Slideablewidget({
    required this.child,
    required this.onSlide,
    this.actionThreshold = 0.1,
    super.key,
  });

  @override
  State<Slideablewidget> createState() => _SlideablewidgetState();
}

class _SlideablewidgetState extends State<Slideablewidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => SlideTransition(
            position: AlwaysStoppedAnimation(Offset(_controller.value, 0)),
            child: widget.child,
          ),
        ),
      );

  void onDragStart(DragStartDetails details) {
    _dragExtent = 0;
    _controller.reset();
    setState(() {});
  }

  void onDragUpdate(DragUpdateDetails details) {
    _dragExtent += details.primaryDelta!;
    if (_dragExtent <= 0) {
      return;
    }
    _controller.value = _dragExtent.abs() / context.size!.width;
  }

  void onDragEnd(DragEndDetails details) {
    if (_controller.value > widget.actionThreshold) {
      widget.onSlide;
    }
    _controller.fling(velocity: -1);
  }
}
