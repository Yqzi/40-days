import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: days(),
    ),
  );
}

class days extends StatefulWidget {
  const days({super.key});

  @override
  State<days> createState() => _daysState();
}

class _daysState extends State<days> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Wrap(
            children: [],
          ),
          SizedBox(
            child: Column(
              children: [
                Title(
                  color: Colors.white,
                  child: Text('Tasks'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
