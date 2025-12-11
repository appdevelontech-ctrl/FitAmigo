// lib/views/findfriend_filter_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcard/tcard.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/friendss_controller.dart';

class FindFriendFilterScreen extends StatefulWidget {
  const FindFriendFilterScreen({Key? key}) : super(key: key);

  @override
  State<FindFriendFilterScreen> createState() => _FindFriendFilterScreenState();
}

class _FindFriendFilterScreenState extends State<FindFriendFilterScreen>
    with SingleTickerProviderStateMixin {
  final FriendController controller = Get.find();
  final TCardController _cardController = TCardController();

  late final AnimationController _animCtrl;
  bool _filtersOpen = true;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.loadLocations();
      controller.loadDepartments();
      controller.loadFilteredFriends(reset: true);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // 🔥 GET GPS LOCATION
  // ---------------------------------------------------------
  Future<void> _getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      Get.snackbar("GPS Disabled", "Turn ON location services.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission needed.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Access Blocked",
          "Enable location permission from app settings.");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    controller.setUserLocation(pos.latitude, pos.longitude);
    setState(() {});
  }

  // ---------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFilterPanel(),
              Expanded(child: _buildSwipeSection()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // APPBAR
  // ---------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        "Discover People",
        style: TextStyle(
            color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 19),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon:
        const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.deepPurple),
      ),
    );
  }

  // ---------------------------------------------------------
  // FILTER PANEL
  // ---------------------------------------------------------
  Widget _buildFilterPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
          ],
        ),
        child: Column(
          children: [
            _buildFilterHeader(),

            if (_filtersOpen) ...[
              const SizedBox(height: 12),
              _buildLocationSelector(),
              const SizedBox(height: 12),
              Obx(() => controller.useGpsLocation.value
                  ? const SizedBox.shrink()
                  : _buildStateCityRow()),
              const SizedBox(height: 10),
              _buildDepartmentRow(),
              const SizedBox(height: 10),
              _buildSubDepartmentRow(),
              const SizedBox(height: 12),
              _buildDistanceSlider(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Refine your search",
            style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _filtersOpen = !_filtersOpen;
            });
          },
          icon: AnimatedRotation(
            turns: _filtersOpen ? 0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.filter_list, color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // LOCATION MODE (GPS / STATE-CITY)
  // ---------------------------------------------------------
  Widget _buildLocationSelector() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _locationModeButton(
              label: "State / City",
              active: !controller.useGpsLocation.value,
              onTap: () {
                controller.useGpsLocation.value = false;
                controller.userLat.value = "";
                controller.userLng.value = "";
                controller.loadFilteredFriends(reset: true);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _locationModeButton(
              label: "Use My Location",
              active: controller.useGpsLocation.value,
              onTap: () => _getCurrentLocation(),
            ),
          ),
        ],
      );
    });
  }

  Widget _locationModeButton({
    required String label,
    required bool active,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.deepPurple : Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                color: active ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // STATE + CITY DROPDOWN
  // ---------------------------------------------------------
  Widget _buildStateCityRow() {
    return Row(
      children: [
        Expanded(
          child: _dropdown(
            hint: "State",
            value: controller.selectedState.value.isEmpty
                ? null
                : controller.selectedState.value,
            items: controller.stateList
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              controller.selectedState.value = v!;
              controller.selectedCity.value =
              controller.cityList.isNotEmpty ? controller.cityList.first : "";
              controller.loadFilteredFriends(reset: true);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdown(
            hint: "City",
            value: controller.selectedCity.value.isEmpty
                ? null
                : controller.selectedCity.value,
            items: controller.cityList
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              controller.selectedCity.value = v!;
              controller.loadFilteredFriends(reset: true);
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DEPARTMENT DROPDOWN
  // ---------------------------------------------------------
  Widget _buildDepartmentRow() {
    return _dropdown(
      hint: "Department",
      value: controller.selectedDepartmentId.value.isEmpty
          ? null
          : controller.selectedDepartmentId.value,
      items: controller.departmentList
          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
          .toList(),
      onChanged: (v) {
        controller.selectedDepartmentId.value = v!;
        controller.loadSubDepartments(v);
        controller.loadFilteredFriends(reset: true);
      },
    );
  }

  // ---------------------------------------------------------
  // SUB-DEPARTMENT DROPDOWN
  // ---------------------------------------------------------
  Widget _buildSubDepartmentRow() {
    return _dropdown(
      hint: "Sub Department",
      value: controller.selectedSubDept.value.isEmpty
          ? null
          : controller.selectedSubDept.value,
      items: controller.subDepartmentList
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) {
        controller.selectedSubDept.value = v!;
        controller.loadFilteredFriends(reset: true);
      },
    );
  }

  // ---------------------------------------------------------
  // DISTANCE SLIDER
  // ---------------------------------------------------------
  Widget _buildDistanceSlider() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distance: ${controller.selectedDistance.value} km",
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Slider(
            value: double.tryParse(controller.selectedDistance.value) ?? 5.0,
            min: 1,
            max: 50,
            divisions: 49,
            label: "${controller.selectedDistance.value} km",
            onChanged: (v) {
              controller.selectedDistance.value = v.toInt().toString();
            },
            onChangeEnd: (v) {
              controller.loadFilteredFriends(reset: true);
            },
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------
  // CLEAR + SEARCH BUTTONS
  // ---------------------------------------------------------
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              controller.useGpsLocation.value = false;

              controller.selectedState.value = "Delhi";
              controller.selectedCity.value = "New Delhi";

              controller.selectedDepartmentId.value = "";
              controller.selectedSubDept.value = "";
              controller.selectedDistance.value = "5";

              controller.loadFilteredFriends(reset: true);
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.deepPurple.shade100)),
            child: const Text("Clear", style: TextStyle(color: Colors.deepPurple)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              controller.loadFilteredFriends(reset: true);
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child:
            const Text("Search", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // COMPACT DROPDOWN
  // ---------------------------------------------------------
  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.black45)),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SWIPE SECTION
  // ---------------------------------------------------------
  Widget _buildSwipeSection() {
    return Obx(() {
      if (controller.isLoading.value && controller.swipeList.isEmpty) {
        return const Center(
            child:
            CircularProgressIndicator(color: Colors.deepPurple));
      }

      if (controller.swipeList.isEmpty) {
        return _emptyState();
      }

      return Column(
        children: [
          Expanded(child: _tCard()),
          const SizedBox(height: 10),
          _swipeButtons(),
        ],
      );
    });
  }

  Widget _tCard() {
    return TCard(
      controller: _cardController,
      lockYAxis: true,
      size: Size(
        Get.width * 0.92,
        Get.height * 0.70,
      ),
      cards: controller.swipeList.map((u) => _userCard(u)).toList(),
      onForward: (i, info) {
        if (i >= controller.swipeList.length - 1) {
          controller.loadFilteredFriends();
        }
      },
    );
  }

  // ---------------------------------------------------------
  // USER CARD
  // ---------------------------------------------------------
  Widget _userCard(u) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          u.profile.isNotEmpty
              ? Image.network(u.profile, fit: BoxFit.cover)
              : Container(color: Colors.grey.shade300),
          Container(color: Colors.black26),
          Positioned(bottom: 0, left: 0, right: 0, child: _userInfo(u)),
        ],
      ),
    );
  }

  Widget _userInfo(u) {
    final requested =
    controller.friendRequests.any((e) => e["_id"] == u.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(u.username,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(u.city, style: const TextStyle(color: Colors.white70)),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: u.subDepartments
                  .map<Widget>((tag) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: requested ? null : () => controller.sendFriendRequest(u.id),

            style: ElevatedButton.styleFrom(
              backgroundColor: requested ? Colors.grey : Colors.deepPurple,
              foregroundColor: Colors.white,          // ⭐ FORCE WHITE TEXT
              disabledForegroundColor: Colors.white,   // ⭐ TEXT IN DISABLED STATE
              disabledBackgroundColor: Colors.grey,    // ⭐ BACKGROUND WHEN DISABLED
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),

            child: Text(
              requested ? "Requested" : "Send Request",
              style: const TextStyle(color: Colors.white), // EXTRA SAFETY
            ),
          ),
        ),

        ]),
    );
  }

  // ---------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 65, color: Colors.deepPurple.shade100),
          const SizedBox(height: 12),
          const Text("No matches found",
              style: TextStyle(fontSize: 17, color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SWIPE BUTTONS
  // ---------------------------------------------------------
  Widget _swipeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _swipeButton(Icons.close, Colors.redAccent, SwipDirection.Left),
        const SizedBox(width: 36),
        _swipeButton(Icons.favorite, Colors.deepPurple, SwipDirection.Right),
      ],
    );
  }

  Widget _swipeButton(IconData icon, Color color, SwipDirection direction) {
    return GestureDetector(
      onTap: () {
        final i = _cardController.index;
        if (icon == Icons.favorite && i < controller.swipeList.length) {
          controller.sendFriendRequest(controller.swipeList[i].id);
        }
        _cardController.forward(direction: direction);
      },
      child: CircleAvatar(
        radius: 34,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
}
