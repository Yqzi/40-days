import 'package:flutter/material.dart';
import 'package:forty_days/components/task_details_dialog.dart';
import 'package:forty_days/models/task.dart';

class CustomCheckBox extends StatefulWidget {
  final List<Task> tasks;
  final int i;
  final void Function() verifyDayComplete;
  final void Function(String, Map<String, bool>?)? taskDetails;
  bool edit;

  CustomCheckBox(
      {super.key,
      required this.edit,
      required this.tasks,
      required this.i,
      required this.verifyDayComplete,
      required this.taskDetails});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  bool val = false;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: widget.tasks[widget.i].isChecked,
      title: Text(widget.tasks[widget.i].name),
      onChanged: (value) {
        widget.tasks[widget.i].subList.isNotEmpty
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return widget.edit == true
                      ? TaskDetailsDialog(
                          task: widget.tasks[widget.i],
                          taskDetails: widget.taskDetails,
                        )
                      : AlertDialog(
                          title: Text(widget.tasks[widget.i].name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var j = 0;
                                  j < widget.tasks[widget.i].subList.length;
                                  j++)
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return CheckboxListTile(
                                      value: widget
                                          .tasks[widget.i].subList.values
                                          .elementAt(j),
                                      title: Text(widget
                                          .tasks[widget.i].subList.keys
                                          .elementAt(j)),
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            widget.tasks[widget.i].subList[
                                                widget.tasks[widget.i].subList
                                                    .keys
                                                    .elementAt(j)] = value!;
                                            widget.verifyDayComplete();
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              TextButton(
                                onPressed: () {
                                  if (!widget.tasks[widget.i].subList
                                      .containsKey(false)) {
                                    widget.tasks[widget.i].isChecked = true;
                                  } else {
                                    widget.tasks[widget.i].isChecked = false;
                                  }
                                  widget.verifyDayComplete();
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                                child: const Text("DONE"),
                              )
                            ],
                          ),
                        );
                },
              )
            : widget.edit == true
                ? (
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return TaskDetailsDialog(
                            task: widget.tasks[widget.i],
                            taskDetails: widget.taskDetails,
                          );
                        }),
                  )
                : (widget.tasks[widget.i].isChecked = value!,);
        setState(() {});
        print('value = $value');
        print('tasks = ${widget.tasks[widget.i].isChecked}');
        widget.verifyDayComplete();
      },
    );
  }
}
