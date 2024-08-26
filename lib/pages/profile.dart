import 'package:flutter/material.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:manga_logger/models/manga_model.dart';
import 'package:manga_logger/models/user.dart';
import 'package:manga_logger/pages/login.dart';
import 'package:manga_logger/pages/manga_details_page.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final User user;

  const ProfilePage({super.key, required this.isDarkMode, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool isDarkMode;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MangaModel> _favoriteMangaList = [];

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    _loadFavoriteManga();
  }

  Future<void> _loadFavoriteManga() async {
    try {
      int? userId = await _dbHelper.getLastLoggedInUser();
      print(userId);
      if (userId != null) {
        List<MangaModel> favoriteManga =
            await _dbHelper.getAllFavoriteManga(userId);

        setState(() {
          _favoriteMangaList = favoriteManga;
        });
      }
    } catch (e) {
      const SnackBar(
        content: Text('Failed to load favorite manga. Please try again.'),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _dbHelper.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log out. Please try again.'),
        ),
      );
    }
  }

  String _getNameEnding(String name) {
    // ending with s, es, and x don't add " 's"
    if (name.endsWith('s') || name.endsWith('es') || name.endsWith('x')) {
      return "$name'";
    }

    return "$name's";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '${_getNameEnding(widget.user.username)} Profile',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'PermanentMarker',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, isDarkMode);
            },
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          color: isDarkMode ? Colors.black : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  "Favorite Manga:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PermanentMarker',
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _favoriteMangaList.isNotEmpty
                    ? _mangaGrid(_favoriteMangaList)
                    : Center(
                        child: Text(
                          "No favorite manga available.",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mangaGrid(List<MangaModel> mangaList) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        final manga = mangaList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailsPage(manga: manga),
              ),
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  manga.posterImageOriginal,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                utf8.decode(manga.titleEn.codeUnits),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
