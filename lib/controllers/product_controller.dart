// lib/controllers/product_detail_controller.dart
import 'package:get/get.dart';
import '../models/product_detail_model.dart';

import '../models/product_rating.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class ProductDetailController extends GetxController {
  final ApiService api = ApiService();

  var productDetail = Rxn<ProductDetailModel>();
  var ratings = RxList<Rating>([]);
  var isLoading = false.obs;

  Future<void> fetchProduct(String slug) async {
    isLoading(true);
    try {
      productDetail.value = await api.getProductBySlug(slug);
      // optionally fetch ratings
      if (productDetail.value?.product?.id != null) {
        final ratingRes =
        await api.getProductRatings(productDetail.value!.product!.id);
        ratings.assignAll(ratingRes.productRatings);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product: $e',
          backgroundColor: Colors.black54);
    } finally {
      isLoading(false);
    }
  }
}