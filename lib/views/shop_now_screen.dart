import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'category_detail_screen.dart';

class ShopAllScreen extends StatefulWidget {
  @override
  State<ShopAllScreen> createState() => _ShopAllScreenState();
}

class _ShopAllScreenState extends State<ShopAllScreen> {
  final HomeController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategoryProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= PREMIUM PURPLE APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Find Today’s Pick",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.deepPurple,
          ),
        ),
      ),

      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: Colors.deepPurple,
            onRefresh: controller.fetchCategoryProducts,
            child: controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _buildCategoryList(),
          );
        }),
      ),
    );
  }

  // ================= LIST LAYOUT =================
  Widget _buildCategoryList() {
    final categories = controller.categories.value.categoriesWithProducts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: List.generate(categories.length, (index) {
            return _categoryCard(categories[index]);
          }),
        ),
      ),
    );
  }

  // ================= SINGLE CATEGORY CARD =================
  Widget _categoryCard(category) {
    final size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 380;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => CategoryDetailScreen(slug: category.slug),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

            return SlideTransition(position: offset, child: child);
          },
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        curve: Curves.easeOut,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(.08),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.deepPurple.withOpacity(.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(.10),
              blurRadius: 14,
              offset: Offset(0, 6),
            )
          ],
        ),

        child: Row(
          children: [

            // ================= CATEGORY IMAGE =================
            Container(
              width: isSmall ? 80 : 90,
              height: isSmall ? 80 : 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.30),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: CachedNetworkImage(
                  imageUrl: category.image ?? "",
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ================= TEXT + BUTTON =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title ?? "",
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Explore best picks for today",
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 13,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Explore",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isSmall ? 12 : 14,
                              color: Colors.deepPurple,
                            )),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios,
                            size: isSmall ? 12 : 14, color: Colors.deepPurple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
