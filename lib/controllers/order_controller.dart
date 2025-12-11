// lib/controllers/order_controller.dart
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart ';

class OrderController extends GetxController {
  final ApiService api = ApiService();

  var ordersResponse = Rxn<UserOrdersResponse>();
  var orderDetail = Rxn<OrderDetailResponse>();
  var isLoading = false.obs;

  // Fetch all orders
  Future<void> fetchUserOrders(String userId) async {
    isLoading(true);
    try {
      ordersResponse.value = await api.getUserOrders(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e',
          backgroundColor: Colors.black54);
    } finally {
      isLoading(false);
    }
  }

  // Fetch single order detail
  Future<void> fetchOrderDetail(String userId, String orderId) async {
    isLoading(true);
    try {
      orderDetail.value = await api.getOrderDetail(userId, orderId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order detail: $e',
          backgroundColor: Colors.black54);
    } finally {
      isLoading(false);
    }
  }
}