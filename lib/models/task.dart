class Task {
  final String name;
  final List<String> subList;

  Task({required this.name, this.subList = const []}) {
    for (var i = 0; i < subList.length; i++) {
      isSubChecked.add(false);
    }
  }

  factory Task.fromSqfliteDatabase(Map<String, dynamic> map) =>
      Task(name: map['name'], subList: map[[]]);

  bool isChecked = false;

  List<bool> isSubChecked = [];
}
