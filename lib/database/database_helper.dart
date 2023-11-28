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
    return await openDatabase(path, version: 1, onCreate: _createDatabase, readOnly: false);
  }

  Future<UserPageModel?> getUserPage(int pageNumber) async {
    try {
      if (_database == null) {
        await initDatabase();
      }

      final userPageData = await _database?.query(
        'user_pages',
        where: 'page = ?',
        whereArgs: [pageNumber],
      );

      if (userPageData != null && userPageData.isNotEmpty) {
        final userPage = userPageData.first;
        List<UserDataModel> userData = [];
        for(int i = 0; i < 6; i++){
          List<Map<String, Object?>>? data = await _database?.query(
            'user_data',
            where: 'id = ?',
            whereArgs: [(pageNumber - 1) * 6 + i],
          );
          if(data != null){
            userData.add(UserDataModel.fromJson(data.first));
          }
        }

        UserPageModel userPageModel = UserPageModel(
          page: userPage['page'] as int,
          perPage: userPage['per_page'] as int,
          total: userPage['total'] as int,
          totalPages: userPage['total_pages'] as int,
          data: userData,
          support: UserSupportModel(
            url: "https://reqres.in/#support-heading",
            text: "To keep ReqRes free, contributions towards server costs are appreciated!",
          )
        );
        return userPageModel;
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

  Future<List<UserPageModel>?> getUserPages() async {
    final db = await database;

    final result = await db.query('user_pages');

    List<UserPageModel> userPages = [];
    // for(Map<String, Object?> userModel in result){
    //   log('user page: $userModel');
    // }
    for (int i = 0; i < result.length; i++) {
      List<UserDataModel> userData = [];
      for(int j = 1; j <= 6; j++){
        List<Map<String, Object?>>? data = await db.query(
          'user_data',
          where: 'id = ?',
          whereArgs: [(i) * 6 + j],
        );
        userData.add(UserDataModel.fromJson(data.first));
      }

      UserPageModel userPage = UserPageModel(
        page: (result[i]['page'] as int?) ?? 0,
        perPage: (result[i]['page'] as int?) ?? 0,
        total: (result[i]['page'] as int?) ?? 0,
        totalPages: (result[i]['page'] as int?) ?? 0,
        data: userData,
        support: UserSupportModel(
          url: "https://reqres.in/#support-heading",
          text: "To keep ReqRes free, contributions towards server costs are appreciated!",
        )
      );

      userPages.add(userPage);
    }
    return userPages;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
