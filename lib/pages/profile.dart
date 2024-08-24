import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode; // Accept dark mode state

  const ProfilePage({super.key, required this.isDarkMode});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode; // Initialize with passed state
  }

  // Toggle between light and dark mode
  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: _appBar(),
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
                  "Favorited Manga:",
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
                child: _favoritedMangaList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(
        'Profile',
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
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context, isDarkMode);
        },
        child: Container(
            width: 35,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, isDarkMode);
                },
                child: Icon(Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 30))),
      ),
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: _toggleTheme,
        ),
      ],
    );
  }

  Widget _favoritedMangaList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          child: ListTile(
            title: Text(
              "Favorited Manga $index",
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
