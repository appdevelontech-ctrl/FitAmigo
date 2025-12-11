// class Friend {
//   final String id;
//   final String username;
//   final String email;
//   final String phone;
//   final String city;
//   final String stateName;
//   final String profile;
//   final String about;
//   final String age;
//   final List<String> subDepartments;
//   final List<String> friends;
//
//   Friend({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.phone,
//     required this.city,
//     required this.stateName,
//     required this.profile,
//     required this.about,
//     required this.age,
//     required this.subDepartments,
//     required this.friends,
//   });
//
//   factory Friend.fromJson(Map<String, dynamic> json) {
//     return Friend(
//       id: json["_id"] ?? "",
//       username: json["username"] ?? "Unknown",
//       email: json["email"] ?? "",
//       phone: json["phone"] ?? "",
//       city: json["city"] ?? "",
//       stateName: json["statename"] ?? "",
//       profile: json["profile"] ?? "",
//       about: json["about"] ?? "",
//       age: json["age"]?.toString() ?? "25",
//       subDepartments: List<String>.from(json["subDepartments"] ?? []),
//       friends: List<String>.from(json["friends"] ?? []),
//     );
//   }
// }
