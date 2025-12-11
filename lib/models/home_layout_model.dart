class HomeLayoutModel {
  final String message;
  final bool success;
  final HomeLayoutData homeLayout;

  HomeLayoutModel({
    required this.message,
    required this.success,
    required this.homeLayout,
  });

  factory HomeLayoutModel.fromJson(Map<String, dynamic> json) {
    return HomeLayoutModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      homeLayout: HomeLayoutData.fromJson(json['homeLayout'] ?? {}),
    );
  }
}

class HomeLayoutData {
  final String id;
  final String topBar;
  final String sliderImg;
  final List<BannerItem> latestProductBanner;

  HomeLayoutData({
    required this.id,
    required this.topBar,
    required this.sliderImg,
    required this.latestProductBanner,
  });

  factory HomeLayoutData.fromJson(Map<String, dynamic> json) {
    return HomeLayoutData(
      id: json['_id'] ?? '',
      topBar: json['top_bar'] ?? '',
      sliderImg: json['slider_img'] ?? '',
      latestProductBanner: (json['latest_product_banner'] as List<dynamic>?)
          ?.map((item) => BannerItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class BannerItem {
  final String imageInput;
  final String imageUrlInput;
  final String imageParaInput;
  final String imageTITInput;

  BannerItem({
    required this.imageInput,
    required this.imageUrlInput,
    required this.imageParaInput,
    required this.imageTITInput,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      imageInput: json['imageInput'] ?? '',
      imageUrlInput: json['imageUrlInput'] ?? '',
      imageParaInput: json['imageParaInput'] ?? '',
      imageTITInput: json['imageTITInput'] ?? '',
    );
  }
}