// lib/models/order_models.dart
import 'package:intl/intl.dart';

class UserOrdersResponse {
  final String message;
  final bool success;
  final UserOrder userOrder;

  UserOrdersResponse({
    required this.message,
    required this.success,
    required this.userOrder,
  });

  factory UserOrdersResponse.fromJson(Map<String, dynamic> json) {
    return UserOrdersResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      userOrder: UserOrder.fromJson(json['userOrder']),
    );
  }
}

class UserOrder {
  final String id;
  final String phone;
  final List<OrderItem> orders;
  final String username;
  final String email;
  final String address;
  final String city;
  final String pincode;

  UserOrder({
    required this.id,
    required this.phone,
    required this.orders,
    required this.username,
    required this.email,
    required this.address,
    required this.city,
    required this.pincode,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ??
          [],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class OrderItem {
  final String id;
  final String mode;
  final double totalAmount;
  final int status;
  final int orderId;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.mode,
    required this.totalAmount,
    required this.status,
    required this.orderId,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      mode: json['mode'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 1,
      orderId: json['orderId'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ================= SINGLE ORDER DETAIL =================

class OrderDetailResponse {
  final bool success;
  final String message;
  final OrderDetail order;

  OrderDetailResponse({
    required this.success,
    required this.message,
    required this.order,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      order: OrderDetail.fromJson(json['userOrder']), // <-- API mein "userOrder"
    );
  }
}

class OrderDetail {
  final String id;
  final String mode;
  final double totalAmount;
  final int status;
  final int orderId;
  final DateTime createdAt;
  final List<OrderProduct> items;           // <-- "items" from API
  final ShippingAddress details;            // <-- "details" from API

  OrderDetail({
    required this.id,
    required this.mode,
    required this.totalAmount,
    required this.status,
    required this.orderId,
    required this.createdAt,
    required this.items,
    required this.details,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['_id'] ?? '',
      mode: json['mode'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 1,
      orderId: json['orderId'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderProduct.fromJson(e))
          .toList() ??
          [],
      details: (json['details'] as List<dynamic>?)?.isNotEmpty == true
          ? ShippingAddress.fromJson(json['details'][0])
          : ShippingAddress.empty(),
    );
  }
}

class OrderProduct {
  final String id;
  final String title;
  final String image;
  final double price;
  final int quantity;

  OrderProduct({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] ?? json['pid'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class ShippingAddress {
  final String username;
  final String phone;
  final String address;
  final String pincode;
  final String email;

  ShippingAddress({
    required this.username,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.email,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Empty fallback
  factory ShippingAddress.empty() {
    return ShippingAddress(
      username: 'Not Available',
      phone: '',
      address: '',
      pincode: '',
      email: '',
    );
  }
}