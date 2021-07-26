import 'dart:async';
import 'dart:io' as io;
import 'package:crime_alert/model/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'common.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  static Database? _db;

  Future<Database?> get db async {
    if(_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }


  Future<Database> initDb() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, 'main.db');
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }


  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE $User ('
            '$ID INTEGER PRIMARY KEY,'
            '$UID TEXT,'
            '$NAME TEXT,'
            '$EMAIL TEXT,'
            ')');
    print('Created Users table');

  }

  Future<User> getUser() async {
    var user = User();
    try {
      var dbClient = await db;
      var result = await dbClient!.query('$User');
      print('get user from db '+result[0].toString());
      user =  User.fromJson(result[0]);
    } catch(e){
      print(e);
    }
    print('gets here magically'+user.toJson().toString());
      return user;
  }

  Future<int> saveUser(User user) async {
    try{
      var res = -1;
      var dbClient = await db;
      await deleteUser().then((val) async {
        res = await dbClient!.insert('User', user.toJson(),);
        user.copyWith(email: user.email);
        print('save user into db '+res.toString());
      });
      return res;
    }catch(e) {
      print(e);
      return -1;
    }
  }

  Future<int> deleteUser() async {
    try{
      var dbClient = await db;
      var res = await dbClient!.delete('User');
      return res;
    }catch(e){
      print(e);
      return -1;
    }
  }

  Future<bool> isLoggedIn() async {
    try{
      var dbClient = await db;
      var res = await dbClient!.query('User');
      print('is logged in from local db '+res.toString());
      return res.isNotEmpty;
    }catch(e){
      print(e);
      return false;
    }
  }

}