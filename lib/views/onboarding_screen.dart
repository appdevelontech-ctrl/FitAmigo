import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/slide1.png",
      "text": "Find a club to start your\nFitness Journey"
    },
    {
      "image": "assets/images/slide2.png",
      "text": "Not just gym but we have\nmore"
    },
    {
      "image": "assets/images/slide3.png",
      "text": "Find Perfect\nFitness Partner"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemCount: onboardingData.length,
            itemBuilder: (_, index) {
              return Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.asset(
                      onboardingData[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient and text
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 120,
                    child: Text(
                      onboardingData[index]["text"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => _controller.jumpToPage(2),
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Indicators and Buttons
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dot indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 8,
                      width: currentPage == index ? 25 : 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Colors.greenAccent
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                currentPage == onboardingData.length - 1
                    ? SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      await StorageService.markOnboardingDone();
                      Get.offAll(() => WelcomeScreen());
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: currentPage == 0
                            ? Colors.grey
                            : Colors.white,
                      ),
                      onPressed: currentPage == 0
                          ? null
                          : () {
                        _controller.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),
                    const SizedBox(width: 25),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
