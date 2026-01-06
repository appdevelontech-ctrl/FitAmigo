import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/category_detail_model.dart';
import '../models/category_product_model.dart';


import '../models/findfriendmodel.dart';
import '../models/friends_model.dart';
import '../models/home_layout_model.dart';
import '../models/order_model.dart';
import '../models/page_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_rating.dart';
import '../models/zone_model.dart';
import 'notificationervice.dart';


class ApiService {
  static const String baseUrl = 'https://dharma-back-dbxy.onrender.com';
  static const String googlePlacesKey = 'AIzaSyCcppZWLo75ylSQvsR-bTPZLEFEEec5nrY';

  Future<ZoneModel> getAllZones() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-zones-only'));
    print("Response (getAllZones): ${response.body}");
    if (response.statusCode == 200) {
      return ZoneModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load zones: ${response.statusCode}');
    }
  }
  Future<List<DepartmentModel>> getDepartments() async {
    final url = "https://dharma-back-dbxy.onrender.com/get-all-department";

    final response = await http.get(Uri.parse(url));

    print("📩 DEPARTMENT RAW: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // ✔ FIXED → correct key is "Department"
      if (jsonData["Department"] == null) {
        print("⚠ Department field NULL mila");
        return [];
      }

      return (jsonData["Department"] as List)
          .map((d) => DepartmentModel.fromJson(d))
          .toList();
    } else {
      throw Exception("Failed to load departments");
    }
  }




  Future<HomeLayoutModel> getHomeLayoutData() async {
    final response = await http.get(Uri.parse('$baseUrl/home-layout-data'));
    print("Response (getHomeLayoutData): ${response.body}");
    if (response.statusCode == 200) {
      return HomeLayoutModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load home layout data: ${response.statusCode}');
    }
  }

  Future<CategoryProductModel> getCategoryProducts(String location) async {
    final response = await http.get(Uri.parse('$baseUrl/get-catgeory-product?location=$location'));
    print("Response (getCategoryProducts): ${response.body}");
    if (response.statusCode == 200) {
      return CategoryProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load category products: ${response.statusCode}');
    }
  }

  Future<CategoryDetailModel> getCategoryDetail(String slug, {String? location = 'delhi'}) async {
    final effectiveLocation = location ?? 'delhi';
    final response = await http.get(
      Uri.parse('$baseUrl/all/category-slug/$slug?filter=&price&page=1&perPage=100&location=$effectiveLocation'),
    );
    print("Response (getCategoryDetail): ${response.body}");
    if (response.statusCode == 200) {
      return CategoryDetailModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load category detail: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> signupNewUser(String phone) async {
    try {


      final response = await http.post(
        Uri.parse('$baseUrl/signup-new-user/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "Gtoken": "sddwdwdwdd",
          "password": ""
        }),
      );

      print("Response (signupNewUser): ${response.body}");
      final result = jsonDecode(response.body);

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Signup failed');
      }

      return result;
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> loginWithOtp(String phone) async {
    try {


      // 🔥 GET FCM Token from SharedPreferences
      final fcmToken = await NotificationService.getFCMToken() ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/login-with-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': '',
          "fcm": fcmToken  // 🔥 FCM Token pass kar diya
        }),
      );

      print("Response (loginWithOtp): ${response.body}");
      print("🔥 FCM Token sent with login: $fcmToken");

      final result = jsonDecode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'OTP request failed');
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> verifyOtp(String otp, String hashOtp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'OTP': otp, 'HASHOTP': hashOtp}),
      );
      print("Response (verifyOtp): ${response.body}");
      final result = jsonDecode(response.body);

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Verification failed');
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Verification failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userId, String token) async {
    try {
      final effectiveUserId = userId.isEmpty ? await getUserId() : userId;
      final response = await http.post(
        Uri.parse('$baseUrl/auth-user/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': effectiveUserId}),
      );
      print("Response (fetchUserDetails): ${response.body}");
      final result = jsonDecode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to fetch user details');
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> body, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("Profile Update Response: ${response.body}");
      return jsonDecode(response.body);

    } catch (e) {
      Get.snackbar("Error", e.toString());
      rethrow;
    }
  }




  // Future<void> _saveUserId(String userId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('user_id', userId);
  //     print('🔐 User ID saved in SharedPreferences: $userId');
  //   } catch (e) {
  //     print('❌ Error saving userId: $e');
  //     throw Exception('Failed to save userId: $e');
  //   }
  // }

  Future<String> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      print('📖 Retrieved userId: $userId');
      return userId;
    } catch (e) {
      print('❌ Error retrieving userId: $e');
      return '';
    }
  }

  Future<FriendResponse> getFriends() async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.get(Uri.parse('$baseUrl/get-friends/$userId'));
      print("Response (getFriends): ${response.body}");
      if (response.statusCode == 200) {
        return FriendResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load friends: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }

  Future<FriendRequestResponse> getFriendRequests() async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.get(Uri.parse('$baseUrl/get-friend-requests/$userId'));
      print("Response (getFriendRequests): ${response.body}");
      if (response.statusCode == 200) {
        return FriendRequestResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load friend requests: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }

  Future<FriendResponse> findAllFriends(String query) async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.get(Uri.parse('$baseUrl/get-all-friend?userId=$userId&query=$query'));
      print("Response (findAllFriends): ${response.body}");
      if (response.statusCode == 200) {
        return FriendResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to find friends: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }Future<FriendResponse> getFilteredFriends({
    required String state,
    required String city,
    required String department,
    required String subDepartment,
    required int page,
    required String distance,
    String? lat,
    String? lng,
  }) async {

    final userId = await getUserId();
    if (userId.isEmpty) throw Exception("⚠ User ID missing!");

    final Map<String, String> params = {
      "page": page.toString(),
      "limit": "50",
      "userId": userId,
    };

    // Normal State/City mode
    if (lat == null && lng == null) {
      params["state"] = state;
      params["city"] = city;
    }

    // GPS Mode Fix
    if (lat != null && lng != null) {
      params["lat"] = lat;
      params["lng"] = lng;
      params["Distance"] = distance;

      // 🔥 Force backend requirement
      params["state"] = "Delhi";
      params["city"] = "Delhi";
    }


    if (department.isNotEmpty) params["department"] = department;
    if (subDepartment.isNotEmpty) params["subDepartment"] = subDepartment;

    final uri = Uri.parse(baseUrl).replace(
      path: "/get-all-friend",
      queryParameters: params,
    );

    print("🌍 Sending Filter URL: $uri");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print("🎯 Filter API Response: ${response.body}");
      return FriendResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("❌ Error: ${response.body}");
    }
  }



  Future<List<DepartmentModel>> getAllDepartments() async {
    final uri = Uri.parse("https://dharma-back-dbxy.onrender.com/get-all-department");

    final response = await http.get(uri);
print("Response is : ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["Department"] as List)
          .map((e) => DepartmentModel.fromJson(e))
          .toList();
    } else {
      throw Exception("❌ Error loading departments");
    }
  }
  Future<Map<String, dynamic>> getApi(String url) async {
    print("🌐 Calling API: $url");

    final response = await http.get(Uri.parse(url));

    print("📩 API RAW RESPONSE:");
    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: ${response.body}");
    }
  }
  Future<Map<String, dynamic>> getNearbyGyms({
    required double lat,
    required double lng,
    required String state,
    required String city,
    required String departmentId,
  }) async {

    final userId = await getUserId();

    print("\n🔥 FETCHING NEARBY GYMS (DYNAMIC)");
    print("state = $state");
    print("city = $city");
    print("lat = $lat");
    print("lng = $lng");
    print("departmentId = $departmentId");

    // 🔥 BUILD DYNAMIC NEARBY URL
    final url = "$baseUrl/get-all-listing"
        "?state=$state"
        "&city=$city"
        "&department=$departmentId"
        "&subDepartment="
        "&page=1"
        "&limit=50"
        "&lat=$lat"
        "&lng=$lng"
        "&Distance=5"
        "&userId=$userId";

    print("🌍 Final Nearby API URL:\n$url");

    try {
      final response = await getApi(url);

      print("🎯 Found: ${response["friends"]?.length ?? 0} gyms");
      return response;

    } catch (e) {
      print("❌ Nearby API Error: $e");
      return {"success": false, "message": e.toString()};
    }
  }





  Future<void> sendFriendRequest(String receiverId) async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.post(
        Uri.parse('$baseUrl/send-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senderId': userId, 'receiverId': receiverId}),
      );
      print("Response (sendFriendRequest): ${response.body}");
      if (response.statusCode != 200) {
        throw Exception('Failed to send friend request: ${response.statusCode}');
      }
      Get.snackbar('Success', 'Friend request sent!');
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String senderId) async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.post(
        Uri.parse('$baseUrl/accept-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senderId': senderId, 'receiverId': userId}),
      );
      print("Response (acceptFriendRequest): ${response.body}");
      if (response.statusCode != 200) {
        throw Exception('Failed to accept friend request: ${response.statusCode}');
      }
      Get.snackbar('Success', 'Friend request accepted!');
    } catch (e) {
      Get.snackbar('Error', 'Network issue: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getMessages(String userId, String friendId) async {
    final url = Uri.parse('$baseUrl/get-message/$userId/$friendId');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/add-message"); // your API endpoint
    final headers = {"Content-Type": "application/json"};

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("❌ Error sending message: $e");
      return {"success": false, "message": e.toString()};
    }
  }




  Future<ProductDetailModel> getProductBySlug(String slug) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-product-slug/$slug'),
    );
    print("Response (getProductBySlug): ${response.body}");
    if (response.statusCode == 200) {
      return ProductDetailModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<ProductRatingResponse> getProductRatings(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/view-product-rating/$productId'),
    );
    print("Response (getProductRatings): ${response.body}");
    if (response.statusCode == 200) {
      return ProductRatingResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load ratings: ${response.statusCode}');
    }
  }




  // Add inside ApiService class

  Future<UserOrdersResponse> getUserOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-orders/$userId'),
    );
    print("Response (getUserOrders): ${response.body}");
    if (response.statusCode == 200) {
      return UserOrdersResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<OrderDetailResponse> getOrderDetail(String userId, String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-orders-view/$userId/$orderId'),
    );
    print("Response (getOrderDetail): ${response.body}");
    if (response.statusCode == 200) {
      return OrderDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load order detail: ${response.statusCode}');
    }
  }
// Inside ApiService class
  Future<Map<String, dynamic>> createOrder(String userId, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/create-order/$userId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    print("createOrder → ${response.statusCode}: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Order failed: ${response.statusCode}');
    }
  }


  Future<PageModel?> getPrivacyPolicy() async {
    try {
      final userId=await getUserId();
      final response = await http.get(Uri.parse('$baseUrl/admin/get-page/691efcb380cb2361aa300f10'));

      print("RAW Privacy Policy Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PageModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print("❌ Privacy Policy Error: $e");
      return null;
    }
  }


  Future<PageModel?> getTermsConditions() async {
    try {
      final userId = await getUserId();
      if (userId.isEmpty) throw Exception('No userId found');
      final response = await http.get(Uri.parse('$baseUrl/admin/get-page/691efcb380cb2361aa300f10'));
      if (response.statusCode == 200) {
        return PageModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("❌ Terms Error: $e");
      return null;
    }
  }
}