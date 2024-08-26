import 'package:flutter/material.dart';
import 'package:manga_logger/models/manga_model.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:manga_logger/pages/login.dart';
import 'dart:convert';

class MangaDetailsPage extends StatefulWidget {
  final MangaModel manga;

  const MangaDetailsPage({super.key, required this.manga});

  @override
  State<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends State<MangaDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // Check favorite status when initializing
  }

  @override
  Widget build(BuildContext context) {
    // Extract information to avoid repetitive code
    final List<String> details = [
      'Average Rating: ${widget.manga.averageRating}',
      'Start Date: ${widget.manga.startDate}',
      'End Date: ${widget.manga.endDate}',
      'Status: ${widget.manga.status}',
      'Popularity Rank: ${widget.manga.popularityRank}',
      'Volumes: ${widget.manga.volumeCounter}',
    ];

    String mangaTitle = utf8.decode(widget.manga.titleEn.codeUnits);

    return Scaffold(
      appBar: AppBar(
        // style font
        title: Text(
          mangaTitle.length < 30
              ? mangaTitle
              : "${mangaTitle.substring(0, 30)}...",
          style: const TextStyle(
            color: Color.fromRGBO(152, 63, 253, 1),
            fontFamily: 'PermanentMarker',
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              widget.manga.posterImageOriginal,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
              ),
            ),
          ),
          // Scrollable Content
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row containing image and description
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image section
                          Expanded(
                            flex: 1, // 1/3 of the row width
                            child: Image.network(
                              widget.manga.posterImageOriginal,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Description section
                          Expanded(
                            flex: 2, // 2/3 of the row width
                            child: RichText(
                                text: TextSpan(
                              text: widget.manga.description,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .white), // Set text color to white for contrast
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Labels styled as buttons, starting from the left
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: details
                            .map((detail) => _styledLabel(detail))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      // Vertical list of clickable volume buttons
                      const Text(
                        "Volumes:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Set text color to white for contrast
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<int?> _getLoggedInUserId() async {
    int? userId = await _dbHelper.getLastLoggedInUser();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
    return userId;
  }

  Future<void> _checkIfFavorite() async {
    int? userId = await _getLoggedInUserId();
    if (userId != null) {
      bool isFavorite =
          await _dbHelper.isFavoriteManga(userId, widget.manga.id);
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    int? userId = await _getLoggedInUserId();
    if (userId == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
      return;
    }

    if (_isFavorite) {
      await _dbHelper.deleteFavoriteManga(userId, widget.manga.id);
      setState(() {
        _isFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await _dbHelper.insertManga(userId, widget.manga);
      setState(() {
        _isFavorite = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to favorites'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
