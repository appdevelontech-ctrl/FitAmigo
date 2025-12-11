import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  final RxBool isLoading = true.obs;
  final RxList gyms = [].obs;

  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _initLocationAndFetchGyms();

  }
  Future<void> _initLocationAndFetchGyms() async {
    try {
      print("\n📍 Checking Permission...");

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        print("❌ Permission still denied");
        return;
      }

      print("📍 Getting location...");
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLat = pos.latitude;
      userLng = pos.longitude;

      print("✔ GOT LOCATION: LAT = $userLat | LNG = $userLng");

      await _fetchGyms();

    } catch (e) {
      print("❌ Location Error: $e");
    }
  }Future<void> _fetchGyms() async {
    if (userLat == null || userLng == null) {
      print("❌ ERROR: Lat/Lng missing");
      return;
    }

    isLoading.value = true;

    try {
      final api = ApiService();

      // Load department safely
      final deps = await api.getDepartments();

      if (deps.isEmpty) {
        print("❌ No department returned!");
        gyms.value = [];
        return;
      }

      final departmentId = deps.first.id;

      // Call nearby API
      final result = await api.getNearbyGyms(
        lat: userLat!,
        lng: userLng!,
        departmentId: departmentId,
      );

      print("\n🟣 RAW API RESULT:");
      print(const JsonEncoder.withIndent("  ").convert(result));

      final friends = result["friends"];

      if (friends == null) {
        print("⚠ Backend returned NULL for friends");
        gyms.value = [];
      } else {
        gyms.value = List.from(friends);
      }

    } catch (e) {
      print("❌ API Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("Nearby Gyms", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          padding: const EdgeInsets.only(left: 20),
        ),

      ),

      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          );
        }

        if (gyms.isEmpty) {
          return Center(child: Text("No gyms found near you 😔"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: gyms.length,
          itemBuilder: (_, i) {
            final gym = gyms[i];
            return _gymCard(gym);
          },
        );
      }),
    );
  }

  Widget _gymCard(dynamic gym) {
    final String title = gym["username"] ?? "";
    final String address = gym["address"] ?? "";
    final List images = gym["images"] ?? [];
    final List features = gym["features"] ?? [];
    final List offers = gym["offers"] ?? [];
    final List faqs = gym["faqs"] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE SLIDER
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87)),

                SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.deepPurple, size: 18),
                    SizedBox(width: 6),
                    Expanded(child: Text(address, style: TextStyle(fontSize: 14, color: Colors.black54))),
                  ],
                ),

                SizedBox(height: 14),

                if (features.isNotEmpty)
                  _sectionHeading("Features"),
                if (features.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children:
                    features.map((f) => _chip(f["text"])).toList(),
                  ),

                SizedBox(height: 14),

                if (offers.isNotEmpty)
                  _sectionHeading("Offers"),
                if (offers.isNotEmpty)
                  ...offers.map((offer) => _offerBox(offer)),

                SizedBox(height: 14),

                if (faqs.isNotEmpty) _sectionHeading("FAQs"),
                if (faqs.isNotEmpty) ...faqs.map((faq) => _faqTile(faq)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple)),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(text, style: TextStyle(fontSize: 13)),
    );
  }

  Widget _offerBox(dynamic offer) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.deepPurple),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "${offer["salePrice"]} / ${offer["saleUnit"]} ${offer["extraText"]}",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _faqTile(dynamic faq) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(faq["question"],
          style: TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(faq["answer"], style: TextStyle(color: Colors.black87)),
        )
      ],
    );
  }
}
