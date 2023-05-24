import 'package:crudoperation/controller/data_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  final dataC = Get.put(DataController());
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'my_tables';
  static const phototable = 'photo_table';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDob = 'dob';
  static const imageLink = 'imageLink';
  static const imagePath = 'imagePath';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnDob INTEGER NOT NULL,
             $imageLink TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $phototable (
            $columnId INTEGER PRIMARY KEY,
             $imageLink TEXT NOT NULL,
             $imagePath TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  Future<int> insertPhoto(Map<String, dynamic> row) async {
    return await _db.insert(phototable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllPhotoRows({required String uniqueName}) async {
    return await _db.rawQuery("SELECT * from $phototable WHERE $imageLink='$uniqueName'");
  }

  Future<List<Map<String, dynamic>>> queryAllPhotoRos() async {
    print(await _db.query(phototable));
    return await _db.query(phototable);
  }

  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
