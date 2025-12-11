import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  Rx<Locale> locale = Locale('en', 'US').obs;

  void changeLanguage(String langCode, String countryCode) {
    locale.value = Locale(langCode, countryCode);
    Get.updateLocale(locale.value); // Apply locale globally
  }
}