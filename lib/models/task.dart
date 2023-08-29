class Task {
  String name;
  Map<String, bool> subList;

  set addToSublist(String s) {
    subList[s] = false;
  }

  Task({required this.name, this.subList = const {}});

  factory Task.fromJson(Map<String, dynamic> map) =>
      Task(name: map['name'], subList: map[[]]);

  bool isChecked = false;
}
