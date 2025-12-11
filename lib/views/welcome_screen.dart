import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E0F00), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_run, size: 100, color: Colors.greenAccent),

            const SizedBox(height: 40),

            const Text(
              "Set Your",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Fitness Goals",
              style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text(
              "We created to bring together fitness enthusiasts\nwho want to find partner, and get fit together!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 45),

            buildButton("Log in", Colors.greenAccent, Colors.black, () => Get.to(() => LoginScreen())),
            const SizedBox(height: 15),
            buildButton("Sign-up", Colors.grey.shade700, Colors.white, () {}),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, Color bg, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
        child: Center(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
