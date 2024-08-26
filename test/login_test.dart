import 'package:flutter_test/flutter_test.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseHelper Login/Logout Tests', () {
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


    test('Set and get last logged-in user', () async {
      await databaseHelper.insertUser('testUser');
      final user = await databaseHelper.getUserByUsername('testUser');

      await databaseHelper.setLastLoggedInUser(user.userId);
      int? lastUserId = await databaseHelper.getLastLoggedInUser();

      expect(lastUserId, user.userId);
    });

    test('Get last logged-in user', () async {
      await databaseHelper.insertUser('testUser');
      final user = await databaseHelper.getUserByUsername('testUser');

      await databaseHelper.setLastLoggedInUser(user.userId);
      int? lastUserId = await databaseHelper.getLastLoggedInUser();

      expect(lastUserId, user.userId);
    });

    test('Logout user', () async {
      await databaseHelper.insertUser('testUser');
      final user = await databaseHelper.getUserByUsername('testUser');

      await databaseHelper.setLastLoggedInUser(user.userId);
      int? lastUserId = await databaseHelper.getLastLoggedInUser();

      expect(lastUserId, user.userId);
    });

  });
}
