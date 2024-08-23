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
  String categoriesLinksRelated = "";
  String genresLinksRelated = "";

  MangaModel();

  // Factory constructor to create a new instance from JSON
  factory MangaModel.fromJson(Map<String, dynamic> jsonData) {
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
      ..categoriesLinksRelated =
          jsonData['relationships']?['categories']?['links']?['related'] ?? ""
      ..genresLinksRelated =
          jsonData['relationships']?['genres']?['links']?['related'] ?? "";
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
