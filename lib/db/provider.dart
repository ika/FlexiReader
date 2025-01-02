import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --------------------------------------------
// Provider
// --------------------------------------------

class DBProvider {
  final int dbVersion = 1;
  final String dbName = "feedb.db"; // change db name to update

  factory DBProvider() => instance;

  DBProvider.internal();
  static final DBProvider instance = DBProvider.internal();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);

    bool exists = await databaseExists(path);

    // if (exists) {
    //   Directory(path).delete(recursive: true);
    //   exists = false;
    // }

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets/db", dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path);
  }

  Future close() async {
    return _database!.close();
  }
}
