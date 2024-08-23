import 'package:flutter/material.dart';
import 'package:manga_logger/models/manga_model.dart';
import 'dart:convert';

class MangaDetailsPage extends StatelessWidget {
  final MangaModel manga;

  const MangaDetailsPage({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    // Extract information to avoid repetitive code
    final List<String> details = [
      'Average Rating: ${manga.averageRating}',
      'Start Date: ${manga.startDate}',
      'End Date: ${manga.endDate}',
      'Status: ${manga.status}',
      'Popularity Rank: ${manga.popularityRank}',
    ];

    // Generate a list of clickable buttons representing manga volumes
    final List<int> volumes =
        List.generate(manga.volumeCounter, (index) => index + 1);

    String mangaTitle = utf8.decode(manga.titleEn.codeUnits);

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
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              manga.posterImageOriginal,
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
                              manga.posterImageOriginal,
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
                              text: manga.description,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: volumes.map((volume) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Action to mark the volume as bought
                                print('Volume $volume clicked!');
                              },
                              child: Text('Volume $volume'),
                            ),
                          );
                        }).toList(),
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

  // Method to create styled labels
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
}
