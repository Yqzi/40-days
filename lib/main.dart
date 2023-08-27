import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forty_days/models/box.dart';
import 'package:forty_days/components/custom_checkBox.dart';
import 'package:forty_days/models/task.dart';
import 'package:forty_days/repos/shared_prefs.dart';

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
        String? x = await _prefs.loadDays(i.toString());
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
      _prefs.saveDays(index.toString(), boxes[index].completionDate.toString());
      setState(() {});
      return;
    }
    // if not complete
    // reset latest checkbox
    else if (index != 0 && boxes[index - 1].isToday) {
      boxes[index - 1] = Box();
      _prefs.removeDays((index - 1).toString());
    } else {
      boxes[index] = Box();
      _prefs.removeDays(index.toString());
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
                      onPressed: () {},
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
                            edit: false,
                            tasks: tasks,
                            i: index,
                            verifyComplete: verifyComplete,
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
