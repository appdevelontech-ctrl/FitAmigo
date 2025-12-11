import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../main_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductDetailController());
    _load();
  }

  Future<void> _load() async {
    EasyLoading.show(status: "Loading...");
    await controller.fetchProduct(widget.slug);
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== PREMIUM PURPLE APPBAR =====================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Product Detail",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.deepPurple,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CupertinoActivityIndicator(
                radius: 18,
                color: Colors.deepPurple,
              ));
        }

        final product = controller.productDetail.value?.product;
        if (product == null) {
          return const Center(
              child: Text("Product Not Found",
                  style: TextStyle(fontSize: 18)));
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _images(product),
            _titlePricing(product),
            _stockInfo(product),
            _divider(),

            if (product.metaDescription.trim().isNotEmpty)
              _section(
                title: "Description",
                child: ReadMoreText(
                  product.metaDescription,
                  trimLines: 3,
                  trimCollapsedText: " Read More",
                  trimExpandedText: " Show Less",
                  style: const TextStyle(fontSize: 15),
                  moreStyle: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            if (product.specifications.isNotEmpty)
              _section(
                title: "Specifications",
                child: _specList(product.specifications),
              ),

            if (product.features.isNotEmpty)
              _section(
                title: "Features",
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: product.features.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text("• $f",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      );
                    }).toList()),
              ),

            if (product.coverageCities.isNotEmpty)
              _section(
                title: "Available In",
                child: Wrap(
                  spacing: 8,
                  children: product.coverageCities.map((city) {
                    return Chip(
                      backgroundColor: Colors.deepPurple.withOpacity(.12),
                      label: Text(
                        city,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      }),

      // ===================== BOTTOM BUTTON =====================
      bottomNavigationBar: Obx(() {
        final product = controller.productDetail.value?.product;
        if (product == null) return const SizedBox();
        final inCart = cartCtrl.items.any((i) => i.id == product.id);
        final isOut = product.stock <= 0;

        return Container(
          height: 75,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
            ],
          ),

          child: ElevatedButton(
            onPressed: isOut
                ? null
                : inCart
                ? null
                : () {
              cartCtrl.addProduct(product);
              HapticFeedback.mediumImpact();

              Get.snackbar(
                "Added to Cart",
                product.title,
                backgroundColor: Colors.deepPurple,
                colorText: Colors.white,
              );

              Future.delayed(const Duration(milliseconds: 900), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => MainScreen()),
                      (route) => false,
                );
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor:
              isOut ? Colors.grey : (inCart ? Colors.deepPurple : Colors.deepPurpleAccent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),

            child: Text(
              isOut
                  ? "Out of Stock 🚫"
                  : (inCart ? "Already in Cart ✔" : "Add to Cart"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ===================== IMAGE SLIDER =====================
  Widget _images(product) {
    final List<String> imgs = [product.pImage, ...product.images];

    return CarouselSlider.builder(
      itemCount: imgs.length,
      itemBuilder: (_, i, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: imgs[i],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(
                color: Colors.deepPurple.withOpacity(.08),
                child:
                const Center(child: CupertinoActivityIndicator(color: Colors.deepPurple)),
              ),
              errorWidget: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 60),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 270,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
    );
  }

  // ===================== TITLE + PRICE =====================
  Widget _titlePricing(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 24, height: 1.3)),

            const SizedBox(height: 6),

            Row(children: [
              Text(
                "₹${product.salePrice}",
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              if (product.regularPrice > product.salePrice)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "₹${product.regularPrice}",
                    style: const TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45),
                  ),
                )
            ]),
          ]),
    );
  }

  // ===================== STOCK INFO =====================
  Widget _stockInfo(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
        Icon(
          product.stock > 0 ? Icons.check_circle : Icons.cancel,
          color: product.stock > 0 ? Colors.deepPurple : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          product.stock > 0 ? "In Stock" : "Out of Stock",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: product.stock > 0 ? Colors.deepPurple : Colors.red),
        ),
      ]),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(color: Colors.black.withOpacity(.15)),
  );

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            child,
            const SizedBox(height: 10),
            Divider(color: Colors.black.withOpacity(.15)),
          ]),
    );
  }

  Widget _specList(Map<String, dynamic> specMap) {
    final list = specMap["specifications"] ?? [];

    return Column(
      children: list.map<Widget>((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple.withOpacity(.10),
            border: Border.all(color: Colors.deepPurple.withOpacity(.25)),
          ),
          child: Text(item["heading"] ?? "",
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        );
      }).toList(),
    );
  }
}
