// lib/controllers/category_controller.dart
import 'package:get/get.dart';

import '../models/category_detail_model.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';


class CategoryController extends GetxController {
  var categoryDetail = CategoryDetailModel(
    message: '',
    success: false,
    categories: [],
  ).obs;
  var isLoading = false.obs;

  final ApiService apiService = ApiService();

  Future<void> fetchCategoryDetail(String? slug, {String? location = 'delhi'}) async {
    if (slug == null || slug.isEmpty) {
      Get.snackbar('Error', 'Invalid category slug', backgroundColor: Colors.black54);
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      categoryDetail.value = await apiService.getCategoryDetail(slug, location: location ?? 'delhi');
    } catch (e) {
      categoryDetail.value = CategoryDetailModel(
        message: 'Failed to load: $e',
        success: false,
        categories: [],
      );
      Get.snackbar('Error', 'Failed to load category detail: $e', backgroundColor: Colors.black54);
    } finally {
      isLoading.value = false;
    }
  }
}