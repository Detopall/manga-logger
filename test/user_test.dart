import 'package:flutter_test/flutter_test.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseHelper User Tests', () {
    late DatabaseHelper databaseHelper;
    late String path;

    setUp(() async {
      databaseHelper = DatabaseHelper();
      path = join(await getDatabasesPath(), 'manga_database_user_test.db');
      await databaseHelper.getDatabase(path: path);
    });

    tearDown(() async {
      await databaseHelper.closeDatabase();
      await databaseFactory.deleteDatabase(path);
    });

    test('Insert User', () async {
      await databaseHelper.insertUser('TestUser');

      final users = await databaseHelper.getUsers();
      expect(users, isNotEmpty);
      expect(users[0].username, 'TestUser');
    });

    test('Get User By Username', () async {
      await databaseHelper.insertUser('TestUser');

      final user = await databaseHelper.getUserByUsername("TestUser");

      expect(user.username, 'TestUser');
      expect(user.userId, 1);
    });

    test('Get User By UserId', () async {
      await databaseHelper.insertUser('TestUser');
      final user = await databaseHelper.getUserByUserId(1);

      expect(user.username, 'TestUser');
      expect(user.userId, 1);
    });

    test('Get All Users', () async {
      await databaseHelper.insertUser('TestUser');
      await databaseHelper.insertUser('TestUser2');

      final users = await databaseHelper.getUsers();

      expect(users.length, 2);
    });

    test('Delete User', () async {
      await databaseHelper.insertUser('TestUser');
      await databaseHelper.deleteUser(1);
      final users = await databaseHelper.getUsers();
      expect(users.length, 0);
    });
  });
}
