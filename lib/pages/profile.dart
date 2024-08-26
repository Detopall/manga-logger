import 'package:flutter/material.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:manga_logger/models/user.dart';
import 'package:manga_logger/pages/login.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode; // Accept dark mode state
  final User user;

  const ProfilePage({super.key, required this.isDarkMode, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool isDarkMode;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
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
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(
                  "Favorite Manga:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PermanentMarker',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _favoriteMangaList(),
              ),
              ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
                  ),
                  child: const Text('Logout')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoriteMangaList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          child: ListTile(
            title: Text(
              "Favorite Manga $index",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'PermanentMarker',
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
