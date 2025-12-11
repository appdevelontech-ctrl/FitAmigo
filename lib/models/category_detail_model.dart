// lib/models/category_detail_model.dart
class CategoryDetailModel {
  final String message;
  final bool success;
  final List<CategoryItem> categories;

  CategoryDetailModel({
    required this.message,
    required this.success,
    required this.categories,
  });

  factory CategoryDetailModel.fromJson(Map<String, dynamic> json) {
    List<CategoryItem> categoriesList = [];
    // Check if MainCat exists and is a Map
    if (json['MainCat'] != null && json['MainCat'] is Map) {
      final mainCat = json['MainCat'] as Map<String, dynamic>;
      final categoryItem = CategoryItem(
        id: mainCat['_id'] ?? '',
        title: mainCat['title'] ?? '',
        slug: mainCat['slug'] ?? '',
        image: mainCat['image'] ?? '',
        description: mainCat['description'] ?? '',
        products: (json['products'] as List<dynamic>?)?.map((item) => Product.fromJson(item)).toList() ?? [],
        totalPages: json['totalPages'],
        currentPage: json['currentPage'],
      );
      categoriesList.add(categoryItem);
    }
    return CategoryDetailModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      categories: categoriesList,
    );
  }
}

class CategoryItem {
  final String id;
  final String title;
  final String slug;
  final String image;
  final String description;
  final List<Product> products;
  final int? totalPages;
  final int? currentPage;

  CategoryItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.description,
    required this.products,
    this.totalPages,
    this.currentPage,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      products: (json['products'] as List<dynamic>?)?.map((item) => Product.fromJson(item)).toList() ?? [],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }
}
class Product {
  final String id;
  final String title;
  final String description;
  final String pImage;
  final double salePrice;
  final double regularPrice;
  final int stock;
  final String slug; // Added slug

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.pImage,
    required this.salePrice,
    required this.regularPrice,
    required this.stock,
    required this.slug, // Required now
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pImage: json['pImage'] ?? '',
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      slug: json['slug'] ?? '', // Map slug from API
    );
  }
}