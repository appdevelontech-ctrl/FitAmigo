class PageModel {
  final String id;
  final String title;
  final String description;
  final String metaTitle;
  final String metaDescription;
  final String metaKeywords;

  PageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    final page = json['Mpage'];
    return PageModel(
      id: page['_id'] ?? '',
      title: page['title'] ?? '',
      description: page['description'] ?? '',
      metaTitle: page['metaTitle'] ?? '',
      metaDescription: page['metaDescription'] ?? '',
      metaKeywords: page['metaKeywords'] ?? '',
    );
  }
}
