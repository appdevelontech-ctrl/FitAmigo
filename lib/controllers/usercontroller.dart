// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../models/user_model.dart';
// import '../services/api_service.dart';
//
// class UserController extends GetxController {
//   final Rx<User?> user = Rx<User?>(null);
//   final RxBool isLoggedIn = false.obs;
//   final RxBool isLoading = false.obs;
//   final ApiService apiService = ApiService();
//   final RxString hashOtp = ''.obs;
//   final RxString userId = ''.obs;
//
//   // NEW: store plain otp for dev/testing (remove for production)
//   final RxString plainOtp = ''.obs; // <<<
//
//   @override
//   void onInit() async {
//     super.onInit();
//     await checkLoginStatus();
//   }
//
//   /// 📲 Login with OTP
//   Future<void> loginWithOtp(String phone) async {
//     isLoading.value = true;
//     print('📞 Starting OTP login for phone: $phone');
//     try {
//       final response = await apiService.loginWithOtp(phone);
//       print('📡 API Response (loginWithOtp): ${jsonEncode(response)}');
//
//       if (response['success'] == true) {
//         // existing: hashed otp (bcrypt or hash)
//         hashOtp.value = response['otp'] ?? '';
//         await _saveHashOtp(hashOtp.value);
//         print('✅ OTP hash saved: ${hashOtp.value}');
//
//         // NEW: save plain newotp if API returns it (for dev fallback)
//         final newOtpVal = response['newotp']?.toString() ?? '';
//         if (newOtpVal.isNotEmpty) {
//           plainOtp.value = newOtpVal;
//           await _savePlainOtp(plainOtp.value); // <<< save plain otp to prefs
//           print('🔑 Plain newotp saved for dev: ${plainOtp.value}');
//         } else {
//           print('ℹ️ No plain newotp in response');
//         }
//
//         String tempUserId = response['existingUser']?['_id']?.toString() ?? '';
//         if (tempUserId.isNotEmpty) {
//           userId.value = tempUserId;
//           await _saveUserId(userId.value);
//           print('👤 User ID saved: ${userId.value}');
//         } else {
//           print('⚠️ No existing user ID found in response');
//         }
//       } else {
//         throw Exception(response['message'] ?? 'OTP request failed');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Login failed: $e');
//       print('❌ OTP login error: $e');
//     } finally {
//       isLoading.value = false;
//       print('🟢 loginWithOtp complete');
//     }
//   }
//
//   /// ✅ Verify OTP
//   Future<void> verifyOtp(String otp) async {
//     isLoading.value = true;
//     print('🔐 Verifying OTP: $otp');
//     try {
//       final storedHashOtp = await _getHashOtp();
//       print('🧩 Stored OTP hash: $storedHashOtp');
//       if (storedHashOtp.isEmpty) {
//         throw Exception('No OTP hash found');
//       }
//
//       // NEW: if plain OTP stored (dev), use that instead of user input
//       final storedPlain = await _getPlainOtp();
//       String otpToUse = storedPlain.isNotEmpty ? storedPlain : otp;
//       if (storedPlain.isNotEmpty) {
//         print('🔁 Using stored plain OTP for verification (dev): $storedPlain');
//       } else {
//         print('🔁 Using user-entered OTP for verification');
//       }
//
//       final response = await apiService.verifyOtp(otpToUse, storedHashOtp);
//       print('📡 API Response (verifyOtp): ${jsonEncode(response)}');
//
//       if (response['success'] == true) {
//         // Removed 'sucesss' check to avoid typo
//         String tempUserId = response['existingUser']?['_id']?.toString() ?? '';
//         print('👤 Temp userId found: $tempUserId');
//         if (tempUserId.isNotEmpty) {
//           userId.value = tempUserId;
//           await _saveUserId(userId.value);
//           print('💾 User ID saved to SharedPreferences');
//         }
//
//         final userResponse = await apiService.fetchUserDetails(
//           userId.value,
//           '',
//         );
//         print(
//           '📡 API Response (fetchUserDetails): ${jsonEncode(userResponse)}',
//         );
//         if (userResponse['success'] == true) {
//           user.value = User.fromJson(userResponse);
//           isLoggedIn.value = true;
//           await _saveUser(user.value!);
//           await _saveLoginState(true);
//           await _clearHashOtp();
//           await _clearPlainOtp(); // <<< clear dev plain otp after success
//           print('✅ User verified & saved: ${user.value?.username}');
//         } else {
//           throw Exception(
//             'Failed to fetch user data: ${userResponse['message'] ?? 'Unknown error'}',
//           );
//         }
//       } else {
//         throw Exception(
//           'Invalid OTP: ${response['message'] ?? 'Unknown error'}',
//         );
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Verification failed: $e');
//       print('🔥 Verify OTP error: $e');
//     } finally {
//       isLoading.value = false;
//       print('🟢 verifyOtp complete');
//     }
//   }
//
//   /// 💾 Save user locally
//   Future<void> _saveUser(User user) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_data', jsonEncode(user.toJson()));
//       print('💾 User data saved locally');
//     } catch (e) {
//       print('❌ Error saving user data: $e');
//       rethrow;
//     }
//   }
//
//   /// 🔐 Save login state
//   Future<void> _saveLoginState(bool status) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('is_logged_in', status);
//       print('🔐 Login state saved: $status');
//     } catch (e) {
//       print('❌ Error saving login state: $e');
//       rethrow;
//     }
//   }
//
//   /// 🔍 Get login state
//   Future<bool> _getLoginState() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final state = prefs.getBool('is_logged_in') ?? false;
//       print('📖 Retrieved login state: $state');
//       return state;
//     } catch (e) {
//       print('❌ Error retrieving login state: $e');
//       return false;
//     }
//   }
//
//   /// 🚪 Logout
//   Future logout() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // 🔥 STEP 1: Get FCM Token BEFORE clearing
//       final fcmToken = prefs.getString('fcmToken');
//       print('🔥 Logout: Current FCM Token: $fcmToken');
//
//       // 🔥 STEP 2: Clear sab kuch EXCEPT FCM Token
//       await prefs.remove('user_data');
//       await prefs.remove('is_logged_in');
//       await prefs.remove('user_id');
//       await prefs.remove('hash_otp');
//       await prefs.remove('plain_otp');
//
//       // Reset reactive variables
//       user.value = null;
//       isLoggedIn.value = false;
//       userId.value = '';
//       hashOtp.value = '';
//       plainOtp.value = '';
//
//       print('🚪 User logged out - FCM Token SAFE: $fcmToken');
//       Get.snackbar('Logout', 'You have been logged out');
//
//     } catch (e) {
//       print('❌ Error during logout: $e');
//       Get.snackbar('Error', 'Logout failed: $e');
//     }
//   }
//
//   /// 🔍 Check login status
//   Future<void> checkLoginStatus() async {
//     print('🔍 Checking login status...');
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userData = prefs.getString('user_data');
//       final loggedIn = await _getLoginState();
//       if (userData != null && loggedIn) {
//         user.value = User.fromJson(jsonDecode(userData));
//         userId.value = prefs.getString('user_id') ?? '';
//         isLoggedIn.value = true;
//         print('✅ User is logged in: ${user.value?.username}');
//       } else {
//         isLoggedIn.value = false;
//         print('ℹ️ No active user session found');
//       }
//     } catch (e) {
//       print('❌ Error checking login status: $e');
//       isLoggedIn.value = false;
//     }
//   }
//
//   /// 🔐 Local storage helpers
//   Future<void> _saveHashOtp(String hashOtp) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('hash_otp', hashOtp);
//       print('💾 Hash OTP saved');
//     } catch (e) {
//       print('❌ Error saving hash OTP: $e');
//       rethrow;
//     }
//   }
//
//   Future<String> _getHashOtp() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final otp = prefs.getString('hash_otp') ?? '';
//       print('📖 Retrieved Hash OTP: $otp');
//       return otp;
//     } catch (e) {
//       print('❌ Error retrieving hash OTP: $e');
//       return '';
//     }
//   }
//
//   Future<void> _clearHashOtp() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('hash_otp');
//       hashOtp.value = '';
//       print('🧹 Cleared stored hash OTP');
//     } catch (e) {
//       print('❌ Error clearing hash OTP: $e');
//       rethrow;
//     }
//   }
//
//   // --- NEW: plain OTP helpers (dev only) ---
//   Future<void> _savePlainOtp(String plainOtpValue) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('plain_otp', plainOtpValue);
//       plainOtp.value = plainOtpValue;
//       print('💾 Plain OTP saved (dev): $plainOtpValue');
//     } catch (e) {
//       print('❌ Error saving plain OTP: $e');
//       rethrow;
//     }
//   }
//
//   Future<String> _getPlainOtp() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final otp = prefs.getString('plain_otp') ?? '';
//       print('📖 Retrieved plain OTP (dev): $otp');
//       return otp;
//     } catch (e) {
//       print('❌ Error retrieving plain OTP: $e');
//       return '';
//     }
//   }
//
//   Future<void> _clearPlainOtp() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('plain_otp');
//       plainOtp.value = '';
//       print('🧹 Cleared stored plain OTP (dev)');
//     } catch (e) {
//       print('❌ Error clearing plain OTP: $e');
//       rethrow;
//     }
//   }
//   // --- END plain OTP helpers ---
//
//   Future<void> _saveUserId(String userId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_id', userId);
//       print('💾 User ID saved: $userId');
//     } catch (e) {
//       print('❌ Error saving userId: $e');
//       rethrow;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/notificationervice.dart';
import '../views/login_screen.dart';

