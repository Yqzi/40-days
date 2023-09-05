import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/models/box.dart';
import 'package:forty_days/components/custom_checkBox.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/repos/data_base.dart';
import 'package:forty_days/repos/shared_prefs.dart';

import 'components/box_widget.dart';
import 'components/task_details_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(home: Home()),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Preferences _prefs = Preferences();
  final CustomDatabase customDatabase = CustomDatabase();
  List<Task> tasks = [];
  List<Box> boxes = [];
  DateTime yesterday = DateTime.now();
  bool edit = false;

  void addTask(String name, Map<String, bool>? subList, bool ifSelectOne) {
    tasks.add(
      Task(name: name, subList: subList ?? {}, ifSelectOne: ifSelectOne),
    );
    customDatabase.createTask(
        name: name, checked: false, ifSelectOne: ifSelectOne);
    if (subList!.isNotEmpty) {
      for (var sName in subList.keys) {
        customDatabase.createSubTask(
          parentName: name,
          subName: sName,
          subChecked: false,
        );
      }
    }

    verifyDayComplete();
    setState(() {});
  }

  void addDay([int? completed]) async {
    if (boxes.isEmpty) {
      for (int i = 0; i < 40; i++) {
        Map? x = await _prefs.loadDays(i.toString());
        boxes.add(
          x == null
              ? Box(tasks: tasks.length)
              : Box(
                  completionDate: x['completionDate'],
                  isComplete: x['isComplete'],
                  lines: x['lines'],
                  tasks: x['tasks'],
                ),
        );
      }
    }
    setState(() {});
  }

  void verifyDayComplete() {
    int index = boxes.indexWhere((e) => e.completionDate == null);
    int lines = tasks.where((e) => e.isChecked == true).length;
    var y = 0;

    if (lines == tasks.length && lines > 0) {
      var x = index > 0 ? index - 1 : index;
      boxes[x] = Box(
        completionDate: DateTime.now(),
        isComplete: true,
        tasks: tasks.length,
        lines: lines,
      );
      _prefs.saveDays(
        index: x.toString(),
        completionDate: boxes[x].completionDate!,
        isComplete: true,
        lines: lines,
        tasks: tasks.length,
      );
      setState(() {});
      return;
    }

    if (lines > 0) {
      if (index > 0 && boxes[index - 1].isToday) {
        boxes[index - 1].isComplete = false;
        boxes[index - 1].lines = lines;
        y = index - 1;
      } else {
        boxes[index] = Box(
          completionDate: DateTime.now(),
          tasks: tasks.length,
          lines: lines,
        );
        y = index;
      }
      _prefs.saveDays(
        index: y.toString(),
        completionDate: boxes[y].completionDate!,
        lines: lines,
        tasks: tasks.length,
      );
      setState(() {});
      return;
    } else {
      if (index > 0 && boxes[index - 1].isToday) {
        boxes[index - 1] = Box(tasks: tasks.length);
        y = index - 1;
      } else {
        boxes[index] = Box(tasks: tasks.length);
        y = index;
      }
      _prefs.removeDays(y.toString());
      setState(() {});
      return;
    }

    // if (isComplete) {
    //   print('4');
    //   if (index != 0) {
    //     if (boxes[index - 1].completionDate != null &&
    //         !boxes[index - 1].isToday) {
    //       boxes[index] = Box(
    //         completionDate: DateTime.now(),
    //         tasks: tasks.length,
    //         lines: tasks.length,
    //       );
    //     } else if (boxes[index - 1].isToday) {
    //       boxes[index - 1].lines = tasks.length;
    //       boxes[index - 1].tasks = tasks.length;
    //     } else {
    //       return;
    //     }
    //   } else {
    //     boxes[index] = Box(
    //       completionDate: DateTime.now(),
    //       tasks: tasks.length,
    //       lines: tasks.length,
    //     );
    //   }
    //   _prefs.saveDays(index.toString(), boxes[index].completionDate!);
    //   setState(() {});
    //   return;
    // }
    // // if not complete
    // // reset latest checkbox
    // else if (index != 0 && boxes[index - 1].isToday) {
    //   boxes[index - 1] = Box();
    //   _prefs.removeDays((index - 1).toString());
    // } else {
    //   boxes[index] = Box();
    //   _prefs.removeDays(index.toString());
    // }

    // setState(() {});
    // return;
  }

  void resetTaskCompletion() {
    // reset task check boxes
    if (yesterday.day != DateTime.now().day) {
      for (var task in tasks) {
        if (task.subList.isEmpty) {
          task.isChecked = false;
        } else {
          for (var key in task.subList.keys) {
            task.subList[key] = false;
          }
          task.isChecked = false;
        }
      }
      yesterday = DateTime.now();
    }
  }

  void setTasks() async {
    tasks = await customDatabase.fetchAll();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setTasks();
    addDay();
    resetTaskCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: const Text("Habit Builder"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3)),
            height:
                ((MediaQuery.of(context).size.width * 5 - 14 * 5) / 8) + 8 + 3,
            child: Center(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                children: [
                  for (var box in boxes) BoxWidget(box: box),
                ],
              ),
            ),
          ),
          SizedBox(
            child: Column(
              children: [
                Title(
                  color: Colors.white,
                  child: const Text('Tasks'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TaskDetailsDialog(
                                taskDetails: addTask,
                              );
                            });
                      },
                      icon: const Icon(FontAwesomeIcons.circlePlus),
                    ),
                    IconButton(
                      onPressed: () {
                        edit = !edit;
                        setState(() {});
                      },
                      icon: const Icon(FontAwesomeIcons.penToSquare),
                    )
                  ],
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Column(
                        children: <Widget>[
                          CustomCheckBox(
                            taskDetails: addTask,
                            edit: edit,
                            task: tasks[index],
                            verifyDayComplete: verifyDayComplete,
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
