import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(
    const MaterialApp(home: Home()),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  void getTaskDetails(String Name, List? subnames) {}

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
                          return CustomAlertDialog();
                        });
                  },
                  icon: const Icon(FontAwesomeIcons.circlePlus),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAlertDialog extends StatefulWidget {
  final Function()? taskDetails;
  const CustomAlertDialog({
    super.key,
    this.taskDetails,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  TextEditingController taskNameController = TextEditingController();
  bool ifSubList = false;
  List<String> subNames = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      title: const Text("Add Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: taskNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              labelText: "Task Name: ",
            ),
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
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                labelText: "add sub task: ",
              ),
              onSubmitted: (value) => setState(
                () {
                  subNames.add(value);
                },
              ),
            ),
          if (ifSubList == true)
            for (int i = 0; i < subNames.length; i++) Text(subNames[i]),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("DONE"),
          ),
        ],
      ),
    );
  }
}
