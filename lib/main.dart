import 'package:dharma_app/controllers/cart_controller.dart';
import 'package:dharma_app/controllers/category_controller.dart';
import 'package:dharma_app/controllers/checkout_controller.dart';
import 'package:dharma_app/controllers/friendss_controller.dart';
import 'package:dharma_app/controllers/language_controller.dart';
import 'package:dharma_app/controllers/order_controller.dart';
import 'package:dharma_app/controllers/product_controller.dart';
import 'package:dharma_app/controllers/theme_controller.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:dharma_app/services/notificationervice.dart';
import 'package:dharma_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'controllers/home_controller.dart';
import 'controllers/usercontroller.dart';
import 'package:flutter_avif/flutter_avif.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // 🔹 FIRST: Initialize FCM & Save Token
  await NotificationService.initializeFCM();  // Ye abhi token save kar dega

  // ✅ Initialize Theme & Language
  Get.put(ThemeController());
  Get.put(LanguageController());
  Get.put(ApiService());

  final userController = Get.put(UserController());
  Get.put(CartController());
  Get.put(CheckoutController());
  Get.put(OrderController());

  // Initialize controllers
  Get.put(HomeController());
  Get.put(CategoryController());
  Get.put(ProductDetailController());
  Get.put(FriendController());

  await userController.checkLoginStatus();

  // Configure EasyLoading
  MyApp.configLoading();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Reactive theme
      ThemeMode themeMode;
      switch (homeController.selectedTheme.value) {
        case 'light': themeMode = ThemeMode.light; break;
        case 'dark': themeMode = ThemeMode.dark; break;
        default: themeMode = ThemeMode.system;
      }

      // Reactive language
      Locale locale;
      switch (homeController.selectedLanguage.value) {
        case 'hi': locale = Locale('hi', 'IN'); break;
        default: locale = Locale('en', 'US');
      }

      return GetMaterialApp(
        title: 'FitAmigo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(0xFF0F2027),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
        fallbackLocale: Locale('en', 'US'),
        home: SplashScreen(),
        builder: EasyLoading.init(),
      );
    });
  }

  // EasyLoading config
  static void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = Colors.black.withOpacity(0.7)
      ..indicatorColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }
}