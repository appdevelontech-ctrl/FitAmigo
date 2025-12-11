class ZoneModel {
  final bool success;
  final List<String> uniqueLocations;

  ZoneModel({required this.success, required this.uniqueLocations});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      success: json['success'] ?? false,
      uniqueLocations: List<String>.from(json['uniqueLocations'] ?? []),
    );
  }
}