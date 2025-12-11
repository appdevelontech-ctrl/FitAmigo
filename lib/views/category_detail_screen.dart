// 📄 lib/screens/category_detail_screen.dart
import 'package:dharma_app/views/product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../controllers/category_controller.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String? slug;
  final String? location;

  const CategoryDetailScreen({Key? key, this.slug, this.location = 'delhi'})
      : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late final CategoryController controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CategoryController());
    _loadData();
  }

  Future<void> _loadData() async {
    if (_initialized) return;
    _initialized = true;

    try {
      EasyLoading.show(status: "Loading...");
      await controller.fetchCategoryDetail(
        widget.slug ?? "",
        location: widget.location ?? "delhi",
      );
    } finally {
      EasyLoading.dismiss();
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    await controller.fetchCategoryDetail(
      widget.slug ?? "",
      location: widget.location ?? "delhi",
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.slug ?? "").replaceAll("-", " ").capitalize ?? "Category";

    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== PREMIUM PURPLE APPBAR =====================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CupertinoActivityIndicator(
                radius: 18,
                color: Colors.deepPurple,
              ));
        }

        final category = controller.categoryDetail.value.categories.isNotEmpty
            ? controller.categoryDetail.value.categories.first
            : null;

        if (category == null) {
          return Center(child: Text("No products available"));
        }

        return RefreshIndicator(
          color: Colors.deepPurple,
          onRefresh: _refresh,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 40),

            children: [
              SizedBox(height: 16),

              // ===================== CATEGORY BANNER =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: category.image ?? "",
                    height: 210,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 210,
                      color: Colors.deepPurple.withOpacity(0.08),
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        Container(height: 210, color: Colors.grey.shade200),
                  ),
                ),
              ),

              SizedBox(height: 18),

              // ===================== TITLE =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 6),

              // ===================== RESULT COUNT =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "${category.products.length} items available",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ===================== PRODUCT LIST =====================
              ...category.products.map((product) => _productCard(product)),
            ],
          ),
        );
      }),
    );
  }

  // ===================== PRODUCT CARD =====================
  Widget _productCard(dynamic product) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => ProductDetailScreen(slug: product.slug),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

            return SlideTransition(position: offset, child: child);
          },
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: Colors.deepPurple.withOpacity(.15)),
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
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: CachedNetworkImage(
                imageUrl: product.pImage ?? "",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.deepPurple.withOpacity(.08),
                  child: Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.deepPurple,
                      )),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),

            // TEXT DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title ?? "No name",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "₹${product.salePrice}",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (product.regularPrice != null &&
                            product.regularPrice > product.salePrice)
                          Text(
                            "₹${product.regularPrice}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                CupertinoIcons.chevron_forward,
                color: Colors.deepPurple,
              ),
            )
          ],
        ),
      ),
    );
  }
}
