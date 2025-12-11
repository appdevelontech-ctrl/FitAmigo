import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/usercontroller.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [

          /// ===== BACKGROUND IMAGE + DARK OVERLAY =====
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55),
                BlendMode.darken,
              ),
              child: Image.asset(
                "assets/images/login.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ===== LOGIN UI =====
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.18),

                    /// -------- TITLE --------
                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 8),
                    Text(
                      "Login to continue your fitness journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 40),

                    /// ---------- LOGIN BOX ----------
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.deepPurpleAccent.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.20),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          /// Phone Input
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(
                                Icons.phone_rounded,
                                color: Colors.deepPurpleAccent,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white24,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                            ),
                          ),

                          SizedBox(height: 25),

                          /// Send OTP Button
                          Obx(
                                () => userController.isLoading.value
                                ? CircularProgressIndicator(
                              color: Colors.deepPurpleAccent,
                            )
                                : SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (phoneController.text.isEmpty) {
                                    Get.snackbar("Error", "Please enter phone number",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  await userController.loginWithOtp(
                                    phoneController.text,
                                  );

                                  if (userController.hashOtp.value.isNotEmpty) {

                                    /// For New User
                                    if (userController.isNewUser.value) {
                                      await userController.loginWithOtp(phoneController.text);

                                      Get.snackbar(
                                        "Account Created 🎉",
                                        "We created your account and sent OTP again!",
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.deepPurple,
                                        colorText: Colors.white,
                                      );
                                    }

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OtpVerifyScreen(phone: phoneController.text),
                                      ),
                                          (route) => false,
                                    );
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Failed to send OTP. Try again.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 35),

                    /// FOOTER
                    Text(
                      "💪 Fit Together, Grow Stronger.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
