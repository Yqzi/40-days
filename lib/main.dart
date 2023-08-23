import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/box.dart';
import 'package:forty_days/task.dart';

import 'custom_alert_dialog.dart';

void main() {
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
  List<Task> tasks = [];
  List<Box> boxes = [];

  void addTask(String name, List<String>? subList) {
    tasks.add(Task(name: name, subList: subList ?? []));
    verifyComplete();
    setState(() {});
  }

  void addDay([int? completed]) {
    for (int i = 0; i < 40; i++) {
      boxes.add(
        Box(),
      );
    }
    setState(() {});
  }

  void verifyComplete() {
    boxes[0] = Box(completionDate: DateTime.now().subtract(Duration(days: 1)));
    boxes[1] = Box(completionDate: DateTime.now().subtract(Duration(days: 1)));
    boxes[2] = Box(completionDate: DateTime.now().subtract(Duration(days: 1)));
    int index = boxes.indexWhere((e) => e.completionDate == null);
    final isComplete = tasks.every((element) => element.isChecked == true);

    if (isComplete) {
      if (index != 0) {
        if (boxes[index - 1].completionDate != null &&
            !boxes[index - 1].isToday) {
          boxes[index] = Box(completionDate: DateTime.now());
        }
        return;
      }

      // if not complete
      else {
        boxes[index] = Box(completionDate: DateTime.now());
      }
    } else if (index != 0 && boxes[index - 1].isToday) {
      boxes[index - 1] = Box();
    } else {
      boxes[index] = Box();
    }
  }

  @override
  void initState() {
    super.initState();
    addDay();
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
                  for (var box in boxes) box.createBox(),
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
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            taskDetails: addTask,
                          );
                        });
                  },
                  icon: const Icon(FontAwesomeIcons.circlePlus),
                ),
                for (var i = 0; i < tasks.length; i++)
                  tasks[i].subList.isNotEmpty
                      ? CheckboxListTile(
                          value: tasks[i].isChecked,
                          title: Text(tasks[i].name),
                          onChanged: (value) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(tasks[i].name),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (var j = 0;
                                          j < tasks[i].subList.length;
                                          j++)
                                        StatefulBuilder(
                                          builder: (BuildContext context,
                                              void Function(void Function())
                                                  setState) {
                                            return CheckboxListTile(
                                              value: tasks[i].isSubChecked[j],
                                              title: Text(tasks[i].subList[j]),
                                              onChanged: (value) {
                                                setState(
                                                  () {
                                                    tasks[i].isSubChecked[j] =
                                                        value!;
                                                    verifyComplete();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      TextButton(
                                        onPressed: () {
                                          if (tasks[i].isSubChecked.every(
                                              (element) => element == true)) {
                                            tasks[i].isChecked = true;
                                            verifyComplete();
                                          } else {
                                            tasks[i].isChecked = false;
                                          }
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("DONE"),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : CheckboxListTile(
                          value: tasks[i].isChecked,
                          onChanged: (value) {
                            tasks[i].isChecked = value!;
                            verifyComplete();
                            setState(() {});
                          },
                          title: Text(tasks[i].name),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
