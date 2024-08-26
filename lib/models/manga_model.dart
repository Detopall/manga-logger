import 'package:http/http.dart' as http;
import 'dart:convert';

class MangaModel {
  String id = "";
  String description = "";
  String titleEn = "";
  String averageRating = "";
  String startDate = "";
  String endDate = "";
  String popularityRank = "";
  String status = "";
  String posterImageOriginal = "";
  int volumeCounter = 0;
  List<String> categoriesLinksRelated = [];

  MangaModel();

  static Future<MangaModel> fromJsonEndpoint(
      Map<String, dynamic> jsonData) async {
    /*

    This function is the creation of
    the Manga Model from the endpoint to retrieve manga data

    */
    List<String> categoriesLinks = await getCategories(jsonData);

    return MangaModel()
      ..id = jsonData['id'] ?? ""
      ..description = jsonData['attributes']?['description'] ?? ""
      ..titleEn = findTitle(jsonData)
      ..averageRating = jsonData['attributes']?['averageRating'] ?? ""
      ..startDate = jsonData['attributes']?['startDate'] ?? ""
      ..endDate = jsonData['attributes']?['endDate'] ?? "on going"
      ..popularityRank =
          jsonData['attributes']?['popularityRank']?.toString() ?? ""
      ..status = jsonData['attributes']?['status'] ?? ""
      ..posterImageOriginal =
          jsonData['attributes']?['posterImage']?['original'] ?? ""
      ..volumeCounter = jsonData['attributes']?['volumeCount'] ?? 0
      ..categoriesLinksRelated = categoriesLinks;
  }

  factory MangaModel.fromJson(Map<String, dynamic> jsonData) {
    /*

    This function is the creation of
    the Manga Model using the stripped data from the endpoint

    */
    return MangaModel()
      ..id = jsonData['id'] ?? ""
      ..description = jsonData['description'] ?? ""
      ..titleEn = jsonData['titleEn'] ?? ""
      ..averageRating = jsonData['averageRating'] ?? ""
      ..startDate = jsonData['startDate'] ?? ""
      ..endDate = jsonData['endDate'] ?? ""
      ..popularityRank = jsonData['popularityRank']?.toString() ?? ""
      ..status = jsonData['status'] ?? ""
      ..posterImageOriginal = jsonData['posterImageOriginal'] ?? ""
      ..volumeCounter = jsonData['volumeCounter'] ?? 0
      ..categoriesLinksRelated =
          List<String>.from(jsonData['categoriesLinksRelated'] ?? []);
  }

  static String findTitle(Map<String, dynamic> jsonData) {
    Map<String, dynamic>? titles = jsonData['attributes']?['titles'];

    if (titles != null) {
      var titleEn = titles.entries
          .firstWhere(
            (entry) => entry.key.contains("en") && entry.value != null,
            orElse: () => titles.entries.first,
          )
          .value;

      return titleEn?.toString() ?? "";
    }
    return "";
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'titleEn': titleEn,
      'averageRating': averageRating,
      'startDate': startDate,
      'endDate': endDate,
      'popularityRank': popularityRank,
      'status': status,
      'posterImageOriginal': posterImageOriginal,
      'volumeCounter': volumeCounter,
      'categoriesLinksRelated': categoriesLinksRelated
    };
  }

  static Future<List<String>> getCategories(
      Map<String, dynamic> jsonData) async {
    List<String> categories = [];

    String uri =
        jsonData['relationships']?['categories']?['links']?['related'] ?? "";

    if (uri == "") {
      return categories;
    }

    try {
      Map<String, dynamic> response = await getCategoryRequest(uri);
      List<dynamic> categoriesJson = response['data'];

      for (var category in categoriesJson) {
        String title = category['attributes']?['title'] ?? "";

        if (title.isNotEmpty) {
          categories.add(title);
        }
      }
    } catch (e) {
      return [];
    }

    return categories;
  }

  static Future<Map<String, dynamic>> getCategoryRequest(String uri) async {
    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load category data');
      }
    } catch (e) {
      throw Exception('Failed to load category data: $e');
    }
  }
}

class PaginationLinks {
  String first = "";
  String next = "";
  String last = "";
  String prev = "";

  PaginationLinks();

  // Factory constructor to create an instance from JSON
  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    var links = json['links'];

    if (links == null) {
      return PaginationLinks();
    }

    return PaginationLinks()
      ..first = json['links']['first'] ?? ""
      ..next = json['links']['next'] ?? ""
      ..last = json['links']['last'] ?? ""
      ..prev = json['links']['prev'] ?? "";
  }
}
