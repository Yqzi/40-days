class Task {
  String name;
  Map<String, bool> subList;
  bool ifSelectOne;

  void addToSublist(String s, {bool? b}) {
    subList[s] = b ?? false;
  }

  Task({
    required this.name,
    this.subList = const {},
    this.ifSelectOne = false,
  });

  factory Task.fromJson(Map<String, dynamic> map) => Task(name: map['name'])
    ..isChecked = map['isChecked'] == 1 ? true : false
    ..ifSelectOne = map['ifSelectOne'] == 1 ? true : false;

  bool isChecked = false;
}

extension Reset on Map<String, bool> {
  void reset() {
    forEach((key, value) {
      this[key] = false;
    });
  }
}
