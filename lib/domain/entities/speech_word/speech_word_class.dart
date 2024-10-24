import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class WordDatabase {
  static final WordDatabase instance = WordDatabase._init();

  static Database? _database;

  WordDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('speak_up.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    // Kiểm tra nếu cơ sở dữ liệu đã tồn tại
    final exists = await databaseExists(path);

    if (!exists) {
        try {
        await Directory(dirname(path)).create(recursive: true);

         final data = await rootBundle.load('assets/database/$fileName');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
       }
    } else {
     }

     return await openDatabase(path);
  }

  Future<List<Map<String, dynamic>>> searchWords(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'word_table',  
      where: 'Word LIKE ?',  
      whereArgs: ['%$query%'],   
    );
    return result;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
