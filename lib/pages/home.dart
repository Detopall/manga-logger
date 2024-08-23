import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:manga_logger/models/manga_model.dart';
import 'package:manga_logger/pages/manga_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MangaModel> mangaList = [];
  final String url = "https://kitsu.io/api/edge/trending/manga";
  late bool trending = true;
  bool isLoading = false;
  late PaginationLinks paginationLinks;
  String pageTitle = "Trending Manga";

  @override
  void initState() {
    super.initState();

    trending = url.contains("trending");
    if (!trending) {
      pageTitle = "Search Manga";
    }

    paginationLinks = PaginationLinks();

    setState(() {
      isLoading = true;
      trending;
    });

    loadMangaData(url);
  }

  Future<void> loadMangaData(String url) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Parse manga data
        List<MangaModel> loadedManga = (jsonData['data'] as List)
            .map((item) => MangaModel.fromJson(item))
            .toList();

        // Parse pagination links
        PaginationLinks links = PaginationLinks.fromJson(jsonData);

        setState(() {
          mangaList.addAll(loadedManga);
          paginationLinks = links;
          isLoading = false;
          pageTitle = "Trending Manga";
        });
      } else {
        throw Exception('Failed to load manga data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load manga data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchField(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              pageTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: mangaList.isNotEmpty
                ? _mangaGrid(mangaList)
                : Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("No data available")),
          ),
          _paginationButtons(trending, paginationLinks),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Manga Logger',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'PermanentMarker',
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
      centerTitle: true,
      elevation: 0.0,
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          width: 35,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "assets/icons/menu.svg",
            height: 30,
            width: 30,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: 37,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/icons/settings.svg",
              height: 30,
              width: 30,
            ),
          ),
        ),
      ],
    );
  }

  Container _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
          )
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search Manga',
          hintStyle: TextStyle(color: Colors.black),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
        ),
        onSubmitted: (value) {
          String newUrl = "https://kitsu.io/api/edge/";
          if (value.trim() == "") {
            newUrl += "trending/manga";
            pageTitle = "Trending Manga";
            trending = true;
          } else {
            newUrl += "manga?filter[text]=$value";
            pageTitle = "Search Results";
            trending = false;
          }
          newMangaState(newUrl, pageTitle, trending);
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  void newMangaState(String newUrl, String pageTitle, bool trending) {
    return setState(() {
      mangaList.clear();
      trending;
      loadMangaData(newUrl);
      pageTitle;
    });
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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

  Widget _paginationButtons(bool trending, PaginationLinks paginationLinks) {
    if (trending) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: paginationLinks.first.isNotEmpty
              ? () =>
                  newMangaState(paginationLinks.first, "Search Results", false)
              : null,
          child: const Text('First'),
        ),
        ElevatedButton(
          onPressed: paginationLinks.prev.isNotEmpty
              ? () =>
                  newMangaState(paginationLinks.prev, "Search Results", false)
              : null,
          child: const Text('Prev'),
        ),
        ElevatedButton(
          onPressed: paginationLinks.next.isNotEmpty
              ? () =>
                  newMangaState(paginationLinks.next, "Search Results", false)
              : null,
          child: const Text('Next'),
        ),
        ElevatedButton(
          onPressed: paginationLinks.last.isNotEmpty
              ? () =>
                  newMangaState(paginationLinks.last, "Search Results", false)
              : null,
          child: const Text('Last'),
        ),
      ],
    );
  }
}
