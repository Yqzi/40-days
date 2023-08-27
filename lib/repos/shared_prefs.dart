import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();

  void saveDays(String index, DateTime value) async {
    var prefs = await _preferences;
    prefs.setString(index, value.toString());
  }

  Future<DateTime?> loadDays(String index) async {
    var prefs = await _preferences;
    var s = prefs.getString(index);
    if (s == null) return null;
    return DateTime.parse(s);
  }

  void removeDays(String index) async {
    var prefs = await _preferences;
    prefs.remove(index);
  }
}
