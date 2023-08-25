import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/models/box.dart';
import 'package:forty_days/components/custom_checkBox.dart';
import 'package:forty_days/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/custom_alert_dialog.dart';

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
  DateTime yesterday = DateTime.now();

  void addTask(String name, List<String>? subList) {
    tasks.add(Task(name: name, subList: subList ?? []));
    verifyComplete();
    setState(() {});
  }

  void addDay([int? completed]) async {
    if (boxes.isEmpty) {
      for (int i = 0; i < 40; i++) {
        String? x = await loadDays(i.toString());
        boxes.add(
          x == null ? Box() : Box(completionDate: DateTime.parse(x)),
        );
      }
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
      } else {
        boxes[index] = Box(completionDate: DateTime.now());
      }
      saveDays(index.toString(), boxes[index].completionDate.toString());
      setState(() {});
      return;
    }
    // if not complete
    // reset latest checkbox
    else if (index != 0 && boxes[index - 1].isToday) {
      boxes[index - 1] = Box();
      removeDays((index - 1).toString());
    } else {
      boxes[index] = Box();
      removeDays(index.toString());
    }
    setState(() {});
    return;
  }

  void resetTaskCompletion() {
    // reset task check boxes
    if (yesterday.day != DateTime.now().day) {
      for (var task in tasks) {
        if (task.isSubChecked.isEmpty) {
          task.isChecked = false;
        } else {
          for (var element in task.isSubChecked) {
            element = false;
          }
          task.isChecked = false;
        }
      }
      yesterday = DateTime.now();
    }
  }

  void saveDays(String index, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(index, value);
  }

  Future<String?> loadDays(String index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(index);
  }

  void removeDays(String index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(index);
  }

  void saveTask({
    required int i,
    required String name,
    required List<String> value,
    required bool boolian,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString((i + 40).toString(), name);
    prefs.setStringList(name, value);
    prefs.setBool(value.toString(), boolian);
  }

  Future<String?> loadTaskName(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString((i + 40).toString());
  }

  /// Use loadtaskName Function to get access to name parameter.
  Future<List<String>> loadTaskSublist(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(name)!;
  }

  /// Use loadTaskSublist Function to get access to value parameter.
  Future<bool> loadtaskChecked(List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(value.toString())!;
  }

  void rebuildtasks() async {
    for (var i = 0; (await loadTaskName(i)) != null; i++) {
      String x = (await loadTaskName(i))!;
      List<String>? y = await loadTaskSublist(x);
      bool? z = await loadtaskChecked(y);
      tasks.add(Task(name: x, subList: y)..isChecked = z);
    }
  }

  @override
  void initState() {
    super.initState();
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
                  CustomCheckBox(
                    tasks: tasks,
                    i: i,
                    verifyComplete: verifyComplete,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
