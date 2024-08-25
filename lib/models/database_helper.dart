import 'package:sqflite/sqflite.dart';
import 'package:manga_logger/models/manga_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:manga_logger/models/user.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;
  String? _dbPath; // Store the custom path

  Future<Database> getDatabase({String? path}) async {
    if (_database != null && _database!.isOpen) return _database!;

    _dbPath = path;
    _database = await _initDatabase(path: path);
    return _database!;
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null; // Reset to null after closing
    }
  }

  Future<Database> _initDatabase({String? path}) async {
    final dbPath = path ?? join(await getDatabasesPath(), 'manga_database.db');
    return await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        // Create users table
        await db.execute(
          "CREATE TABLE users(userId INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT)",
        );

        // Create favorite_manga table
        await db.execute(
          "CREATE TABLE favorite_manga(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, favoriteManga TEXT, "
          "FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE)",
        );
      },
      version: 1,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<void> insertUser(String username) async {
    final db = await getDatabase(path: _dbPath);
    await db.insert(
      'users',
      {'username': username},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await getDatabase(path: _dbPath);
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User> getUserByUsername(String username) async {
    final db = await getDatabase(path: _dbPath);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return User.fromMap(maps.first);
  }

  Future<User> getUserByUserId(int userId) async {
    final db = await getDatabase(path: _dbPath);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return User.fromMap(maps.first);
  }

  Future<void> deleteAllUsers() async {
    final db = await getDatabase(path: _dbPath);
    await db.delete('users');
  }

  Future<void> deleteUser(int userId) async {
    final db = await getDatabase(path: _dbPath);
    await db.delete(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertManga(int userId, MangaModel manga) async {
    final db = await getDatabase(path: _dbPath);
    String mangaJson = jsonEncode(manga.toMap());
    await db.insert(
      'favorite_manga',
      {
        'userId': userId,
        'favoriteManga': mangaJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MangaModel>> getAllFavoriteManga(int userId) async {
    final db = await getDatabase(path: _dbPath);

    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_manga',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        final mangaJson = maps[i]['favoriteManga'];
        final mangaMap = jsonDecode(mangaJson);
        return MangaModel.fromJson(mangaMap);
      });
    }

    return [];
  }

  Future<MangaModel> getFavoriteManga(int userId, String mangaId) async {
    final db = await getDatabase(path: _dbPath);
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_manga',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      for (final map in maps) {
        final mangaJson = map['favoriteManga'];
        final mangaMap = jsonDecode(mangaJson);

        if (mangaMap['id'] == mangaId) {
          return MangaModel.fromJson(mangaMap);
        }
      }
    }

    throw Exception('Manga not found');
  }

  Future<void> deleteFavoriteManga(int userId, String mangaId) async {
    final db = await getDatabase(path: _dbPath);

    await db.delete(
      'favorite_manga',
      where: 'userId = ? AND favoriteManga LIKE ?',
      whereArgs: [userId, '%$mangaId%'], // Adjusted to handle JSON string
    );
  }

  Future<void> deleteAllFavoriteManga(int userId) async {
    final db = await getDatabase(path: _dbPath);

    await db.delete(
      'favorite_manga',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteAccount(int userId) async {
    final db = await getDatabase(path: _dbPath);

    await db.delete(
      'favorite_manga',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    await db.delete(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
