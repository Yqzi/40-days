class Task {
  String name;
  Map<String, bool> subList;
  bool ifSelectOne;

  set addToSublist(String s) {
    subList[s] = false;
  }

  Task({
    required this.name,
    this.subList = const {},
    this.ifSelectOne = false,
  });

  factory Task.fromJson(Map<String, dynamic> map) => Task(name: map['name']);

  bool isChecked = false;
}

extension Reset on Map<String, bool> {
  void reset() {
    forEach((key, value) {
      this[key] = false;
    });
  }
}
