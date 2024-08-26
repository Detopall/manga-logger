import 'package:flutter_test/flutter_test.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:manga_logger/models/manga_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  // make mock manga data
  Map<String, dynamic> mockMangaData = {
    'id': "testId",
    'description': "",
    'title': "",
    'titleEn': "",
    'averageRating': "",
    'startDate': "",
    'endDate': "",
    'popularityRank': "",
    'status': "",
    'posterImageOriginal': "",
    'volumeCounter': 0,
    'categoriesLinksRelated': "",
    'genresLinksRelated': ""
  };

  group('DatabaseHelper Manga Tests', () {
    late DatabaseHelper databaseHelper;
    late String path;

    setUp(() async {
      databaseHelper = DatabaseHelper();
      path = join(await getDatabasesPath(), 'manga_database_manga_test.db');
      await databaseHelper.getDatabase(path: path);
    });

    tearDown(() async {
      await databaseHelper.closeDatabase();
      await databaseFactory.deleteDatabase(path);
    });

    test('Insert Manga', () async {
      await databaseHelper.insertUser("TestUser");
      final user = await databaseHelper.getUserByUsername("TestUser");
      const userId = 1;

      expect(user.userId, userId);

      final testManga = MangaModel.fromJson(mockMangaData);

      await databaseHelper.insertManga(userId, testManga);

      MangaModel manga =
          await databaseHelper.getFavoriteManga(userId, "testId");

      expect(manga, isNotNull);
      expect(manga.id, testManga.id);
    });

    test('Get All Manga', () async {
      await databaseHelper.insertUser("TestUser");
      final user = await databaseHelper.getUserByUsername("TestUser");
      const userId = 1;

      expect(user.userId, userId);

      final testManga = MangaModel.fromJson(mockMangaData);

      await databaseHelper.insertManga(userId, testManga);

      List<MangaModel> allManga = await databaseHelper.getAllFavoriteManga(userId);

      expect(allManga, isNotEmpty);
      expect(allManga.length, 1);
      expect(allManga[0].id, testManga.id);
    });

    test('Is Favorite Manga', () async {
      await databaseHelper.insertUser("TestUser");
      final user = await databaseHelper.getUserByUsername("TestUser");
      const userId = 1;

      expect(user.userId, userId);

      final testManga = MangaModel.fromJson(mockMangaData);

      await databaseHelper.insertManga(userId, testManga);

      List<MangaModel> allManga = await databaseHelper.getAllFavoriteManga(userId);

      expect(allManga, isNotEmpty);
      expect(allManga.length, 1);
      expect(allManga[0].id, testManga.id);

      bool isFavorite = await databaseHelper.isFavoriteManga(userId, "testId");

      expect(isFavorite, true);
    });



    test('Delete One Manga', () async {
      await databaseHelper.insertUser("TestUser");
      final user = await databaseHelper.getUserByUsername("TestUser");
      const userId = 1;

      expect(user.userId, userId);

      final testManga = MangaModel.fromJson(mockMangaData);

      await databaseHelper.insertManga(userId, testManga);

      MangaModel manga =
          await databaseHelper.getFavoriteManga(userId, "testId");

      expect(manga, isNotNull);
      expect(manga.id, testManga.id);

      await databaseHelper.deleteFavoriteManga(userId, "testId");

      expect(() => databaseHelper.getFavoriteManga(userId, "testId"),
          throwsA(isA<Exception>()));

      List<MangaModel> allManga = await databaseHelper.getAllFavoriteManga(userId);

      expect(allManga, isEmpty);
    });


    test('Delete All Manga', () async {
      await databaseHelper.insertUser("TestUser");
      final user = await databaseHelper.getUserByUsername("TestUser");
      const userId = 1;

      expect(user.userId, userId);

      final testManga = MangaModel.fromJson(mockMangaData);

      await databaseHelper.insertManga(userId, testManga);

      MangaModel manga =
          await databaseHelper.getFavoriteManga(userId, "testId");

      expect(manga, isNotNull);
      expect(manga.id, testManga.id);

      await databaseHelper.deleteAllFavoriteManga(userId);

      expect(() => databaseHelper.getFavoriteManga(userId, "testId"),
          throwsA(isA<Exception>()));

      List<MangaModel> allManga = await databaseHelper.getAllFavoriteManga(userId);

      expect(allManga, isEmpty);
    });

  });
}
