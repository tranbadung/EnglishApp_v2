import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:speak_up/data/local/database_services/database_key.dart';
import 'package:speak_up/presentation/pages/admin/database/model/phonetic_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../domain/entities/category/category.dart';
import '../../../../domain/entities/expression/expression.dart';
import '../../../../domain/entities/lesson/lesson.dart';
import '../../../../domain/entities/word/word.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('speak_up.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print("Database path: $path");

    if (!await databaseExists(path)) {
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data =
        await rootBundle.load(join('assets', 'database', 'speak_up.db'));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied successfully");
      } catch (e) {
        print("Error copying database: $e");
      }
    }
    return await openDatabase(path, readOnly: false);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Expression (
        ExpressionID INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Translation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Lesson (
        LessonID INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Translation TEXT,
        Description TEXT,
        DescriptionTranslation TEXT,
        ImageURL TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Category (
        CategoryID INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Translation TEXT,
        ImageURL TEXT
      )
    ''');
  }

  Future<Word?> createWord(Word word) async {
    final db = await instance.database;

    try {
      final id = await db.insert('Word', word.toMap());
      if (id > 0) {
        word.wordID = id;
        print("Created word with ID: $id");
        return word;
      } else {
        print("Failed to create word. No ID returned.");
        return null;
      }
    } catch (e) {
      print("Error creating word: $e");
      return null;
    }
  }

  Future<Word?> getWordById(int id) async {
    try {
      final db = await instance.database;
      final results = await db.query(
        'Word',
        where: 'WordID = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        Map<String, int> phoneticComponents = {};
        try {
          String phoneticStr =
              results.first['PhoneticComponents'] as String? ?? '{}';
          if (phoneticStr.startsWith('{') && phoneticStr.endsWith('}')) {
            phoneticStr = phoneticStr.substring(1, phoneticStr.length - 1);
            List<String> pairs = phoneticStr.split(',');
            for (String pair in pairs) {
              if (pair.trim().isNotEmpty) {
                List<String> keyValue = pair.split(':');
                if (keyValue.length == 2) {
                  String key = keyValue[0].trim().replaceAll('"', '');
                  int value = int.tryParse(keyValue[1].trim()) ?? 0;
                  phoneticComponents[key] = value;
                }
              }
            }
          }
        } catch (e) {
          print("Error parsing phoneticComponents: $e");
          phoneticComponents = {'default': 1};
        }
        return Word(
          wordID: int.parse(results.first['WordID'].toString()),
          word: results.first['Word'].toString(),
          pronunciation: results.first['Pronunciation'].toString(),
          phoneticComponents: phoneticComponents,
          phoneticID: int.parse(results.first['PhoneticID'].toString()),
          translation: results.first['Translation'] as String? ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error getting word by ID: $e');
      return null;
    }
  }

  Future<List<Word>> getAllWords() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('Word');
      print("Fetched ${maps.length} words from database");

      return List.generate(maps.length, (i) {
        Map<String, int> phoneticComponents = {};
        try {
          String phoneticStr = maps[i]['PhoneticComponents'] as String? ?? '{}';
          if (phoneticStr.startsWith('{') && phoneticStr.endsWith('}')) {
            phoneticStr = phoneticStr.substring(1, phoneticStr.length - 1);
            List<String> pairs = phoneticStr.split(',');
            for (String pair in pairs) {
              if (pair.trim().isNotEmpty) {
                List<String> keyValue = pair.split(':');
                if (keyValue.length == 2) {
                  String key = keyValue[0].trim().replaceAll('"', '');
                  int value = int.tryParse(keyValue[1].trim()) ?? 0;
                  phoneticComponents[key] = value;
                }
              }
            }
          }
        } catch (e) {
          print("Error parsing phoneticComponents: $e");
          phoneticComponents = {'default': 1};
        }

        return Word(
          wordID: maps[i]['WordID'],
          word: maps[i]['Word'] ?? '',
          pronunciation: maps[i]['Pronunciation'] ?? '',
          phoneticComponents: phoneticComponents,
          phoneticID: maps[i]['PhoneticID'] ?? 0,
          translation: maps[i]['Translation'] ?? '',
        );
      });
    } catch (e) {
      print("Error getting words: $e");
      return [];
    }
  }

  Future<bool> updateWord(Word word) async {
    try {
      if (word.wordID == null || word.wordID == 0) {
        print("Invalid WordID: ${word.wordID}");
        return false;
      }

      final db = await instance.database;

      // Kiểm tra nếu từ tồn tại
      final existingWord = await getWordById(word.wordID!);
      if (existingWord == null) {
        print("Word with ID ${word.wordID} does not exist.");
        return false;
      }

      String phoneticComponentsStr = word.phoneticComponents.toString();

      final result = await db.update(
        'Word',
        {
          'Word': word.word,
          'Pronunciation': word.pronunciation,
          'PhoneticComponents': phoneticComponentsStr,
          'PhoneticID': word.phoneticID,
          'Translation': word.translation,
        },
        where: 'WordID = ?',
        whereArgs: [word.wordID],
      );

      if (result > 0) {
        print("Word with ID ${word.wordID} updated successfully.");
      } else {
        print(
            "No rows affected. Check if WordID ${word.wordID} exists in the database.");
      }

      return result > 0;
    } catch (e) {
      print("Error updating word: $e");
      return false;
    }
  }

  Future<bool> deleteWord(Word word) async {
    print("Attempting to delete word: ${word.toString()}");

    if (word.wordID == null || word.wordID == 0) {
      print("Error: Cannot delete word. WordID is null or 0.");
      return false;
    }

    final db = await instance.database;

    try {
      final result = await db.delete(
        'Word',
        where: 'WordID = ?',
        whereArgs: [word.wordID],
      );

      if (result > 0) {
        print("Word with ID ${word.wordID} deleted successfully.");
        return true;
      } else {
        print(
            "No rows affected. Word with ID ${word.wordID} not found in the database.");
        return false;
      }
    } catch (e) {
      print("Error deleting word: $e");
      return false;
    }
  }

  // Phonetic operations
  Future<List<Phonetic>> getAllPhonetics() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('Phonetic');
      print("Fetched ${maps.length} phonetics from database");

      return List.generate(maps.length, (i) {
        return Phonetic.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error getting phonetics: $e");
      return [];
    }
  }

  Future<int> createPhonetic(Phonetic phonetic) async {
    try {
      final db = await instance.database;
      final result = await db.insert('Phonetic', phonetic.toMap());
      print('Created new phonetic with ID: $result');
      phonetic.phoneticID = result;
      return result;
    } catch (e) {
      print('Error creating phonetic: $e');
      return -1;
    }
  }

  Future<bool> deletePhonetic(int id) async {
    try {
      final db = await instance.database;
      final result = await db.delete(
        'Phonetic',
        where: 'PhoneticID = ?',
        whereArgs: [id],
      );
      print('Deleted phonetic with ID $id: ${result > 0}');
      return result > 0;
    } catch (e) {
      print('Error deleting phonetic: $e');
      return false;
    }
  }

  Future<bool> updatePhonetic(Phonetic phonetic) async {
    if (phonetic.phoneticID == null) {
      print("Error: phoneticID is null");
      return false;
    }

    try {
      final db = await instance.database;
      final result = await db.update(
        'Phonetic',
        phonetic.toMap(),
        where: 'PhoneticID = ?',
        whereArgs: [phonetic.phoneticID],
      );
      print("Update result: $result rows affected");
      return result > 0;
    } catch (e) {
      print("Error updating phonetic: $e");
      return false;
    }
  }

  Future<bool> phoneticExists(int id) async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Phonetic',
        where: 'PhoneticID = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print("Error checking phonetic existence: $e");
      return false;
    }
  }

  // Lesson operations
  Future<List<Lesson>> getLessonList() async {
    try {
      final db = await database;
      final maps = await db.query('lesson');
      return List.generate(maps.length, (i) {
        return Lesson(
          isLearned: false,
          lessonID: maps[i][LessonTable.LessonID.name] as int,
          name: maps[i][LessonTable.Name.name] as String,
          translation: maps[i][LessonTable.Translation.name] as String,
          description: maps[i][LessonTable.Description.name] as String,
          descriptionTranslation:
          maps[i][LessonTable.DescriptionTranslation.name] as String,
          imageURL: maps[i][LessonTable.ImageURL.name] as String,
        );
      });
    } catch (e) {
      print("Error getting lessons: $e");
      return [];
    }
  }

  // Expression operations
  Future<int> createExpression(Expression expression) async {
    try {
      final db = await instance.database;
      return await db.insert('Expression', expression.toMap());
    } catch (e) {
      print("Error creating expression: $e");
      return -1;
    }
  }

  Future<bool> updateExpression(Expression expression) async {
    try {
      final db = await instance.database;
      final result = await db.update(
        'Expression',
        expression.toMap(),
        where: 'ExpressionID = ?',
        whereArgs: [expression.expressionID],
      );
      return result > 0;
    } catch (e) {
      print("Error updating expression: $e");
      return false;
    }
  }

  Future<bool> deleteExpression(int id) async {
    try {
      final db = await instance.database;
      final result = await db.delete(
        'Expression',
        where: 'ExpressionID = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      print("Error deleting expression: $e");
      return false;
    }
  }

  Future<List<Expression>> getAllExpressions() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('Expression');
      return List.generate(maps.length, (i) {
        return Expression.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error getting expressions: $e");
      return [];
    }
  }

  // Category operations
  Future<int> createCategory(Category category) async {
    try {
      final db = await instance.database;
      return await db.insert('Category', category.toMap());
    } catch (e) {
      print("Error creating category: $e");
      return -1;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final db = await instance.database;
      final result = await db.update(
        'Category',
        category.toMap(),
        where: 'CategoryID = ?',
        whereArgs: [category.categoryID],
      );
      return result > 0;
    } catch (e) {
      print("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final db = await instance.database;
      final result = await db.delete(
        'Category',
        where: 'CategoryID = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('Category');
      return List.generate(maps.length, (i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error getting categories: $e");
      return [];
    }
  }
}
