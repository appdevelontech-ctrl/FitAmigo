import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/usercontroller.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.find<UserController>();

  final TextEditingController username = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController about = TextEditingController();

  File? selectedImage;

  @override
  void initState() {
    super.initState();

    final user = userController.user.value;
    username.text = user?.username ?? "";
    phone.text = user?.phone ?? "";
    email.text = user?.email ?? "";
    address.text = user?.address ?? "";
    pincode.text = user?.pincode ?? "";
    city.text = user?.city ?? "";
    about.text = user?.about ?? "";
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => selectedImage = File(img.path));

      final bytes = await selectedImage!.readAsBytes();
      userController.uploadedImageBase64.value = base64Encode(bytes);

      Get.snackbar(
        "Image Added",
        "Ready for update",
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your Profile",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: Obx(() {
        final user = userController.user.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [

              /// --- DP + Name ---
              GestureDetector(
                onTap: pickImage,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.purpleAccent,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 62,
                        backgroundColor: Colors.white,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : user?.profile != null && user!.profile!.isNotEmpty
                            ? NetworkImage(user.profile!) as ImageProvider
                            : null,
                        child: (selectedImage == null && (user?.profile == null || user!.profile!.isEmpty))
                            ? Icon(Icons.person, size: 55, color: Colors.deepPurple)
                            : null,
                      ),
                    ),

                    SizedBox(height: 14),

                    Text(
                      username.text,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              /// ---- Personal Info ----
              _cardContainer(
                child: Column(
                  children: [
                    _buildField(username, "Full Name", icon: Icons.person),
                    _buildField(phone, "Phone Number", icon: Icons.phone),
                    _buildField(email, "Email", icon: Icons.email),
                  ],
                ),
              ),

              SizedBox(height: 16),

              /// ---- Address Info ----
              _cardContainer(
                child: Column(
                  children: [
                    _buildField(city, "City", icon: Icons.location_city),
                    _buildField(pincode, "Pincode", icon: Icons.numbers),
                    _buildField(address, "Address", icon: Icons.home, maxLines: 2),
                  ],
                ),
              ),

              SizedBox(height: 16),

              /// ---- About ----
              _cardContainer(
                child: _buildField(
                  about,
                  "About Me",
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
              ),

              SizedBox(height: 25),

              /// --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: userController.isLoading.value
                      ? null
                      : () {
                    userController.updateProfile(
                      username: username.text.trim(),
                      phone: phone.text.trim(),
                      email: email.text.trim(),
                      pincode: pincode.text.trim(),
                      address: address.text.trim(),
                      city: city.text.trim(),
                      about: about.text.trim(),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: userController.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {int maxLines = 1, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          labelStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.deepPurple.withOpacity(0.08),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 12,
            color: Colors.deepPurple.withOpacity(0.12),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
