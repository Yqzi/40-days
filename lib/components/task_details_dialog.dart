import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDetailsDialog extends StatefulWidget {
  final void Function(String, Map<String, bool>?)? taskDetails;
  final void Function()? verifyDayComplete;
  final Task? task;

  const TaskDetailsDialog(
      {super.key, this.taskDetails, this.task, this.verifyDayComplete});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  bool ifSubList = false;
  Map<String, bool> subNames = {};

  String title = 'Add Task';

  @override
  void initState() {
    if (widget.task != null) {
      title = widget.task!.name;
      taskNameController.text = title;
      ifSubList = widget.task!.subList.isNotEmpty;
      subNames = widget.task!.subList;
      setState(() {});
    }
    super.initState();
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
                      widget.task!.name = value;
                    }
                  });
                },
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  ifSubList = !ifSubList;
                });
              },
              child: const Text("ADD SUBLIST +"),
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
                      widget.task!.isChecked = false;
                      widget.task!.addToSublist = value;
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
                        widget.task!.name = title,
                        widget.task!.isChecked = false,
                      )
                    : widget.taskDetails!(title, subNames);
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
