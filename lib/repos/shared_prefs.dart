import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();

  void saveDays(String index, String value) async {
    var prefs = await _preferences;
    prefs.setString(index, value);
  }

  Future<String?> loadDays(String index) async {
    var prefs = await _preferences;
    return prefs.getString(index);
  }

  void removeDays(String index) async {
    var prefs = await _preferences;
    prefs.remove(index);
  }
}
