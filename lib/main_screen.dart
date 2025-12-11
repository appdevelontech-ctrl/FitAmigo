import 'dart:ui';
import 'package:dharma_app/services/api_service.dart';
import 'package:dharma_app/views/cart_screen.dart';
import 'package:dharma_app/views/dashboard_screen.dart';
import 'package:dharma_app/views/findfriends.dart';
import 'package:dharma_app/views/friends_screen.dart';
import 'package:dharma_app/views/login_screen.dart';
import 'package:dharma_app/views/order_list_screen.dart';
import 'package:dharma_app/views/privacy_policy.dart';
import 'package:dharma_app/views/profile_screen.dart';
import 'package:dharma_app/views/tearms%20condition.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/friendss_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/usercontroller.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final HomeController homeController = Get.find();
  final UserController userController = Get.find();
  final FriendController friendController = Get.put(FriendController());

  late List<Widget> _screens;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final RxBool _isLoadingTab = false.obs;

  @override
  void initState() {
    super.initState();

    Get.put(CartController(), permanent: true);
    Get.put(OrderController(), permanent: true);

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _screens = [
      DashboardScreen(),
      OrdersListScreen(),
      FriendsScreen(),
      CartScreen(),
    ];

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await userController.checkLoginStatus();
    if (!userController.isLoggedIn.value) {
      Get.offAll(() => LoginScreen());
    } else {
      _loadTab(0);
    }
  }

  Future<void> _loadTab(int index) async {
    _isLoadingTab.value = true;

    try {
      switch (index) {
        case 0:
          await homeController.fetchAllData();
          break;
        case 1:
          final uid = await Get.find<ApiService>().getUserId();
          if (uid != null) await Get.find<OrderController>().fetchUserOrders(uid);
          break;
        case 2:
          await friendController.fetchAllData();
          break;
      }
    } catch (e) {
      print("Error loading tab $index: $e");
    }

    _isLoadingTab.value = false;
    setState(() => _selectedIndex = index);
    _animationController.forward(from: 0.0);
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Main Content Area
          Positioned.fill(
            top: 90,
            bottom: 85,
            child: Obx(() => _isLoadingTab.value
                ? Center(child: CupertinoActivityIndicator(radius: 16))
                : FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: _screens[_selectedIndex],
                key: ValueKey<int>(_selectedIndex),
              ),
            )),
          ),

          // AppBar
          _buildModernAppBar(),

          // Floating Bottom Nav
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

