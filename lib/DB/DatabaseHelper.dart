// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';

// class DatabaseHelper {
//   static const databaseName = "MyDatabase.db";
//   static const databaseVersion = 1;

//   static const table = 'my_table';

//   static const columnId = 'id';
//   static const columnUserId = 'user_id';
//   static const columnName = 'name';
//   static const columnPic = 'picture';
//   static const columnEmbedding = 'embedding';
//   static const columnPresenceDate = 'presence_date';
//   static const columnCreatedAt = 'created_at';
//   static const columnIsLoggedIn = 'is_auth';

//   late Database db;

//   Future<void> init() async {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = join(documentsDirectory.path, databaseName);
//     db = await openDatabase(
//       path,
//       version: databaseVersion,
//       onCreate: onCreate,
//     );
//   }

//   Future onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $table (
//         $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//         $columnUserId TEXT NOT NULL,
//         $columnName TEXT NOT NULL,
//         $columnPic TEXT NOT NULL,
//         $columnEmbedding TEXT NOT NULL,
//         $columnPresenceDate TEXT NOT NULL,
//         $columnCreatedAt TEXT NOT NULL,
//         $columnIsLoggedIn TTEXT NOT NULL
//       )
//     ''');
//   }

//   Future<int> insert(Map<String, dynamic> row) async {
//     return await db.insert(table, row);
//   }

//   Future<List<Map<String, dynamic>>> queryAllRows() async {
//     return await db.query(table);
//   }

//   Future<int> queryRowCount() async {
//     final results = await db.rawQuery('SELECT COUNT(*) FROM $table');
//     return Sqflite.firstIntValue(results) ?? 0;
//   }

//   Future<int> update(Map<String, dynamic> row) async {
//     int id = row[columnId];

//     return await db.update(
//       table,
//       row,
//       where: '$columnId = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> delete(int id) async {
//     return await db.delete(
//       table,
//       where: '$columnId = ?',
//       whereArgs: [id],
//     );
//   }
// }
