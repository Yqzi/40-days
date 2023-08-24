import 'package:flutter/material.dart';
import 'package:forty_days/models/task.dart';

class CustomCheckBox extends StatefulWidget {
  final List<Task> tasks;
  final int i;
  final void Function() verifyComplete;

  const CustomCheckBox({
    super.key,
    required this.tasks,
    required this.i,
    required this.verifyComplete,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: widget.tasks[widget.i].isChecked,
      title: Text(widget.tasks[widget.i].name),
      onChanged: (value) {
        widget.tasks[widget.i].subList.isNotEmpty
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(widget.tasks[widget.i].name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var j = 0;
                            j < widget.tasks[widget.i].subList.length;
                            j++)
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return CheckboxListTile(
                                value: widget.tasks[widget.i].isSubChecked[j],
                                title: Text(widget.tasks[widget.i].subList[j]),
                                onChanged: (value) {
                                  setState(
                                    () {
                                      widget.tasks[widget.i].isSubChecked[j] =
                                          value!;
                                      widget.verifyComplete();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        TextButton(
                          onPressed: () {
                            if (widget.tasks[widget.i].isSubChecked
                                .every((element) => element == true)) {
                              widget.tasks[widget.i].isChecked = true;
                              widget.verifyComplete();
                            } else {
                              widget.tasks[widget.i].isChecked = false;
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text("DONE"),
                        )
                      ],
                    ),
                  );
                },
              )
            : widget.tasks[widget.i].isChecked = value!;
        widget.verifyComplete();
      },
    );
  }
}
