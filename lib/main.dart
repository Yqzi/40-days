import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:forty_days/components/custom_checkBox.dart';
import 'package:forty_days/repos/shared_prefs.dart';
import 'package:forty_days/repos/notications.dart';
import 'package:forty_days/repos/data_base.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/models/box.dart';
import 'package:flutter/material.dart';

import 'components/box_widget.dart';
import 'components/missed_dialog.dart';
import 'components/task_details_dialog.dart';

final theme = FlexThemeData.dark(
  scheme: FlexScheme.cyanM3,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  tz.initializeTimeZones();
  await NotifService().initNotif();

  runApp(
    MaterialApp(
      home: const Home(),
      darkTheme: theme,
      themeMode: ThemeMode.dark,
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final CustomDatabase customDatabase = CustomDatabase();
  final Preferences prefs = Preferences();
  late bool firstTimeUser;
  late int yesterday;
  List<Task> tasks = [];
  List<Box> boxes = [];
  bool edit = false;
  bool dayMissed = false;
  bool allowCreation = false;
  bool hasAlertComplete = false;
  DateTime now = DateTime.now();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('AppLifeCycleState: $state');

    // on resumed
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await addDay();
          if (boxes.lastOrNull?.isComplete == true) {
            checkAllComplete();
            return;
          }

          if (!dayMissed || boxes.lastOrNull?.isComplete == true) {
            return;
          }
          // ignore: use_build_context_synchronously
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => MissedDialog(
              boxes: boxes,
              prefs: prefs,
              tasks: tasks,
              setState: () {
                setState(() {});
              },
              completeMissedDays: () {
                int index =
                    boxes.indexWhere((e) => e.completionDate == null) - 1;
                int remainingDays = index +
                    DateTime.now()
                        .difference(boxes[index].completionDate!)
                        .inDays;

                for (int i = index; i < remainingDays; i++) {
                  boxes[i] = Box(
                    tasks: tasks.length,
                    completionDate:
                        DateTime.now().subtract(const Duration(days: 1)),
                    isComplete: true,
                    lines: tasks.length,
                  );
                  prefs.saveDays(
                    index: i.toString(),
                    completionDate: boxes[i].completionDate!,
                    isComplete: true,
                    lines: tasks.length,
                    tasks: tasks.length,
                  );
                  quickTaskReset();
                }
                setState(() {});
              },
            ),
          );
        },
      );
    }

    if (state == AppLifecycleState.paused) {
      if (boxes.isEmpty) {
        return;
      }
      late Box b;
      try {
        b = boxes.lastWhere((element) => element.isComplete == true);
      } catch (e) {
        b = boxes[0];
      }
      if (b.isToday) {
        await NotifService().cancelNotification(0);
        await NotifService().dailyNotif(
          title: 'Reminder',
          body:
              'D\'ont forget to complete your daylies if you haven\'t already!!!',
          time: DateTime(now.year, now.month, now.day, 19).add(
            const Duration(days: 1),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setTasks();
    verifyFirst();
    // schedule notif
    NotifService().dailyNotif(
      title: 'Reminder',
      body: 'D\'ont forget to complete your daylies if you haven\'t already!!!',
      time: DateTime(now.year, now.month, now.day, 19),
    );
    // checkAllComplete();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await addDay();
        // schedule next notif
        late Box b;
        try {
          b = boxes.lastWhere((element) => element.isComplete == true);
        } catch (e) {
          b = boxes[0];
        }
        if (b.isToday) {
          await NotifService().cancelNotification(0);
          await NotifService().dailyNotif(
            title: 'Reminder',
            body:
                'D\'ont forget to complete your daylies if you haven\'t already!!!',
            time: DateTime(now.year, now.month, now.day, 19)
                .add(const Duration(days: 1)),
          );
        }
        if (boxes.lastOrNull?.isComplete == true) {
          checkAllComplete();
          return;
        }

        if (!dayMissed || boxes.lastOrNull?.isComplete == true) {
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
            completeMissedDays: () {
              int index = boxes.indexWhere((e) => e.completionDate == null) - 1;
              int remainingDays = index +
                  DateTime.now()
                      .difference(boxes[index].completionDate!)
                      .inDays;

              for (int i = index; i < remainingDays; i++) {
                boxes[i] = Box(
                  tasks: tasks.length,
                  completionDate:
                      DateTime.now().subtract(const Duration(days: 1)),
                  isComplete: true,
                  lines: tasks.length,
                );
                prefs.saveDays(
                  index: i.toString(),
                  completionDate: boxes[i].completionDate!,
                  isComplete: true,
                  lines: tasks.length,
                  tasks: tasks.length,
                );
                quickTaskReset();
              }
              setState(() {});
            },
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
        if (i == 39) {
          boxes.add(Box(tasks: tasks.length));
          prefs.removeDay(i);
          return;
        }
        boxes.add(
          Box(
            tasks: tasks.length,
            completionDate: DateTime.now().subtract(const Duration(days: 1)),
            isComplete: true,
            lines: tasks.length,
          ),
        );
        prefs.saveDays(
          index: i.toString(),
          completionDate: boxes[i].completionDate!,
          isComplete: true,
          lines: 0,
          tasks: tasks.length,
        );
        // Map? x = await prefs.loadDays(i.toString());
        // boxes.add(
        //   x == null
        //       ? Box(tasks: tasks.length)
        //       : Box(
        //           completionDate: x['completionDate'],
        //           isComplete: x['isComplete'],
        //           lines: x['lines'],
        //           tasks: x['tasks'],
        //         ),
        // );
      }
    }
    dayMissed = await checkDate();
  }

  Future<bool> checkDate() async {
    int index = boxes.indexWhere((e) => e.completionDate == null);
    if (index > 0) {
      // if date changed manually to past protect progress.
      if (boxes[index - 1].completionDate!.difference(DateTime.now()).inDays <
          0) {
        return false;
      }
      if (boxes[index - 1].completionDate!.day !=
              DateTime.now().subtract(const Duration(days: 1)).day &&
          !boxes[index - 1].isToday) {
        return true;
      }
    }
    return false;
  }

  // Function should also be called every day
  Future<dynamic> checkAllComplete() async {
    if (boxes.last.isComplete) {
      // Day after completion
      if (!boxes.last.isToday) {
        // reset all tasks checkboxes
        quickTaskReset();

        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            contentPadding: const EdgeInsets.only(right: 24, left: 24, top: 10),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: const Text(
              'Reset',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'We have now reset the 40 days. You may now edit or add tasks to your daylies',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text('Dismiss'),
                ),
              )
            ],
          ),
        ).then((_) async {
          // reset all days checkboxes
          for (int i = 39; i >= 0; i--) {
            boxes[i].isComplete = false;
            boxes[i].completionDate = null;
            prefs.removeDay(i);
          }
          setState(() {});
        });
      }
      // Checking if AlertDialog already shown
      if (hasAlertComplete) {
        return;
      }
      // day of completion
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          contentPadding: const EdgeInsets.only(right: 24, left: 24, top: 10),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: const Text(
            'Congratulations',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'You have successfully completed your 40 days. Tomorrow you will have a fresh start to add or edit your daylies to your desire.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Dismiss'),
              ),
            )
          ],
        ),
      ).then((_) => hasAlertComplete = true);
    }
  }

  Future<void> verifyDayComplete() async {
    int index = boxes.indexWhere((e) => e.completionDate == null);
    int lines = tasks.where((e) => e.isChecked == true).length;
    int y = 0;

    print(index);
    if (lines == tasks.length && lines > 0) {
      int x = index > 0
          ? !boxes[index - 1].isToday
              ? index
              : index - 1
          : index;
      if (index == -1) {
        x = boxes.length - 1;
      }
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
      if (boxes[x].isComplete) {
        await NotifService().cancelNotification(0);
        await NotifService().dailyNotif(
          title: 'Reminder',
          body:
              'D\'ont forget to complete your daylies if you haven\'t already!!!',
          time: DateTime(now.year, now.month, now.day, 19).add(
            const Duration(days: 1),
          ),
        );
      }

      checkAllComplete();
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
      checkAllComplete();
      setState(() {});
      return;
    } else {
      if (index > 0 && boxes[index - 1].isToday) {
        boxes[index - 1] = Box(tasks: tasks.length);
        y = index - 1;
      } else if (index == -1) {
        boxes.last = Box(tasks: tasks.length);
        y = 39;
      } else {
        boxes[index] = Box(tasks: tasks.length);
        y = index;
      }
      if (DateTime.now().hour < 19) {
        await NotifService().dailyNotif(
          title: 'Reminder',
          body:
              'D\'ont forget to complete your daylies if you haven\'t already!!!',
          time: DateTime(now.year, now.month, now.day, 19),
        );
      }
      prefs.removeDays(y.toString());
      checkAllComplete();
      setState(() {});
      return;
    }
  }

  void quickTaskReset() {
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
  }

  void resetTaskCompletion() {
    // reset task check boxes
    if (yesterday != DateTime.now().day) {
      quickTaskReset();
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
                icon: const Icon(FontAwesomeIcons.plus),
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
                  for (int i = 0; i < boxes.length; i++)
                    BoxWidget(box: boxes[i], index: i),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Title(
                  color: Theme.of(context).colorScheme.onBackground,
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
                                  isLastDayComplete: boxes.last.isComplete,
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
                          color: (edit)
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).colorScheme.secondary,
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
                                      icon: Icon(
                                        FontAwesomeIcons.circleMinus,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                        size: 20,
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return TaskDetailsDialog(
                                                isLastDayComplete:
                                                    boxes.last.isComplete,
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
                                            padding: const EdgeInsets.all(15.0),
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
                                  ],
                                ).animate().slideX(
                                    begin: -0.1,
                                    end: -0.05,
                                    delay: const Duration(milliseconds: 100),
                                  )
                              : Card(
                                  child: CustomCheckBox(
                                    taskDetails: addTask,
                                    edit: edit,
                                    task: tasks[index],
                                    allTasks: tasks,
                                    verifyDayComplete: verifyDayComplete,
                                  ),
                                ).animate().slideX(
                                    begin: 0.05,
                                    delay: const Duration(milliseconds: 200),
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
