import 'package:flutter/material.dart';
import 'package:forty_days/components/task_details_dialog.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/repos/data_base.dart';

class CustomCheckBox extends StatefulWidget {
  final Task task;
  final void Function() verifyDayComplete;
  final void Function(String, Map<String, bool>?, bool)? taskDetails;
  final bool edit;

  const CustomCheckBox({
    super.key,
    required this.edit,
    required this.task,
    required this.verifyDayComplete,
    required this.taskDetails,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  // @override
  // void dispose() {
  //   widget.task.subList = subTasks;
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: widget.task.isChecked,
      title: Text(widget.task.name),
      onChanged: (value) {
        widget.task.subList.isNotEmpty
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return widget.edit == true
                      ? TaskDetailsDialog(
                          task: widget.task,
                          taskDetails: widget.taskDetails,
                          verifyDayComplete: widget.verifyDayComplete,
                        )
                      : _Dialog(
                          task: widget.task,
                          verifyDayComplete: widget.verifyDayComplete,
                          taskDetails: widget.taskDetails,
                        );
                },
              )
            : widget.edit == true
                ? (
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return TaskDetailsDialog(
                            task: widget.task,
                            taskDetails: widget.taskDetails,
                            verifyDayComplete: widget.verifyDayComplete,
                          );
                        }),
                  )
                : (widget.task.isChecked = value!,);
        widget.verifyDayComplete();
      },
    );
  }
}

class _Dialog extends StatefulWidget {
  final Task task;
  final void Function() verifyDayComplete;
  final void Function(String, Map<String, bool>?, bool)? taskDetails;

  const _Dialog({
    super.key,
    required this.task,
    required this.verifyDayComplete,
    this.taskDetails,
  });

  @override
  State<_Dialog> createState() => __DialogState();
}

class __DialogState extends State<_Dialog> {
  late Map<String, bool> subTasks;
  CustomDatabase customDatabase = CustomDatabase();

  @override
  void initState() {
    super.initState();
    subTasks = widget.task.subList;
  }

  void updateTask(
      {String? name, bool? sub, bool? newChecked, bool? ifSelectOne}) {
    var x;
    widget.task.subList.forEach((key, value) {
      x = key;
    });
    customDatabase.updateTask(
      name ?? widget.task.name,
      ifSelectOne ?? widget.task.ifSelectOne,
      newChecked ?? widget.task.isChecked,
      sub ?? x,
      task: widget.task,
    );
  }

  void resetOtherCompletions() {
    Task curr = widget.task;
    if (curr.ifSelectOne) {
      subTasks.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var sub in subTasks.entries)
            CheckboxListTile(
              value: sub.value,
              title: Text(sub.key),
              onChanged: (value) {
                setState(
                  () {
                    resetOtherCompletions();
                    subTasks[sub.key] = value!;
                    updateTask(sub: value);
                    widget.verifyDayComplete();
                  },
                );
              },
            ),
          TextButton(
            onPressed: () {
              bool y = false;
              if (!widget.task.subList.containsValue(false)) {
                widget.task.isChecked = true;
                y = true;
              } else if (subTasks.containsValue(true) &&
                  widget.task.ifSelectOne == true) {
                widget.task.isChecked = true;
                y = true;
              } else {
                widget.task.isChecked = false;
                y = false;
              }
              updateTask(newChecked: y);
              widget.verifyDayComplete();
              Navigator.of(context).pop();
            },
            child: const Text("DONE"),
          )
        ],
      ),
    );
  }
}
