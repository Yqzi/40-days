import 'package:flutter/material.dart';

import '../models/task.dart';
import '../repos/data_base.dart';

class TaskDetailsDialog extends StatefulWidget {
  final void Function(String, Map<String, bool>?, bool)? taskDetails;
  final void Function()? verifyDayComplete;
  final Task? task;

  const TaskDetailsDialog({
    super.key,
    this.taskDetails,
    this.task,
    this.verifyDayComplete,
  });

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  CustomDatabase customDatabase = CustomDatabase();
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  Map<String, bool> subNames = {};
  bool ifSelectOne = false;
  bool ifSubList = false;

  String title = 'Add Task';

  @override
  void initState() {
    if (widget.task != null) {
      title = widget.task!.name;
      taskNameController.text = title;
      ifSubList = widget.task!.subList.isNotEmpty;
      subNames = widget.task!.subList;
      ifSelectOne = widget.task!.ifSelectOne;
      widget.task!.subList.reset();
      setState(() {});
    }
    super.initState();
  }

  void updateTask({String? title, bool? checked, String? value, bool? one}) {
    if (title != null) {
      widget.task!.name = title;
    }
    if (checked != null) {
      widget.task!.isChecked = checked;
    }
    if (value != null) {
      widget.task!.addToSublist(value);
    }
    if (one != null) {
      widget.task!.ifSelectOne = one;
    }
    var x;
    widget.task!.subList.forEach((key, value) {
      x = key;
    });

    customDatabase.updateTask(
      widget.task!.name,
      widget.task!.ifSelectOne,
      widget.task!.isChecked,
      x,
      task: widget.task!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ifSubList == false || taskNameController.text == '')
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelText: "Task Name: ",
                ),
                onSubmitted: (value) {
                  setState(() {
                    title = value;
                    if (widget.task != null) {
                      updateTask(title: value);
                    }
                  });
                },
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      ifSubList = !ifSubList;
                    });
                  },
                  child: const Text("ADD SUBLIST +"),
                ),
                TextButton(
                  onPressed: () {
                    ifSelectOne = !ifSelectOne;
                  },
                  child: const Text('Select One?'),
                )
              ],
            ),
            if (ifSubList == true)
              TextField(
                controller: subNamesController,
                focusNode: myFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  labelText: "add sub task: ",
                ),
                onSubmitted: (value) => setState(
                  () {
                    subNames[value] = false;
                    subNamesController.clear();
                    myFocusNode.requestFocus();
                    if (widget.task != null) {
                      updateTask(checked: false, value: value);
                    }
                  },
                ),
              ),
            if (ifSubList == true)
              for (int i = 0; i < subNames.length; i++)
                Text(subNames.keys.elementAt(i)),
            TextButton(
              onPressed: () {
                widget.task != null
                    ? (
                        () => updateTask(
                              title: title,
                              checked: false,
                              one: ifSelectOne,
                            ),
                      )
                    : widget.taskDetails!(title, subNames, ifSelectOne);
                if (widget.task != null) widget.verifyDayComplete!();
                Navigator.of(context).pop();
              },
              child: const Text("DONE"),
            ),
          ],
        ),
      ),
    );
  }
}