// ==================== MODERN PURPLE APPBAR ====================
  Widget _buildModernAppBar() {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 350;
    final isMedium = size.width >= 350 && size.width < 600;
    final isLarge = size.width >= 600;

    double titleSize = isSmall ? 18 : isMedium ? 22 : 28;
    double iconSize = isSmall ? 18 : 22;
    double padding = isSmall ? 8 : 10;
    double height = isSmall ? 110 : isMedium ? 130 : 150;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: height,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 6,
              left: 16,
              right: 16,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.12),
                  blurRadius: 25,
                  offset: Offset(0, 8),
                )
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ================= LEFT SIDE =================
                Row(
                  children: [
                    // Drawer Button
                    GestureDetector(
                      onTap: _openDrawer,
                      child: Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.menu,
                            size: iconSize, color: Colors.deepPurple),
                      ),
                    ),

                    SizedBox(width: isSmall ? 8 : 12),

                    Text(
                      "FitAmigo",
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                // ================= RIGHT SIDE =================
                Row(
                  children: [
                    // Search button
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 350),
                          pageBuilder: (_, __, ___) => FindFriendFilterScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                            return SlideTransition(position: offset, child: child);
                          },
                        ));

                      },
                      child: Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search,
                            size: iconSize, color: Colors.deepPurple),
                      ),
                    ),

                    SizedBox(width: isSmall ? 8 : 12),

                    // Location
                    Obx(() {
                      final locations = homeController.zones.value.uniqueLocations;

                      return GestureDetector(
                        onTap: () => _showLocationSheet(locations),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 10 : 14,
                              vertical: isSmall ? 6 : 9),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: iconSize - 4,
                                  color: Colors.deepPurple),
                              SizedBox(width: 6),
                              Text(
                                homeController.selectedLocation.value.isEmpty
                                    ? "Select"
                                    : homeController.selectedLocation.value,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showLocationSheet(List<String> locations) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Location", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Divider(thickness: 1),
            SizedBox(height: 10),
            ...locations.map((loc) => ListTile(
              title: Text(loc, style: TextStyle(fontSize: 16)),
              onTap: () {
                homeController.changeLocation(loc);
                homeController.selectedLocation.value = loc;
                Get.back();
              },
            )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ==================== FLOATING PURPLE BOTTOM NAV ====================
  Widget _buildFloatingNavBar() {
    final CartController cart = Get.find<CartController>();

    return Positioned(
      bottom: 18,
      left: 16,
      right: 16,
      child: Material(
        elevation: 14,
        borderRadius: BorderRadius.circular(30),
        shadowColor: Colors.deepPurple.withOpacity(0.25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.deepPurple.withOpacity(0.15)),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,

            // 💜 Purple selection
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey.shade600,
            selectedFontSize: 13,
            unselectedFontSize: 12,
            elevation: 0,

            onTap: _loadTab,

            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),

              BottomNavigationBarItem(
                icon: Obx(() => Badge(
                  backgroundColor: Colors.deepPurple,       // 💜 Purple Badge
                  isLabelVisible: friendController.totalUnread.value > 0,
                  label: Text(
                    friendController.totalUnread.value.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(Icons.chat_bubble_rounded),
                )),
                label: 'Chats',
              ),

              BottomNavigationBarItem(
                icon: Obx(() => Badge(
                  backgroundColor: Colors.deepPurple,        // 💜 Purple Cart Badge
                  isLabelVisible: cart.itemCount > 0,
                  label: Text(
                    cart.itemCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(Icons.shopping_cart_rounded),
                )),
                label: 'Cart',
              ),
            ],
          ),
        ),
      ),
    );
  }


// ==================== DRAWER ====================
  Widget _buildDrawer() {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width * 0.78, // Responsive drawer width
      child: SafeArea(
        child: Column(
          children: [
            // ---- Profile Header ----
            // ---- PREMIUM USER HEADER ----
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.18),
                    Colors.deepPurple.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Profile Image
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.purpleAccent],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 55, color: Colors.deepPurple),
                        ),
                      ),

                      // Small edit button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => Get.to(() => ProfileScreen()),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple,
                            ),
                            child: Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  // Username
                  Obx(() => Text(
                    userController.user.value?.username ?? "Guest User",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  )),

                  SizedBox(height: 5),

                  // Email
                  Obx(() => Text(
                    userController.user.value?.email ?? "guest@example.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )),

                  SizedBox(height: 18),

                  // Small badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🎯 Fitness Member",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  )
                ],
              ),
            ),


            SizedBox(height: 20),

            // ---- Drawer Items ----
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _drawerItem(Icons.home_rounded, "Home", () => _loadTab(0)),
                  _drawerItem(Icons.person_outline, "My Profile", () => Get.to(() => ProfileScreen())),
                  _drawerItem(Icons.shopping_cart_outlined, "My Cart", () => _loadTab(3)),
                  _drawerItem(Icons.privacy_tip_outlined, "Privacy Policy", () => Get.to(() => PrivacyPolicyScreen())),
                  _drawerItem(Icons.description_outlined, "Terms & Conditions", () => Get.to(() => TermsConditionsScreen())),
                ],
              ),
            ),

            // ---- Logout ----
            Divider(),
            _drawerItem(Icons.logout, "Logout", () => _showLogoutDialog(), isRed: true),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

// ==================== Drawer Item Widget ====================
  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {bool isRed = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // highlight background on hover/tap
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: isRed ? Colors.red : Colors.deepPurple),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isRed ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }


  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, size: 60, color: Colors.redAccent),
              SizedBox(height: 16),
              Text("Logout?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Are you sure you want to log out?", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Get.back();
                        userController.logout();
                        Get.offAll(() => LoginScreen());
                      },
                      child: Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}