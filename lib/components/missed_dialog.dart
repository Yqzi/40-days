import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/box.dart';
import '../models/task.dart';
import '../repos/shared_prefs.dart';

class MissedDialog extends StatelessWidget {
  final void Function() completeMissedDays;
  final void Function() setState;
  final Preferences prefs;
  final List<Task> tasks;
  final List<Box> boxes;

  const MissedDialog({
    super.key,
    required this.tasks,
    required this.boxes,
    required this.prefs,
    required this.setState,
    required this.completeMissedDays,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      contentPadding: const EdgeInsets.only(
          top: 20.0, right: 24.0, left: 24.0, bottom: 16.0),
      actionsPadding:
          const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 0.0),
      title: Row(
        children: [
          Expanded(flex: 1, child: Container()),
          const Expanded(
            flex: 8,
            child: Text(
              'ALERT',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              splashRadius: 15,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AlertDialog(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      title: const Text(
                        'Selecting YES means you keep your progress and the "days missed" will be completed',
                        textAlign: TextAlign.center,
                      ),
                      contentPadding:
                          const EdgeInsets.only(right: 24, left: 24, top: 10),
                      content: const Text(
                        '*This should only be used if you forgot to mark*',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10),
                      ),
                      actionsPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('NO'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text('YES'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    // Auto complete missed days
                    completeMissedDays();
                    // reset task completion

                    Navigator.pop(context);
                  }
                });
              },
              icon: const Icon(FontAwesomeIcons.gear),
            ),
          )
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have missed a day! The 40 days will now reset.',
            textAlign: TextAlign.center,
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0, bottom: 0.0),
            child: Text(
              '* If There was a mistake press the settings icon in the top right corner',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            int i = 0;
            Navigator.pop(context);
            boxes.forEach(
              (e) {
                if (e.isComplete) {
                  e.isComplete = false;
                  e.completionDate = null;
                  prefs.removeDay(i);
                  i++;
                }
                return;
              },
            );
            for (Task task in tasks) {
              if (task.subList.isEmpty) {
                task.isChecked = false;
              } else {
                for (var key in task.subList.keys) {
                  task.subList[key] = false;
                }
                task.isChecked = false;
              }
            }
            setState();
          },
          child: const Text('DONE'),
        ),
      ],
    );
  }
}
