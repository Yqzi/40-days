import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/components/custom_checkBox.dart';
import 'package:forty_days/repos/shared_prefs.dart';
import 'package:forty_days/repos/data_base.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/models/box.dart';
import 'package:flutter/material.dart';

import 'components/box_widget.dart';
import 'components/missed_dialog.dart';
import 'components/task_details_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: const Home(),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CustomDatabase customDatabase = CustomDatabase();
  final Preferences prefs = Preferences();
  late int yesterday;
  List<Task> tasks = [];
  List<Box> boxes = [];
  bool edit = false;
  bool dayMissed = false;
  bool allowCreation = false;
  late bool firstTimeUser;

  void addTask(
      String name, Map<String, bool>? subList, bool ifSelectOne, int? index) {
    if (index == null) {
      tasks.add(
        Task(name: name, subList: subList ?? {}, ifSelectOne: ifSelectOne),
      );

      customDatabase.createTask(
        name: name,
        checked: false,
        ifSelectOne: ifSelectOne,
        index: tasks.length - 1,
      );
    }
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

  Future<void> addDay([int? completed]) async {
    if (boxes.isEmpty) {
      for (int i = 0; i < 40; i++) {
        Map? x = await prefs.loadDays(i.toString());
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
    dayMissed = await checkDate();
  }

  Future<bool> checkDate() async {
    int index = boxes.indexWhere((e) => e.completionDate == null);
    if (index > 0) {
      if (boxes[index - 1].completionDate!.day !=
              DateTime.now().subtract(const Duration(days: 1)).day &&
          !boxes[index - 1].isToday) {
        return true;
      }
    }
    return false;
  }

  void verifyDayComplete() {
    int index = boxes.indexWhere((e) => e.completionDate == null);
    int lines = tasks.where((e) => e.isChecked == true).length;
    var y = 0;

    if (lines == tasks.length && lines > 0) {
      var x = index > 0
          ? !boxes[index - 1].isToday
              ? index
              : index - 1
          : index;
      boxes[x] = Box(
        completionDate: DateTime.now(),
        isComplete: true,
        tasks: tasks.length,
        lines: lines,
      );
      prefs.saveDays(
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
      prefs.saveDays(
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
      prefs.removeDays(y.toString());
      setState(() {});
      return;
    }
  }

  void resetTaskCompletion() {
    // reset task check boxes
    if (yesterday != DateTime.now().day) {
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
      yesterday = DateTime.now().day;
      prefs.saveYesterday(yesterday);
    }
  }

  void setTasks() async {
    tasks = await customDatabase.fetchAll();
    setYesterday();
    setState(() {});
  }

  void verifyFirst() async {
    firstTimeUser = await prefs.loadFirst() ?? true;
    setState(() {});
  }

  void setYesterday() async {
    yesterday = await prefs.loadYesterday() ?? DateTime.now().day;
    prefs.saveYesterday(yesterday);
    resetTaskCompletion();
  }

  @override
  void initState() {
    super.initState();
    setTasks();
    verifyFirst();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await addDay();
        if (!dayMissed) {
          return;
        }
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) => MissedDialog(
            boxes: boxes,
            prefs: prefs,
            tasks: tasks,
            setState: () {
              setState(() {});
            },
          ),
        );
      },
    );
    setState(() {});
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Habit Builder"),
            if (boxes.firstOrNull?.isComplete == true &&
                boxes.firstOrNull?.isToday == false)
              IconButton(
                onPressed: () {
                  if (firstTimeUser) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.only(right: 24, left: 24, top: 10),
                        title: const Text(
                          'Notice',
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          'This feature is not meant for repetitive use',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  firstTimeUser = false;
                                  prefs.saveFirstTimeUser();
                                  Navigator.pop(context);
                                },
                                child: const Text('Dismiss')),
                          )
                        ],
                      ),
                    );
                  }
                  allowCreation = !allowCreation;
                  setState(() {});
                },
                icon: const Icon(FontAwesomeIcons.chessRook),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent, width: 5)),
            height:
                ((MediaQuery.of(context).size.width * 5 - 14 * 5) / 8) + 8 + 10,
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
          Expanded(
            child: Column(
              children: [
                Title(
                  color: Colors.white,
                  child: const Text('Tasks'),
                ),
                if (boxes.firstOrNull?.isComplete == false ||
                    boxes.firstOrNull?.isToday == true ||
                    allowCreation)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TaskDetailsDialog(
                                  allTasks: tasks,
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
                        icon: Icon(
                          FontAwesomeIcons.penToSquare,
                          color:
                              (edit) ? const Color(0xFFFFE082) : Colors.white,
                        ),
                      )
                    ],
                  ),
                Expanded(
                  child: ReorderableListView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        int idx = 0;
                        final Task item = tasks.removeAt(oldIndex);
                        tasks.insert(newIndex, item);
                        for (Task task in tasks) {
                          customDatabase.updateIndex(
                              index: idx, prevName: task.name);
                          idx++;
                        }
                      });
                    },
                    children: [
                      for (int index = 0; index < tasks.length; index++)
                        ListTile(
                          key: Key(index.toString()),
                          title: edit == true
                              ? Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return verificationDialog(
                                              index,
                                              context,
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.circleMinus,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: MaterialButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return TaskDetailsDialog(
                                                  task: tasks[index],
                                                  taskDetails: addTask,
                                                  verifyDayComplete:
                                                      verifyDayComplete,
                                                  allTasks: tasks,
                                                  index: index,
                                                );
                                              },
                                            );
                                          },
                                          child: Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: CustomCheckBox(
                                                taskDetails: addTask,
                                                edit: edit,
                                                task: tasks[index],
                                                allTasks: tasks,
                                                verifyDayComplete:
                                                    verifyDayComplete,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Card(
                                  child: CustomCheckBox(
                                    taskDetails: addTask,
                                    edit: edit,
                                    task: tasks[index],
                                    allTasks: tasks,
                                    verifyDayComplete: verifyDayComplete,
                                  ),
                                ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog verificationDialog(int index, BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      titlePadding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
      title: const Text(
        'Confirmation',
        style: TextStyle(
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Are you sure you want want to delete ${tasks[index].name}?",
            textAlign: TextAlign.center,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Divider(),
          ),
          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const VerticalDivider(),
                  TextButton(
                    onPressed: () {
                      customDatabase.removeTask(taskName: tasks[index].name);
                      tasks.removeAt(index);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
