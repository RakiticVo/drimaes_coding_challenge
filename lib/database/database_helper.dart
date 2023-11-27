import 'dart:async';
import 'package:drimaes_coding_challenge/models/user_data_model.dart';
import 'package:drimaes_coding_challenge/models/user_support_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:drimaes_coding_challenge/models/user_page_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'app_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<UserPageModel?> getUserPage(int pageNumber) async {
    try {
      if (_database == null) {
        await initDatabase();
      }

      // Implement your logic to fetch a specific page from the database
      // For example:
      final data = await _database?.query(
        'user_pages',
        where: 'page = ?',
        whereArgs: [pageNumber],
      );

      if (data != null && data.isNotEmpty) {
        return UserPageModel.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user page from database: $e");
      return null;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_pages(
        page INTEGER PRIMARY KEY,
        per_page INTEGER,
        total INTEGER,
        total_pages INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_data(
        id INTEGER PRIMARY KEY,
        email TEXT,
        first_name TEXT,
        last_name TEXT,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_support(
        url TEXT PRIMARY KEY,
        text TEXT
      )
    ''');
  }

  Future<void> saveUserPages(List<UserPageModel> userPages) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var userPage in userPages) {
        final existingUserPageRecord = await txn.rawQuery('SELECT * FROM user_pages WHERE page = ?', [userPage.page]);

        if (existingUserPageRecord.isEmpty) {
          await txn.rawInsert('''
            INSERT INTO user_pages(page, per_page, total, total_pages)
            VALUES(${userPage.page}, ${userPage.perPage}, ${userPage.total}, ${userPage.totalPages})
          ''');
        } else {
          // Update the existing record
          await txn.rawUpdate('''
            UPDATE user_pages
            SET per_page = ${userPage.perPage},
                total = ${userPage.total},
                total_pages = ${userPage.totalPages}
            WHERE page = ${userPage.page}
          ''');
        }

        for (var userData in userPage.data) {
          // Check if the record already exists
          final existingRecord = await txn.rawQuery('SELECT * FROM user_data WHERE id = ?', [userData.id]);

          if (existingRecord.isEmpty) {
            // Insert a new record if it doesn't exist
            await txn.rawInsert('''
              INSERT INTO user_data(id, email, first_name, last_name, avatar)
              VALUES(${userData.id}, "${userData.email}", "${userData.firstName}", "${userData.lastName}", "${userData.avatar}")
            ''');
          } else {
            // Update the existing record with the new values
            await txn.rawUpdate('''
              UPDATE user_data
              SET email = "${userData.email}",
                  first_name = "${userData.firstName}",
                  last_name = "${userData.lastName}",
                  avatar = "${userData.avatar}"
              WHERE id = ${userData.id}
            ''');
          }
        }

        final existingUserSupportRecord = await txn.rawQuery('SELECT * FROM user_support WHERE url = ?', [userPage.support.url]);

        if (existingUserSupportRecord.isEmpty) {
          await txn.rawInsert('''
            INSERT INTO user_support(url, text)
            VALUES("${userPage.support.url}", "${userPage.support.text}")
          ''');
        } else {
          // Update the existing record
          await txn.rawUpdate('''
            UPDATE user_support
            SET text = "${userPage.support.text}"
            WHERE url = "${userPage.support.url}"
          ''');
        }
      }
    });
  }

  Future<List<UserPageModel>> getUserPages() async {
    final db = await database;
    final result = await db.query('user_pages');

    List<UserPageModel> userPages = [];
    for (var row in result) {
      List<UserDataModel> userData = await db.query('user_data', where: 'id = ${row['page']}').then(
            (List<Map<String, dynamic>> maps) {
          return List.generate(maps.length, (i) {
            return UserDataModel(
              id: maps[i]['id'],
              email: maps[i]['email'],
              firstName: maps[i]['first_name'],
              lastName: maps[i]['last_name'],
              avatar: maps[i]['avatar'],
            );
          });
        },
      );

      UserSupportModel userSupport = await db.query('user_support', where: 'url = "${row['page']}"').then(
            (List<Map<String, dynamic>> maps) {
          return UserSupportModel(
            url: maps[0]['url'],
            text: maps[0]['text'],
          );
        },
      );

      UserPageModel userPage = UserPageModel(
        page: (row['page'] as int?) ?? 0,
        perPage: (row['per_page'] as int?) ?? 0,
        total: (row['total'] as int?) ?? 0,
        totalPages: (row['total_pages'] as int?) ?? 0,
        data: userData,
        support: userSupport,
      );

      userPages.add(userPage);
    }

    return userPages;
  }
}
