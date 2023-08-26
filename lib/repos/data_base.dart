import 'package:forty_days/models/task.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<String> get fullPath async {
    const name = 'database.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var _database = await openDatabase(
      path,
      version: 1,
      onCreate: createTable,
      singleInstance: true,
    );
    return _database;
  }

  Future<void> createTable(Database database, int version) async {
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
      FOREIGN KEY(parentName) REFERENCES $tableName1(name)
      PRIMARY KEY (parentName, name)
      ); 
    """,
    );
  }

  Future<int> createTask({required String name, required bool checked}) async {
    int check = checked == true ? 1 : 0;
    final database = await CustomDatabase().database;
    return await database.rawInsert(
      "ISERT INTO $tableName1 (name, isChecked) VALUES (?,?)",
      [name, check],
    );
  }

  Future<int> createSubTask({
    required String parentName,
    required String subName,
    required bool subChecked,
  }) async {
    int check = subChecked == true ? 1 : 0;
    final database = await CustomDatabase().database;
    return await database.rawInsert(
      "INSERT INTO $tableName2 (parentName, subName, isSubChecked) VALUES (?, ? ,?)",
      [parentName, subName, check],
    );
  }

  Future<List<Task>> fetchAll() async {
    List<Task> tasks = [];
      List<Map> query;
    tasks.forEach((task) {

      List<Map> q = query.where((q) => q[parentName] == task.name).toList();
      q.forEach((element) {task.subList.add(element['subName'])});
    })
    final database = await CustomDatabase().database;
    final tasksQuery = await database.rawQuery(
        '''SELECT * FROM $tableName1 ,$tableName2  WHERE $tableName1.name == $tableName2.parentName''');
    for (var e in tasks) {}
       List<Task> tasks = tasksQuery.map((e) => Task.fromJson(e)).toList();
  }
}
