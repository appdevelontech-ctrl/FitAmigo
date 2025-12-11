import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'Checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ---------------- CART LIST ----------------
          SafeArea(
            child: Obx(() {
              if (cartCtrl.items.isEmpty) {
                return _buildEmptyCart();
              }

              return RefreshIndicator(
                onRefresh: () async {},
                color: Colors.deepPurple,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 140),
                  itemCount: cartCtrl.items.length,
                  itemBuilder: (_, i) =>
                      _buildCartItem(cartCtrl.items[i], cartCtrl),
                ),
              );
            }),
          ),

          // ---------------- CHECKOUT BAR ----------------
          Obx(() => cartCtrl.items.isNotEmpty
              ? Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: Colors.deepPurple.withOpacity(.25), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),

                      Obx(() => Text(
                        '₹${cartCtrl.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: () =>
                        Get.to(() => const CheckoutScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          )
              : const SizedBox()),
        ],
      ),
    );
  }

  // ---------------- EMPTY CART ----------------
  Widget _buildEmptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.cart_fill,
            size: 90, color: Colors.deepPurple.shade300),
        const SizedBox(height: 18),
        const Text('Your cart is empty',
            style: TextStyle(color: Colors.black87, fontSize: 20)),
        const SizedBox(height: 8),
        const Text('Add items to get started',
            style: TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    ),
  );

  // ---------------- CART ITEM CARD ----------------
  Widget _buildCartItem(CartItem item, CartController ctrl) {
    bool isSmall = MediaQuery.of(Get.context!).size.width < 380;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmall ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: Colors.deepPurple.withOpacity(.25), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withOpacity(.12),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),

      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: item.image,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
              const CupertinoActivityIndicator(color: Colors.deepPurple),
              errorWidget: (_, __, ___) =>
              const Icon(Icons.error, color: Colors.red),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: isSmall ? 15 : 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 4),

                Text('₹${item.price.toStringAsFixed(0)} each',
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 13)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Text('Qty: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Obx(() => Text("${item.quantity.value}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                    const Spacer(),

                    Obx(() => Text(
                      '₹${(item.price * item.quantity.value).toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    )),
                  ],
                )
              ],
            ),
          ),

          // Quantity Buttons
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.deepPurple),
                    onPressed: () =>
                        ctrl.updateQuantity(item.id, item.quantity.value - 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.deepPurple),
                    onPressed: () =>
                        ctrl.updateQuantity(item.id, item.quantity.value + 1),
                  ),
                ],
              ),

              TextButton(
                onPressed: () => ctrl.removeItem(item.id),
                child: const Text(
                  "Remove",
                  style:
                  TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
