import 'package:flutter/material.dart';

import '../models/task.dart';
import '../repos/data_base.dart';

class TaskDetailsDialog extends StatefulWidget {
  final void Function(String, Map<String, bool>?, bool)? taskDetails;
  final void Function()? verifyDayComplete;
  final Task? task;
  final List<Task> allTasks;

  const TaskDetailsDialog({
    super.key,
    this.taskDetails,
    this.task,
    this.verifyDayComplete,
    required this.allTasks,
  });

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  CustomDatabase customDatabase = CustomDatabase();
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  Map<String, bool> subNames = {};
  bool ifSelectOne = false;
  bool ifSubList = false;
  late String prevName;

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

  void updateTask(
      {String? title, bool? checked, String? sub, bool? one, bool? addNewSub}) {
    if (title != null) {
      prevName = widget.task!.name;
      widget.task!.name = title;
    }
    if (checked != null) {
      widget.task!.isChecked = checked;
    }
    if (one != null) {
      widget.task!.ifSelectOne = one;
    }
    customDatabase.updateTask(
      widget.task!.name,
      widget.task!.ifSelectOne,
      widget.task!.isChecked,
      sub,
      widget.task!.subList[sub ?? widget.task!.subList.keys.lastOrNull],
      sub ?? widget.task!.subList.keys.lastOrNull,
      task: widget.task!,
      addNewSub: addNewSub ?? false,
      prevName: prevName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: GestureDetector(
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
                TextFormField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: "Task Name: ",
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Please enter some text";
                    }

                    if (!widget.allTasks.every((e) => e.name != text) &&
                        title != taskNameController.text) {
                      return "Task already exists";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        title = value;
                        if (widget.task != null) {
                          updateTask(title: value);
                        }
                      });
                    }
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
                      if (widget.task != null) {
                        updateTask(checked: false, sub: value, addNewSub: true);
                      }
                      subNames[value] = false;
                      subNamesController.clear();
                      myFocusNode.requestFocus();
                    },
                  ),
                ),
              if (ifSubList == true)
                for (int i = 0; i < subNames.length; i++)
                  Text(subNames.keys.elementAt(i)),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.task != null
                        ? ()
                        : widget.taskDetails!(title, subNames, ifSelectOne);
                    if (widget.task != null) {
                      widget.verifyDayComplete!();
                      title = taskNameController.text;
                      updateTask(
                        title: title,
                        checked: false,
                        one: ifSelectOne,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("DONE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