class UserController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final ApiService apiService = ApiService();
  final RxString plainOtp = ''.obs;  // << needed for showing OTP in UI

  final RxString hashOtp = ''.obs;
  final RxString userId = ''.obs;
  final RxBool isNewUser = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await checkLoginStatus();
  }
  Future<void> loginWithOtp(String phone) async {
    isLoading.value = true;

    try {
      final response = await apiService.loginWithOtp(phone);

      if (response['success'] == true) {


        // ----------------------------------------------
        // ⭐ 1. CATCH NEW OTP FOR TESTING
        // ----------------------------------------------
        final String newOtp = response['newotp']?.toString() ?? "";
        if (newOtp.isNotEmpty) {
          plainOtp.value = newOtp;         // UI show
          await _savePlainOtp(newOtp);     // save locally
          print("🔥 Test OTP Stored: $newOtp");
        } else {
          print("ℹ️ API did NOT return newotp");
        }
        final bool newUserCheck = response['newUser'] == true ||
            response['message'] == 'User not found' ||
            response['existingUser'] == null;

        if (newUserCheck) {
          isNewUser.value = true;

          final signupRes = await apiService.signupNewUser(phone);

          if (signupRes['success'] != true) {
            throw Exception(signupRes['message'] ?? 'Signup Failed');
          }

          hashOtp.value = signupRes['otp'] ?? '';
          await _saveHashOtp(hashOtp.value);

          String tempUserId = signupRes['existingUser']?['_id'] ?? "";
          if (tempUserId.isNotEmpty) {
            userId.value = tempUserId;
            await saveUserId(userId.value);
          }

        } else {
          isNewUser.value = false;

          hashOtp.value = response['otp'] ?? '';
          await _saveHashOtp(hashOtp.value);

          String tempUserId = response['existingUser']?['_id'] ?? "";
          if (tempUserId.isNotEmpty) {
            userId.value = tempUserId;
            await saveUserId(userId.value);
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _savePlainOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("plain_otp", otp);
  }

  Future<String> _getPlainOtp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("plain_otp") ?? "";
  }

  Future<void> _clearPlainOtp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("plain_otp");
    plainOtp.value = "";
  }



  Future<void> signupNewUser(String phone) async {
    try {



      final signupResponse = await apiService.signupNewUser(phone);

      print("🆕 Signup Response: $signupResponse");

      if (signupResponse["success"] == true) {

        hashOtp.value = signupResponse['otp'] ?? '';

        String id = signupResponse['existingUser']?['_id'] ?? "";
        if (id.isNotEmpty) {
          userId.value = id;
          await saveUserId(userId.value);
        }

        print("🎉 User Created & OTP Generated");

      } else {
        Get.snackbar("Error", signupResponse["message"] ?? "Signup failed");
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }


  RxString uploadedImageBase64 = ''.obs;



  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    print('🔐 Verifying OTP: $otp');

    try {
      final storedHashOtp = await _getHashOtp();
      print('🧩 Stored OTP hash: $storedHashOtp');

      if (storedHashOtp.isEmpty) {
        throw Exception('No OTP hash found');
      }

      final response = await apiService.verifyOtp(otp, storedHashOtp);
      print('📡 API Response (verifyOtp): ${jsonEncode(response)}');

      if (response['success'] == true) {
        // ✅ yahan se sirf userId use karna hai jo pehle save hua tha
        if (userId.value.isEmpty) {
          userId.value = await apiService.getUserId();
        }

        if (userId.value.isEmpty) {
          throw Exception('UserId missing. Please login again.');
        }

        final userResponse =
        await apiService.fetchUserDetails(userId.value, '');
        print('📡 API Response (fetchUserDetails): ${jsonEncode(userResponse)}');

        if (userResponse['success'] == true) {
          user.value = User.fromJson(userResponse);
          isLoggedIn.value = true;
          await _saveUser(user.value!);
          await _saveLoginState(true);
          await _clearHashOtp();
          await _clearPlainOtp();  // <-- Plain OTP clear here
          print('✅ User verified & saved: ${user.value?.username}');
        } else {
          throw Exception(
              'Failed to fetch user data: ${userResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed: $e');
      print('🔥 Verify OTP error: $e');
    } finally {
      isLoading.value = false;
      print('🟢 verifyOtp complete');
    }
  }


  Future<void> updateProfile({
    required String username,
    required String phone,
    required String email,
    required String pincode,
    required String address,
    required String city,
    required String about,
  }) async {

    isLoading.value = true;

    try {
      final u = user.value!;

      final payload = {
        "type": u.type?.toString() ?? "",
        "username": username,
        "phone": phone,
        "email": email,
        "password": "",
        "confirm_password": "",
        "pincode": pincode,
        "Gender": "1",
        "DOB": "",
        "address": address,
        "state": u.state ?? "",
        "statename": u.statename ?? "",
        "country": "",
        "city": city,
        "about": about,
        "SetEmail": "",
        "profile_url": username.toLowerCase().replaceAll(" ", "-"),

        // 🔥 IMPORTANT — if image selected send base64 else send old image
        "profile": uploadedImageBase64.value.isNotEmpty
            ? uploadedImageBase64.value
            : (u.profile ?? ""),
      };

      print("📤 FINAL PAYLOAD ---> $payload");

      final response = await apiService.updateUserProfile(payload, userId.value);

      if (response["success"] == true) {
        Get.snackbar("Success", "Profile updated successfully!");

        final refreshed = await apiService.fetchUserDetails(userId.value, "");
        user.value = User.fromJson(refreshed);
        await _saveUser(user.value!);

        uploadedImageBase64.value = ""; // reset
      }
      else {
        Get.snackbar("Error", response["message"] ?? "Update failed");
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// 💾 Save user locally
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    print('💾 User data saved locally');
  }

  /// 🔐 Save login state
  Future<void> _saveLoginState(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', status);
  }

  /// 🔍 Get login state
  Future<bool> _getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔥 1. Get FCM Token before clearing storage
      final fcmToken = prefs.getString("fcm_token");
      print("🔥 Saving FCM before logout: $fcmToken");

      // ❌ 2. Remove only login-related data
      await prefs.remove('user_id');
      await prefs.remove('user_data');
      await prefs.remove('hash_otp');

      // 🔥 3. Set login flag to FALSE
      await prefs.setBool('is_logged_in', false);

      // 🔥 4. Restore FCM token (if exists)
      if (fcmToken != null) {
        await prefs.setString("fcm_token", fcmToken);
      }

      // 5. Reset runtime values
      user.value = null;
      userId.value = '';
      hashOtp.value = '';

      isLoggedIn.value = false;

      print("🚪 Logout success: User data cleared, FCM preserved");

      // OPTIONAL: Move to login screen
      Navigator.pushAndRemoveUntil(
        Get.context!,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );


    } catch (e) {
      print("❌ Logout error: $e");
      Get.snackbar("Error", "Logout failed: $e");
    }
  }


  /// 🔍 Check login status
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final loggedIn = await _getLoginState();

    if (userData != null && loggedIn) {
      user.value = User.fromJson(jsonDecode(userData));
      userId.value = prefs.getString('user_id') ?? '';
      isLoggedIn.value = true;
      print('✅ User is logged in');
    } else {
      isLoggedIn.value = false;
      print('ℹ No active session');
    }
  }

  /// 🔐 Local storage helpers

  Future<void> _saveHashOtp(String hashOtp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hash_otp', hashOtp);
  }

  Future<String> _getHashOtp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hash_otp') ?? '';
  }

  Future<void> _clearHashOtp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hash_otp');
    hashOtp.value = '';
  }

  /// ❇️ FIXED FUNCTION
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }


  /// 🟢 Calculate Profile Completion Percentage Dynamically
  double get profileCompletion {
    final u = user.value;
    if (u == null) return 0.0;

    int totalFields = 8;
    int filled = 0;

    if (u.username != null && u.username!.isNotEmpty) filled++;
    if (u.phone != null && u.phone!.isNotEmpty) filled++;
    if (u.email != null && u.email!.isNotEmpty) filled++;
    if (u.city != null && u.city!.isNotEmpty) filled++;
    if (u.pincode != null && u.pincode!.isNotEmpty) filled++;
    if (u.address != null && u.address!.isNotEmpty) filled++;
    if (u.about != null && u.about!.isNotEmpty) filled++;

    // Profile Image Condition
    if (u.profile != null && u.profile!.isNotEmpty) filled++;

    return filled / totalFields;
  }

}
