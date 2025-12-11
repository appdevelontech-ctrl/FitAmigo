// lib/views/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ctrl = Get.find<CheckoutController>();
  final cartCtrl = Get.find<CartController>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  double? lat, lng;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyCcppZWLo75ylSQvsR-bTPZLEFEEec5nrY");
    loadUser();
  }

  void loadUser() {
    final user = ctrl.userData;
    nameCtrl.text = user['username'] ?? "";
    phoneCtrl.text = user['phone'] ?? "";
    pincodeCtrl.text = user['pincode'] ?? "";

    addressCtrl.clear();
    lat = null;
    lng = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------- PURPLE APPBAR --------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.purple),
          padding: const EdgeInsets.only(left: 20),
        ),
      ),

      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _section("Customer Details", [
                _input("Name", nameCtrl),
                _input("Phone", phoneCtrl,
                    keyboard: TextInputType.phone),
                addressUI(),
                _input("Pincode", pincodeCtrl),
              ]),

              const SizedBox(height: 16),

              _section("Order Items",
                  cartCtrl.items.map((i) => orderCard(i)).toList()),

              const SizedBox(height: 20),

              // ---------------- TOTAL BOX ----------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.deepPurple.withOpacity(.3), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(
                      "₹${cartCtrl.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- BUTTON ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    if (validate()) {
                      ctrl.placeOrder(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        pincode: pincodeCtrl.text.trim(),
                        lat: lat,
                        lng: lng,
                      );
                    }
                  },
                  child: const Text("Place COD Order",
                      style:
                      TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // -------------------- ADDRESS AUTOCOMPLETE --------------------
  Widget addressUI() {
    return Column(
      children: [
        TextField(
          controller: addressCtrl,
          onChanged: autoCompleteSearch,
          decoration: InputDecoration(
            labelText: "Search Address",
            labelStyle: const TextStyle(color: Colors.deepPurple),
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            focusedBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: Colors.deepPurple.shade400, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),

        if (predictions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: Colors.deepPurple.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (_, i) {
                final p = predictions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on,
                      color: Colors.deepPurple),
                  title: Text(p.description ?? "",
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => getPlaceDetail(p.placeId!),
                );
              },
            ),
          )
      ],
    );
  }

  // -------------------- SECTION BOX --------------------
  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.deepPurple.withOpacity(.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          const SizedBox(height: 12),
          ...children
        ],
      ),
    );
  }

  // -------------------- ORDER ITEM CARD --------------------
  Widget orderCard(item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.deepPurple.withOpacity(.3), width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(item.image,
                  width: 55, height: 55, fit: BoxFit.cover)),

          const SizedBox(width: 12),

          Expanded(
            child: Text(item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ),

          Text(
            "₹${item.price * item.quantity.value}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          )
        ],
      ),
    );
  }

  // -------------------- TEXT INPUT --------------------
  Widget _input(String label, TextEditingController c, {keyboard}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.deepPurple),
          focusedBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: Colors.deepPurple.shade400, width: 2),
              borderRadius: BorderRadius.circular(12)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // -------------------- VALIDATION --------------------
  void autoCompleteSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() => predictions = []);
      return;
    }

    var result = await googlePlace.autocomplete.get(value);
    setState(() => predictions = result?.predictions ?? []);
  }

  void getPlaceDetail(String id) async {
    var result = await googlePlace.details.get(id);

    setState(() {
      addressCtrl.text = result?.result?.formattedAddress ?? "";
      predictions = [];
      lat = result?.result?.geometry?.location?.lat;
      lng = result?.result?.geometry?.location?.lng;
    });

    if (lat != null) {
      Get.snackbar("Success", "Location Selected",
          backgroundColor: Colors.deepPurple.shade300,
          colorText: Colors.white);
    }
  }

  bool validate() {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty ||
        pincodeCtrl.text.isEmpty) {
      Get.snackbar("Error", "All fields required",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }
    if (lat == null) {
      Get.snackbar("Error", "Select valid location",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }
    return true;
  }
}
