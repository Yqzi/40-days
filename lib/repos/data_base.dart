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
      "ifSelectOne" INTEGER NOT NULL,
      "isChecked" INTEGER NOT NULL
      ); 
    """,
    );
    await database.execute(
      """
      CREATE TABLE IF NOT EXISTS $tableName2 (
      "parentName" TEXT NOT NULL, 
      "subName" TEXT UNIQUE NOT NULL,
      "isSubChecked" INTEGER NOT NULL,
      FOREIGN KEY(parentName) REFERENCES $tableName1(name),
      PRIMARY KEY (parentName, subName)
      ); 
    """,
    );
  }

  Future<int> createTask({
    required String name,
    required bool ifSelectOne,
    required bool checked,
  }) async {
    int check = checked == true ? 1 : 0;
    int one = ifSelectOne == true ? 1 : 0;
    return await (await database).rawInsert(
      "INSERT INTO $tableName1 (name, ifSelectOne, isChecked) VALUES (?,?,?)",
      [name, one, check],
    );
  }

  Future<int> createSubTask({
    required String parentName,
    required String subName,
    required bool subChecked,
  }) async {
    int check = subChecked == true ? 1 : 0;
    return await (await database).rawInsert(
      "INSERT INTO $tableName2 (parentName, subName, isSubChecked) VALUES (?, ?, ?)",
      [parentName, subName, check],
    );
  }

  Future<List<Task>> fetchAll() async {
    final tasksQuery =
        await (await database).rawQuery('''SELECT * FROM $tableName1''');
    final subQuery =
        await (await database).rawQuery('''SELECT * FROM $tableName2''');

    tasksQuery.forEach((element) {
      print(element['isChecked']);
    });

    List<Task> tasks = tasksQuery.map((e) => Task.fromJson(e)).toList();
    List<Map> sub = subQuery;

    tasks.forEach((task) {
      List<Map> q = sub.where((e) => e['parentName'] == task.name).toList();

      q.forEach((element) {
        task.addToSublist(element['subName'],
            b: element['isSubChecked'] == 1 ? true : false);
      });
    });
    return tasks;
  }

  Future<void> updateTask(String newName, bool newChecked, String newSubName,
      {required Task task}) async {
    int check = newChecked == true ? 1 : 0;
    await (await database).rawQuery(
        '''UPDATE $tableName1 SET name = $newName, isChecked = $check WHERE  ${task.name}''');
    await (await database)
        .rawQuery('''UPDATE $tableName2 SET subName = $newSubName''');
  }
}
