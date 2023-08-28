import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDetailsDialog extends StatefulWidget {
  final void Function(String, List<String>?)? taskDetails;
  final Task? task;

  const TaskDetailsDialog({super.key, this.taskDetails, this.task});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  bool ifSubList = false;
  List<String> subNames = [];

  String title = 'Add Task';

  @override
  void initState() {
    if (widget.task != null) {
      title = widget.task!.name;
      taskNameController.text = title;
      widget.task!.subList.forEach((e) {
        subNames.add(e);
      });
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
                      widget.task!.isSubChecked.add(false);
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
                    subNames.add(value);
                    subNamesController.clear();
                    myFocusNode.requestFocus();
                    if (widget.task != null) {
                      widget.task!.isChecked = false;
                      widget.task!.isSubChecked.add(false);
                    }
                  },
                ),
              ),
            if (ifSubList == true)
              for (int i = 0; i < subNames.length; i++) Text(subNames[i]),
            TextButton(
              onPressed: () {
                // List<bool> len = [];
                // subNames.forEach((element) {
                //   len.add(false);
                // });
                widget.task != null
                    ? (
                        widget.task!.name = title,
                        widget.task!.subList = subNames,
                        // widget.task!.isSubChecked = len,
                      )
                    : widget.taskDetails!(title, subNames);
                setState(() {});
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
