class Task {
  String name;
  List<String> subList;

  set addToSublist(String s) {
    subList.add(s);
  }

  Task({required this.name, this.subList = const []}) {
    for (var i = 0; i < subList.length; i++) {
      isSubChecked.add(false);
    }
  }

  factory Task.fromJson(Map<String, dynamic> map) =>
      Task(name: map['name'], subList: map[[]]);

  bool isChecked = false;

  List<bool> isSubChecked = [];
}
