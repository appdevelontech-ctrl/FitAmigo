// lib/models/product_detail_model.dart
class ProductDetailModel {
  final String message;
  final bool success;
  final ProductDetail? product;

  ProductDetailModel({
    required this.message,
    required this.success,
    this.product,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      product: json['Product'] != null
          ? ProductDetail.fromJson(json['Product'])
          : null,
    );
  }
}

class ProductDetail {
  final String id;
  final String title;
  final String description;
  final String pImage;
  final List<String> images;
  final String slug;
  final double regularPrice;
  final double salePrice;
  final int stock;
  final List<String> coverageCities;
  final Map<String, dynamic> specifications;
  final List<dynamic> features;
  final String metaTitle;
  final String metaDescription;

  ProductDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.pImage,
    required this.images,
    required this.slug,
    required this.regularPrice,
    required this.salePrice,
    required this.stock,
    required this.coverageCities,
    required this.specifications,
    required this.features,
    required this.metaTitle,
    required this.metaDescription,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    // extract coverage cities
    final coverage = (json['coverage'] as List<dynamic>?)
        ?.map((e) => e['city'] as String)
        .toList() ??
        [];

    return ProductDetail(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pImage: json['pImage'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      slug: json['slug'] ?? '',
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      coverageCities: coverage,
      specifications: json['specifications'] ?? {},
      features: json['features'] ?? [],
      metaTitle: json['metaTitle'] ?? '',
      metaDescription: json['metaDescription'] ?? '',
    );
  }
}