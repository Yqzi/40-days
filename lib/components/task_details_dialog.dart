import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/task.dart';
import '../repos/data_base.dart';

class TaskDetailsDialog extends StatefulWidget {
  final void Function(String, Map<String, bool>?, bool, int?)? taskDetails;
  final void Function()? verifyDayComplete;
  final Task? task;
  final int? index;
  final List<Task> allTasks;

  const TaskDetailsDialog({
    super.key,
    this.taskDetails,
    this.task,
    this.verifyDayComplete,
    required this.allTasks,
    this.index,
  });

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final _taskFormKey = GlobalKey<FormState>();
  CustomDatabase customDatabase = CustomDatabase();
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode taskFocusNode = FocusNode();
  FocusNode subFocusNode = FocusNode();
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
    prevName = widget.task!.name;
    if (title != null) {
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

  void updateName() {
    if (taskNameController.text.isNotEmpty || taskNameController.text != '') {
      if (_taskFormKey.currentState!.validate()) {
        title = taskNameController.text;
        if (widget.task != null) {
          updateTask(title: title);
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _taskFormKey,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          updateName();
        },
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: taskNameController,
                  focusNode: taskFocusNode,
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
                    if (_taskFormKey.currentState!.validate()) {
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
                          updateName();
                        });
                      },
                      child: ifSubList
                          ? const Row(
                              children: [
                                Text(
                                  "Sublist Added ",
                                  style: TextStyle(color: Colors.green),
                                ),
                                Icon(
                                  FontAwesomeIcons.check,
                                  color: Colors.green,
                                  size: 15,
                                )
                              ],
                            )
                          : const Text("ADD SUBLIST +"),
                    ),
                    TextButton(
                      onPressed: () {
                        ifSelectOne = !ifSelectOne;
                        updateName();
                        setState(() {});
                      },
                      child: ifSelectOne
                          ? const Text(
                              'Select One',
                              style: TextStyle(color: Colors.green),
                            )
                          : const Text('Select One?'),
                    )
                  ],
                ),
                if (ifSubList == true)
                  TextFormField(
                    controller: subNamesController,
                    focusNode: subFocusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      labelText: "add sub task: ",
                    ),
                    onFieldSubmitted: (value) => setState(
                      () {
                        if (subNamesController.text.isNotEmpty) {
                          if (widget.task != null) {
                            updateTask(
                                checked: false, sub: value, addNewSub: true);
                          }
                          subNames[value] = false;
                          subNamesController.clear();
                          subFocusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                if (ifSubList)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: Scrollbar(
                      trackVisibility: true,
                      thickness: 3,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < subNames.length; i++)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    subNames.keys.elementAt(i),
                                  ),
                                ),
                              SizedBox(
                                height: 8,
                                child: Container(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    if (_taskFormKey.currentState!.validate()) {
                      updateName();
                      if (widget.task != null &&
                          !subNames.containsKey(subNamesController.text) &&
                          ifSubList) {
                        updateTask(
                            sub: subNamesController.text, addNewSub: true);
                        widget.verifyDayComplete!();
                        updateTask(
                          title: title,
                          checked: false,
                          one: ifSelectOne,
                        );
                      }
                      if (subNamesController.text.isNotEmpty) {
                        subNames[subNamesController.text] = false;
                      }
                      widget.taskDetails!(
                        title,
                        subNames,
                        ifSelectOne,
                        widget.index,
                      );
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("DONE"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
