// lib/models/category_product_model.dart
class CategoryProductModel {
  final String message;
  final bool success;
  final List<CategoryWithProducts> categoriesWithProducts;

  CategoryProductModel({
    required this.message,
    required this.success,
    required this.categoriesWithProducts,
  });

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    return CategoryProductModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      categoriesWithProducts: (json['categoriesWithProducts'] as List<dynamic>?)
          ?.map((item) => CategoryWithProducts.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class CategoryWithProducts {
  final String id;
  final String title;
  final String slug; // Added slug field
  final String image;
  final String description;
  final List<Product> products;

  CategoryWithProducts({
    required this.id,
    required this.title,
    required this.slug, // Added slug parameter
    required this.image,
    required this.description,
    required this.products,
  });

  factory CategoryWithProducts.fromJson(Map<String, dynamic> json) {
    return CategoryWithProducts(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '', // Added slug parsing
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => Product.fromJson(item))
          .toList() ??
          [],
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

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.pImage,
    required this.salePrice,
    required this.regularPrice,
    required this.stock,
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
    );
  }
}