import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool isChecked = false;

  void addTask(String name, List<String>? subList) {
    tasks.add(Task(name: name, subList: subList ?? []));
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
                  for (int i = 0; i < 40; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
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
                            setState(() {
                              tasks[i].isChecked = value!;
                            });
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
