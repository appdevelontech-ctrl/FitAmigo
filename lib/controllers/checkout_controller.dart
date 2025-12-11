// lib/controllers/checkout_controller.dart
import 'dart:convert';
import 'package:dharma_app/controllers/usercontroller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/cart_controller.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

import '../views/cart_screen.dart';

class CheckoutController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final CartController _cart = Get.find<CartController>();
  final UserController _userCtrl = Get.find<UserController>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _userCtrl.user.value;
    if (user != null) {
      userData.value = user.toJson();
    } else {
      final userId = await _getUserId();
      if (userId.isNotEmpty) {
        try {
          final res = await _api.fetchUserDetails(userId, '');
          if (res['success'] == true) {
            userData.value = res['existingUser'] ?? res;
          }
        } catch (e) {
          Get.snackbar('Error', 'Failed to load user');
        }
      }
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  /// --------------------------------------------------------------
  ///  NEW – placeOrder – EXACT MATCH WITH POSTMAN JSON
  /// --------------------------------------------------------------
  Future<bool> placeOrder({
    required String name,
    required String phone,
    required String address,
    required String pincode,
    required double? lat,
    required double? lng,
  }) async {
    final userId = await _getUserId();

    if (userId.isEmpty || !_userCtrl.isLoggedIn.value) {
      Get.snackbar('Error', 'Please login first', backgroundColor: Colors.red);
      return false;
    }
    if (name.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        pincode.isEmpty) {
      Get.snackbar('Error', 'All fields are required', backgroundColor: Colors.red);
      return false;
    }
    if (lat == null || lng == null) {
      Get.snackbar('Error', 'Location is required', backgroundColor: Colors.red);
      return false;
    }

    isLoading(true);
    try {
      final payload = {
        // ---- TOP-LEVEL FIELDS (exact order as Postman) ----
        "phone": phone,
        "pincode": pincode,
        "address": address,

        // ---- ITEMS (exact keys) ----
        "items": _cart.items.map((c) => {
          "id": c.id,
          "title": c.title,
          "image": c.image,
          "regularPrice": c.price.toInt(),   // <-- matches Postman
          "price": c.price.toInt(),
          "color": "",
          "customise": "",
          "TotalQuantity": c.quantity.value,
          "SelectedSizes": {},
          "weight": 11,
          "stock": c.stock,
          "pid": c.pid,
          "quantity": c.quantity.value,
        }).toList(),

        // ---- REST OF THE FIELDS (exact order) ----
        "status": "1",
        "mode": "COD",               // you can change to "Razorpay" later
        "details": {
          "username": name,
          "phone": phone,
          "pincode": pincode,
          "state": userData['state'] ?? '',
          "address": address,
          "email": userData['email'] ?? '',
        },
        "discount": 0,
        "shipping": 0,
        "totalAmount": _cart.totalPrice.value.toInt(),
        "primary": false,
        "payment": 0,
        "username": name,
        "email": userData['email'] ?? '',
        "userId": userId,
        "state": userData['state'] ?? '',
        "verified": userData['verified'] ?? 1,
        "longitude": lng.toString(),
        "latitude": lat.toString(),
      };

      // DEBUG – see exact JSON in console / log
      debugPrint('=== ORDER PAYLOAD ===\n${jsonEncode(payload)}');

      final response = await _api.createOrder(userId, payload);

      if (response['success'] == true) {
        // 1. Clear cart first (so UI updates instantly)
        _cart.clearCart();

        // 2. Show the pretty dialog
        await Get.dialog(
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2027),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Order Placed Successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your COD order has been confirmed.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();               // close dialog
                        Get.back();               // close checkout screen

                        // go to cart page
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );

        return true;
      } else {
        Get.snackbar('Failed', response['message'] ?? 'Try again',
            backgroundColor: Colors.red);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading(false);
    }
  }
}