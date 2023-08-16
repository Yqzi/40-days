import 'dart:ui';

import 'package:flutter/material.dart';

void tasks(List<String> tasks, context) async {
  BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 10,
      sigmaY: 10,
    ),
    child: await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(tasks.toString()),
        );
      },
    ),
  );
}
