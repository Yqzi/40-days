import 'package:forty_days/models/task.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

const tableName1 = 'Tasks';
const tableName2 = 'SubTasks';

class CustomDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get _fullPath async {
    const name = 'database.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await _fullPath;
    var _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
      singleInstance: true,
    );
    return _database;
  }

  Future<void> _createTable(Database database, int version) async {
    await database.execute(
      """
      CREATE TABLE IF NOT EXISTS $tableName1 (
      "name" TEXT PRIMARY KEY,
      "isChecked" INTEGER NOT NULL,
      ); 
    """,
    );
    await database.execute(
      """
      CREATE TABLE IF NOT EXISTS $tableName2 (
      "parentName" TEXT NOT NULL 
      "subName" TEXT UNIQUE NOT NULL,
      "isSubChecked" INTEGER NOT NULL,
      "ifSelectOne" INTEGER NOT NULL,
      FOREIGN KEY(parentName) REFERENCES $tableName1(name)
      PRIMARY KEY (parentName, name)
      ); 
    """,
    );
  }

  Future<int> createTask({required String name, required bool checked}) async {
    int check = checked == true ? 1 : 0;
    return (await database).rawInsert(
      "INSERT INTO $tableName1 (name, isChecked) VALUES (?,?)",
      [name, check],
    );
  }

  Future<int> createSubTask(
      {required String parentName,
      required String subName,
      required bool subChecked,
      required bool ifSelectOne}) async {
    int check = subChecked == true ? 1 : 0;
    int one = ifSelectOne == true ? 1 : 0;
    return (await database).rawInsert(
      "INSERT INTO $tableName2 (parentName, subName, isSubChecked, ifSelectOne) VALUES (?, ?, ?, ?)",
      [parentName, subName, check, one],
    );
  }

  Future<List<Task>> fetchAll() async {
    final database = await CustomDatabase().database;
    final tasksQuery = await database.rawQuery('''SELECT * FROM $tableName1''');
    final subQuery = await database.rawQuery('''SELECT * FROM $tableName2''');

    List<Task> tasks = tasksQuery.map((e) => Task.fromJson(e)).toList();
    List<Map> sub = subQuery.map((e) => e).toList();

    tasks.forEach((task) {
      List<Map> q = sub.where((e) => e['parentName'] == task.name).toList();

      q.forEach((element) {
        task.addToSublist = element['subName'];
      });
    });
    return tasks;
  }

  Future<void> updateTask({required Task task}) async {
    await (await database).rawQuery("""
""");
  }
}
