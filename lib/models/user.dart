import 'package:manga_logger/models/manga_model.dart';

class User {
  final int userId;
  final String username;
  List<MangaModel> favoriteManga;

  User({
    required this.userId,
    required this.username,
    required this.favoriteManga,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      username: map['username'],
      favoriteManga: map['favoriteManga'] != null
          ? List<MangaModel>.from(
              (map['favoriteManga'] as List).map(
                (mangaMap) => MangaModel.fromJson(mangaMap),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'favoriteManga': favoriteManga.map((manga) => manga.toJson()).toList(),
    };
  }
}
