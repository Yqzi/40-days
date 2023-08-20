import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  final void Function(String, List<String>)? taskDetails;
  const CustomAlertDialog({
    super.key,
    this.taskDetails,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController subNamesController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  bool ifSubList = false;
  List<String> subNames = [];

  String title = 'Add Task';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelText: "Task Name: ",
                ),
                onSubmitted: (value) {
                  setState(() {
                    title = value;
                  });
                },
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
                controller: subNamesController,
                focusNode: myFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  labelText: "add sub task: ",
                ),
                onSubmitted: (value) => setState(
                  () {
                    subNames.add(value);
                    subNamesController.clear();
                    myFocusNode.requestFocus();
                    print(taskNameController.text);
                  },
                ),
              ),
            if (ifSubList == true)
              for (int i = 0; i < subNames.length; i++) Text(subNames[i]),
            TextButton(
              onPressed: () {
                widget.taskDetails!(title, subNames);
                Navigator.of(context).pop();
              },
              child: const Text("DONE"),
            ),
          ],
        ),
      ),
    );
  }
}
