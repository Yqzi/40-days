import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/repos/data_base.dart';

class CustomCheckBox extends StatefulWidget {
  final Task task;
  final void Function() verifyDayComplete;
  final void Function(String, Map<String, bool>?, bool, int?)? taskDetails;
  final bool edit;
  final List<Task> allTasks;

  const CustomCheckBox({
    super.key,
    required this.edit,
    required this.task,
    required this.verifyDayComplete,
    required this.taskDetails,
    required this.allTasks,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  CustomDatabase customDatabase = CustomDatabase();
  // @override
  // void dispose() {
  //   widget.task.subList = subTasks;
  //   super.dispose();
  // }

  void updateTask({
    String? name,
    String? sub,
    bool? newChecked,
    bool? ifSelectOne,
    String? prevName,
  }) {
    customDatabase.updateTask(
        name ?? widget.task.name,
        ifSelectOne ?? widget.task.ifSelectOne,
        newChecked ?? widget.task.isChecked,
        sub,
        widget.task.subList[sub ?? widget.task.subList.keys.lastOrNull],
        sub ?? widget.task.subList.keys.lastOrNull,
        task: widget.task,
        prevName: prevName ?? widget.task.name);
  }

  @override
  Widget build(BuildContext context) {
    return widget.edit == true
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Text(widget.task.name),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  FontAwesomeIcons.greaterThan,
                  color: Color.fromARGB(255, 100, 97, 97),
                  size: 10,
                ),
              )
            ],
          )
        : CheckboxListTile(
            value: widget.task.isChecked,
            title: Text(widget.task.name),
            onChanged: (value) {
              widget.task.subList.isNotEmpty
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _Dialog(
                          task: widget.task,
                          verifyDayComplete: widget.verifyDayComplete,
                        );
                      },
                    )
                  : widget.task.isChecked = value!;
              if (widget.task.subList.isEmpty) updateTask(newChecked: value!);
              widget.verifyDayComplete();
            },
          );
  }
}

class _Dialog extends StatefulWidget {
  final Task task;
  final void Function() verifyDayComplete;

  const _Dialog({
    super.key,
    required this.task,
    required this.verifyDayComplete,
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

  void updateTask({
    String? name,
    String? sub,
    bool? newChecked,
    bool? ifSelectOne,
    bool? reset,
    String? prevName,
  }) {
    customDatabase.updateTask(
      name ?? widget.task.name,
      ifSelectOne ?? widget.task.ifSelectOne,
      newChecked ?? widget.task.isChecked,
      sub,
      widget.task.subList[sub ?? widget.task.subList.keys.lastOrNull],
      sub ?? widget.task.subList.keys.lastOrNull,
      reset: reset ?? false,
      task: widget.task,
      prevName: prevName ?? widget.task.name,
    );
  }

  void resetOtherCompletions() {
    Task curr = widget.task;
    if (curr.ifSelectOne) {
      subTasks.reset();
      updateTask(reset: true);
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
                    updateTask(sub: sub.key);
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
