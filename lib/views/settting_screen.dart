import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/usercontroller.dart';


class SettingsScreen extends StatelessWidget {
  final UserController userController = Get.find();
  final HomeController homeController = Get.find();
  final ThemeController themeController = Get.find();
  final LanguageController languageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Card(
              color: Colors.black.withOpacity(0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),

                    // 🔹 Theme Section
                    _buildThemeSection(),

                    SizedBox(height: 24),

                    // 🔹 Language Section
                    _buildLanguageSection(),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Obx(() {
      String currentTheme = homeController.selectedTheme.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _themeOption('Light', currentTheme == 'light', () {
                homeController.changeTheme('light');
              }),
              _themeOption('Dark', currentTheme == 'dark', () {
                homeController.changeTheme('dark');
              }),
              _themeOption('System', currentTheme == 'system', () {
                homeController.changeTheme('system');
              }),
            ],
          ),
        ],
      );
    });
  }

  Widget _themeOption(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? Colors.lightBlueAccent.withOpacity(0.6) : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.lightBlueAccent : Colors.white24),
        ),
        child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Obx(() {
      String currentLang = homeController.selectedLanguage.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Language', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _languageOption('English', currentLang == 'en', () {
                homeController.changeLanguage('en');
              }),
              _languageOption('Hindi', currentLang == 'hi', () {
                homeController.changeLanguage('hi');
              }),
            ],
          ),
        ],
      );
    });
  }

  Widget _languageOption(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? Colors.lightBlueAccent.withOpacity(0.6) : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.lightBlueAccent : Colors.white24),
        ),
        child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}