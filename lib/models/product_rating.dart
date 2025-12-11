// lib/models/product_rating_model.dart
class ProductRatingResponse {
  final bool success;
  final String message;
  final List<Rating> productRatings;

  ProductRatingResponse({
    required this.success,
    required this.message,
    required this.productRatings,
  });

  factory ProductRatingResponse.fromJson(Map<String, dynamic> json) {
    return ProductRatingResponse( 
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      productRatings: (json['productRatings'] as List<dynamic>?)
          ?.map((e) => Rating.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Rating {
  final String id;
  final int stars;
  final String comment;
  final String userName;

  Rating({
    required this.id,
    required this.stars,
    required this.comment,
    required this.userName,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      stars: json['stars'] ?? 0,
      comment: json['comment'] ?? '',
      userName: json['user']?['username'] ?? 'Anonymous',
    );
  }
}