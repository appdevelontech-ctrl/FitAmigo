import 'package:dharma_app/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/usercontroller.dart';
import '../main_screen.dart';
import '../services/storage_service.dart';
import '../views/onboarding_screen.dart';
import '../views/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _routeCheck();
  }

  Future<void> _routeCheck() async {
    bool isFirst = await StorageService.isFirstLaunch();
    await userController.checkLoginStatus();

    Timer(const Duration(seconds: 2), () {
      if (isFirst) {
        Get.offAll(() => OnboardingScreen());
      } else if (userController.isLoggedIn.value) {
        Get.offAll(() => MainScreen());
      } else {
        Get.offAll(() => WelcomeScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fitness_girl.jpg"), // <-- Yaha aapki image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_gymnastics, color: Colors.white, size: 100),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 10),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
