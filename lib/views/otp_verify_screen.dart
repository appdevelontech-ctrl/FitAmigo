import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/usercontroller.dart';
import '../main_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  OtpVerifyScreen({required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final UserController userController = Get.find<UserController>();
  final List<TextEditingController> otpControllers =
  List.generate(4, (_) => TextEditingController());

  int resendSeconds = 30;
  bool canResend = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    resendSeconds = 30;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (resendSeconds == 0) {
        setState(() => canResend = true);
        t.cancel();
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    otpControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// ---- BACKGROUND ----
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55),
                BlendMode.darken,
              ),
              child: Image.asset(
                "assets/images/slide1.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ---- MAIN UI ----
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.16),

                    /// TITLE
                    Text(
                      "Verify OTP 🔐",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Enter the verification code sent to",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),

                    Text(
                      widget.phone,
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    /// ⭐⭐ DISPLAY TESTING OTP HERE ⭐⭐
                    Obx(() {
                      if (userController.plainOtp.value.isNotEmpty) {
                        return Column(
                          children: [
                            Text(
                              "Testing OTP: ${userController.plainOtp.value}",
                              style: TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }
                      return SizedBox();
                    }),

                    SizedBox(height: 30),

                    /// OTP BOXES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: TextField(
                              controller: otpControllers[index],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.deepPurple.withOpacity(0.25),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 40),

                    /// VERIFY BUTTON
                    Obx(() => userController.isLoading.value
                        ? CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    )
                        : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          String otp = otpControllers
                              .map((e) => e.text)
                              .join();

                          if (otp.length != 4) {
                            Get.snackbar(
                              "Error",
                              "Enter valid OTP",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await userController.verifyOtp(otp);

                          if (userController.user.value != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MainScreen()),
                                  (route) => false,
                            );
                          }
                        },
                        child: Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),

                    SizedBox(height: 20),

                    /// RESEND OTP
                    canResend
                        ? GestureDetector(
                      onTap: () async {
                        await userController.loginWithOtp(widget.phone);
                        startTimer();

                        Get.snackbar(
                          "OTP Sent",
                          "A new OTP has been sent!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.deepPurple,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                        : Text(
                      "Resend in $resendSeconds sec",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 15),
                    ),

                    SizedBox(height: 40),
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
