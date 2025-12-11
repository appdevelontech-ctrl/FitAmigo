import 'dart:ui';
import 'package:dharma_app/controllers/theme_controller.dart';
import 'package:dharma_app/controllers/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category_product_model.dart';
import '../models/home_layout_model.dart';
import '../models/zone_model.dart';
import '../services/api_service.dart';
import 'language_controller.dart';

class HomeController extends GetxController {
  var zones = ZoneModel(success: false, uniqueLocations: []).obs;
  var homeLayout = HomeLayoutModel(
    message: '',
    success: false,
    homeLayout: HomeLayoutData(
      id: '',
      topBar: '',
      sliderImg: '',
      latestProductBanner: [],
    ),
  ).obs;

  var categories = CategoryProductModel(
    message: '',
    success: false,
    categoriesWithProducts: [],
  ).obs;

  var filteredCategories = <CategoryWithProducts>[].obs;
  var isLoading = false.obs;
  var selectedLocation = 'Delhi'.obs;

  // Reactive theme and language
  final ThemeController themeController = Get.find();
  final LanguageController languageController = Get.find();
  var selectedTheme = 'system'.obs; // Default to system
  var selectedLanguage = 'en'.obs; // Default to English

  final ApiService apiService = ApiService();

  @override
  void onInit() {
    fetchAllData();
    selectedTheme.value = themeController.themeMode.value == ThemeMode.light
        ? 'light'
        : themeController.themeMode.value == ThemeMode.dark
        ? 'dark'
        : 'system';
    selectedLanguage.value = languageController.locale.value.languageCode;
    super.onInit();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      zones.value = await apiService.getAllZones();
      homeLayout.value = await apiService.getHomeLayoutData();
      final UserController userController = Get.find();
      if (userController.user.value?.statename != null &&
          zones.value.uniqueLocations.contains(userController.user.value!.statename)) {
        selectedLocation.value = userController.user.value!.statename!;
      } else if (zones.value.uniqueLocations.isNotEmpty) {
        selectedLocation.value = zones.value.uniqueLocations.first;
      }
      await fetchCategoryProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeLocation(String location) {
    selectedLocation.value = location;
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    isLoading.value = true;
    try {
      categories.value = await apiService.getCategoryProducts(selectedLocation.value);
      filteredCategories.value = categories.value.categoriesWithProducts;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        backgroundColor: Colors.black.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.value = categories.value.categoriesWithProducts;
    } else {
      filteredCategories.value = categories.value.categoriesWithProducts
          .where((category) => category.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void changeTheme(String theme) {
    selectedTheme.value = theme;
    switch (theme) {
      case 'light':
        themeController.setTheme(ThemeMode.light);
        break;
      case 'dark':
        themeController.setTheme(ThemeMode.dark);
        break;
      case 'system':
        themeController.setTheme(ThemeMode.system);
        break;
    }
  }

  void changeLanguage(String lang) {
    selectedLanguage.value = lang;
    switch (lang) {
      case 'en':
        languageController.changeLanguage('en', 'US');
        break;
      case 'hi':
        languageController.changeLanguage('hi', 'IN');
        break;
    }
  }
}