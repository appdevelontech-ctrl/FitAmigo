// lib/controllers/cart_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
class CartItem {
  final String id;
  final String title;
  final String image;
  final double price;
  final int stock;
  final String pid;
  final RxInt quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.stock,
    required this.pid,
    int quantity = 1,
  }) : quantity = quantity.obs;

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image': image,
    'price': price,
    'stock': stock,
    'pid': pid,
    'quantity': quantity.value,
  };

  // Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : 0,
      pid: json['pid']?.toString() ?? '',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartController extends GetxController {
  final RxList<CartItem> _items = <CartItem>[].obs;
  List<CartItem> get items => _items.toList(); // Return copy to prevent external mutation

  final RxDouble totalPrice = 0.0.obs;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity.value);

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    ever(_items, (_) => _updateTotal());
  }

  // ADD YE METHOD CartController class ke andar (clearCart() ke neeche)

  /// Refresh cart from SharedPreferences (useful when switching to Cart tab)
  Future<void> refreshCart() async {
    await _loadCart(); // Yeh wahi private method hai jo onInit mein chalta hai
    _updateTotal();
    update(); // GetX ko bata de ki UI update karo
  }
  // Calculate total price
  void _updateTotal() {
    totalPrice.value = _items.fold(
      0.0,
          (sum, item) => sum + (item.price * item.quantity.value),
    );
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('cart');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString);
        final items = list
            .map((e) {
          try {
            return CartItem.fromJson(e as Map<String, dynamic>);
          } catch (err) {
            print('Error parsing cart item: $err');
            return null;
          }
        })
            .whereType<CartItem>()
            .toList();
        _items.assignAll(items);
      }
    } catch (e) {
      print('Failed to load cart: $e');
      Get.snackbar('Error', 'Failed to load cart', backgroundColor: Colors.red);
    }
  }

  // Save cart to SharedPreferences
  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('cart', jsonString);
    } catch (e) {
      print('Failed to save cart: $e');
    }
  }

  // Add or update product
  void addProduct(dynamic product) {
    if (product == null) return;

    final String id = product.id?.toString() ?? '';
    final String title = product.title?.toString() ?? 'Product';
    final String image = product.pImage?.toString() ?? '';
    final double price = (product.salePrice is num)
        ? (product.salePrice as num).toDouble()
        : 0.0;
    final int stock = (product.stock is num) ? (product.stock as num).toInt() : 1;

    if (id.isEmpty) return;

    final existing = _items.firstWhereOrNull((i) => i.id == id);
    if (existing != null) {
      if (existing.quantity.value < existing.stock) {
        existing.quantity.value++;
      } else {
        Get.snackbar('Stock Limit', 'Cannot add more. Out of stock!',
            backgroundColor: Colors.orange);
      }
    } else {
      _items.add(CartItem(
        id: id,
        title: title,
        image: image,
        price: price,
        stock: stock,
        pid: id,
      ));
    }
    saveCart();
  }

  // Remove item
  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    saveCart();
    Get.snackbar('Removed', 'Item removed from cart',
        backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
  }

  // Update quantity
  void updateQuantity(String id, int qty) {
    final item = _items.firstWhereOrNull((i) => i.id == id);
    if (item != null && qty > 0 && qty <= item.stock) {
      item.quantity.value = qty;
      _updateTotal(); // ✅ Recalculate total instantly
      saveCart();
    } else if (qty <= 0) {
      removeItem(id);
    } else if (qty > item!.stock) {
      Get.snackbar('Out of Stock', 'Only ${item.stock} left!',
          backgroundColor: Colors.orange);
    }
  }


  // CLEAR CART – AFTER ORDER SUCCESS
  void clearCart() {
    _items.clear();
    saveCart();
    totalPrice.value = 0.0;
    Get.snackbar('Cart Cleared', 'All items removed',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  // Optional: Check if cart has item
  bool hasItem(String id) => _items.any((i) => i.id == id);
}