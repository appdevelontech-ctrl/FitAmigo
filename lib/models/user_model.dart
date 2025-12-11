import 'dart:convert';

class User {
  final String? id;
  final String? username;
  final String? phone;
  final String? email;
  final int? type;
  final String? state;
  final String? statename;
  final String? city;
  final String? address;
  final int? verified;
  final String? pincode;
  final String? about;
  final List<dynamic>? department;
  final String? doc1;
  final String? doc2;
  final String? doc3;
  final String? profile;
  final String? pHealthHistory;
  final String? cHealthStatus;
  final List<dynamic>? coverage;
  final List<dynamic>? gallery;
  final List<dynamic>? images;
  final List<dynamic>? mId;
  final List<dynamic>? dynamicUsers;

  User({
    this.id,
    this.username,
    this.phone,
    this.email,
    this.type,
    this.state,
    this.statename,
    this.city,
    this.address,
    this.verified,
    this.pincode,
    this.about,
    this.department,
    this.doc1,
    this.doc2,
    this.doc3,
    this.profile,
    this.pHealthHistory,
    this.cHealthStatus,
    this.coverage,
    this.gallery,
    this.images,
    this.mId,
    this.dynamicUsers,
  });

  /// ✅ Factory constructor for parsing API response
  factory User.fromJson(Map<String, dynamic> json) {
    print('🧩 Raw JSON in User.fromJson: $json');

    // Handle nested structure (common API pattern: { success: true, existingUser: {...}} )
    final existingUser = json['existingUser'] as Map<String, dynamic>? ?? json;

    return User(
      id: existingUser['_id']?.toString(),
      username: existingUser['username'],
      phone: existingUser['phone'],
      email: existingUser['email'],
      type: existingUser['type'],
      state: existingUser['state'],
      statename: existingUser['statename'],
      city: existingUser['city'],
      address: existingUser['address'],
      verified: existingUser['verified'],
      pincode: existingUser['pincode'],
      about: existingUser['about'],
      department: existingUser['department'] ?? [],
      doc1: existingUser['Doc1'],
      doc2: existingUser['Doc2'],
      doc3: existingUser['Doc3'],
      profile: existingUser['profile'],
      pHealthHistory: existingUser['pHealthHistory'],
      cHealthStatus: existingUser['cHealthStatus'],
      coverage: existingUser['coverage'] ?? [],
      gallery: existingUser['gallery'] ?? [],
      images: existingUser['images'] ?? [],
      mId: existingUser['mId'] ?? [],
      dynamicUsers: existingUser['dynamicUsers'] ?? [],
    );
  }

  /// ✅ Convert User object → JSON (for saving to SharedPreferences)
  Map<String, dynamic> toJson() {
    final map = {
      '_id': id,
      'username': username,
      'phone': phone,
      'email': email,
      'type': type,
      'state': state,
      'statename': statename,
      'city': city,
      'address': address,
      'verified': verified,
      'pincode': pincode,
      'about': about,
      'department': department,
      'Doc1': doc1,
      'Doc2': doc2,
      'Doc3': doc3,
      'profile': profile,
      'pHealthHistory': pHealthHistory,
      'cHealthStatus': cHealthStatus,
      'coverage': coverage,
      'gallery': gallery,
      'images': images,
      'mId': mId,
      'dynamicUsers': dynamicUsers,
    };
    print('💾 Converting User to JSON: $map');
    return map;
  }

  /// 🔄 Encode User → JSON string
  String toJsonString() => jsonEncode(toJson());

  /// 🔄 Decode JSON string → User
  factory User.fromJsonString(String jsonString) {
    final data = jsonDecode(jsonString);
    print('📖 Decoding JSON string to User: $data');
    return User.fromJson(data);
  }
}
