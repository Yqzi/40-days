import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();

  void saveDays({
    required String index,
    required DateTime completionDate,
    bool isComplete = false,
    required int lines,
    required int tasks,
  }) async {
    var prefs = await _preferences;
    prefs.setString(index, completionDate.toString());
    prefs.setStringList(index, [
      completionDate.toString(),
      isComplete.toString(),
      lines.toString(),
      tasks.toString()
    ]);
  }

  Future<Map?> loadDays(String index) async {
    var prefs = await _preferences;
    Map x = {};
    var s = prefs.getStringList(index);
    if (s == null) return null;
    x['completionDate'] = DateTime.parse(s[0]);
    x['isComplete'] = bool.parse(s[1]);
    x['lines'] = int.parse(s[2]);
    x['tasks'] = int.parse(s[3]);
    return x;
  }

  void removeDays(String index) async {
    var prefs = await _preferences;
    prefs.remove(index);
  }
}
