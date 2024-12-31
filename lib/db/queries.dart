import 'package:flexireader/db/provider.dart';
import 'package:flexireader/models/cmodel.dart';
import 'package:flexireader/models/fmodel.dart';
import 'package:sqflite/sqflite.dart';

// --------------------------------------------
// queries.dart
// --------------------------------------------

DBProvider provider = DBProvider();

// --------------------------------------------
// Queries
// --------------------------------------------

class DBQueries {
  final String feedsTable = 'feeds';
  final String cacheTable = 'cache';

  // --------------------------------------------
  // Feeds
  // --------------------------------------------
  Future<int> insertFeedItem(FModel fModel) async {
    final db = await provider.database;
    var result = await db.insert(feedsTable, fModel.toMap());
    return result;
  }

  Future<List<FModel>> getAllFeedItems() async {
    final db = await provider.database;
    var result = await db.query(feedsTable, orderBy: 'time DESC');
    List<FModel> items =
        result.isNotEmpty ? result.map((e) => FModel.fromMap(e)).toList() : [];
    return items;
  }

  Future<int?> getFeedCount() async {
    final db = await provider.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $feedsTable'));
  }

  Future<FModel?> getFeedItemById(int id) async {
    final db = await provider.database;
    List<Map> result =
        await db.query(feedsTable, where: 'id = ?', whereArgs: [id]);
    return (result.isNotEmpty) ? FModel.fromMap(result.first) : null;
  }

  Future<int> deleteFeedItem(int id) async {
    final db = await provider.database;
    return await db.delete(feedsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateFeedItem(FModel fModel) async {
    final db = await provider.database;
    return await db.update(feedsTable, fModel.toMap(),
        where: 'id = ?', whereArgs: [fModel.id]);
  }

  // --------------------------------------------
  // cache
  // --------------------------------------------
  Future<int> deleteCacheByTime(int offset) async {
    final db = await provider.database;
    return await db.delete(cacheTable, where: 'time < ?', whereArgs: [offset]);
  }

  Future<int?> countCacheByFeedId(int feedid) async {
    final db = await provider.database;
    return Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $cacheTable WHERE feedid = $feedid'));
  }

  Future<List<CModel>> getCacheByFeedId(int randomNumber) async {
    final db = await provider.database;
    var result = await db.query(feedsTable, orderBy: 'time DESC');
    List<CModel> items =
        result.isNotEmpty ? result.map((e) => CModel.fromMap(e)).toList() : [];
    return items;
  }
}
