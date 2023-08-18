import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(home: Days()),
  );
}

class Days extends StatefulWidget {
  const Days({super.key});

  @override
  State<Days> createState() => _DaysState();
}

class _DaysState extends State<Days> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Builder"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3)),
            height:
                ((MediaQuery.of(context).size.width * 5 - 14 * 5) / 8) + 8 + 4,
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
