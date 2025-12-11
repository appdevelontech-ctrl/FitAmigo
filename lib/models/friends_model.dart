class Friend {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String city;
  final String stateName;
  final String profile;
  final String about;
  final String age;
  final List<String> subDepartments;
  final List<String> friends;

  Friend({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.city,
    required this.stateName,
    required this.profile,
    required this.about,
    required this.age,
    required this.subDepartments,
    required this.friends,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json["_id"]?.toString() ?? "",
      username: json["username"]?.toString() ?? "Unknown",
      email: json["email"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      city: json["city"]?.toString() ?? "",
      stateName: json["statename"]?.toString() ?? "",
      profile: json["profile"]?.toString() ?? "",
      about: json["about"]?.toString() ?? "",
      age: json["age"]?.toString() ?? "25",

      /// Ensure values always become list of strings
      subDepartments: (json["subDepartments"] is List)
          ? json["subDepartments"].map<String>((e) => e.toString()).toList()
          : [],

      friends: (json["friends"] is List)
          ? json["friends"].map<String>((e) => e.toString()).toList()
          : [],
    );
  }
}class DepartmentModel {
  final String id;
  final String name;
  final List<String> values;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.values,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      values: (json["value"] is List && json["value"] != null)
          ? List<String>.from(json["value"].map((e) => e.toString()))
          : [], // 🔥 SAFE FALLBACK IF NULL
    );
  }
}



// --------------------------------------------------------

class FriendResponse {
  final bool success;
  final String message;
  final List<Friend> friends;
  final List<DepartmentModel> departments;
  final List<String> subDepartments;

  FriendResponse({
    required this.success,
    required this.message,
    required this.friends,
    required this.departments,
    required this.subDepartments,
  });

  factory FriendResponse.fromJson(Map<String, dynamic> json) {
    return FriendResponse(
      success: json["success"] ?? false,
      message: json["message"]?.toString() ?? "",

      friends: (json["friends"] is List)
          ? json["friends"].map<Friend>((e) => Friend.fromJson(e)).toList()
          : [],

      departments: (json["departments"] is List)
          ? json["departments"]
          .map<DepartmentModel>((e) => DepartmentModel.fromJson(e))
          .toList()
          : [],

      subDepartments: (json["subdepartment"] is List)
          ? json["subdepartment"].map<String>((e) => e.toString()).toList()
          : [],
    );
  }
}


class FriendRequestResponse {
  final bool success;
  final List<dynamic> requests;

  FriendRequestResponse({
    required this.success,
    required this.requests,
  });

  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestResponse(
      success: json["success"] ?? false,
      requests: json["requests"] ?? [],
    );
  }
}
