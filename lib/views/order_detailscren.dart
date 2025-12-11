import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../utils/status_helper.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String userId;
  final String orderId;
  const OrderDetailScreen({Key? key, required this.userId, required this.orderId})
      : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrderDetail(widget.userId, widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return Scaffold(
      backgroundColor: Colors.white,

      // ====== PURPLE PREMIUM APPBAR ======
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Obx(() {
          final order = controller.orderDetail.value?.order;
          final displayId = order?.orderId.toString() ?? widget.orderId;
          return Text(
            "Order #${displayId.length > 10 ? displayId.substring(0, 10) : displayId}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isSmall ? 16 : 18,
            ),
          );
        }),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        final order = controller.orderDetail.value?.order;
        if (order == null) {
          return const Center(
            child: Text("Order Not Found", style: TextStyle(color: Colors.black54, fontSize: 18)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOrderHeader(order, isSmall),
              const SizedBox(height: 16),
              _buildInfoSection(order, isSmall),
              const SizedBox(height: 16),
              _buildAddressSection(order.details, isSmall),
              const SizedBox(height: 16),
              _buildProductsSection(order.items, isSmall),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ================= ORDER SUMMARY CARD =================
  Widget _buildOrderHeader(OrderDetail order, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.10),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.deepPurple.withOpacity(.30)),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order #${order.orderId}",
              style: TextStyle(fontSize: isSmall ? 17 : 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(DateFormat('dd MMM yyyy').format(order.createdAt),
              style: TextStyle(color: Colors.grey.shade700, fontSize: isSmall ? 12 : 14)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: TextStyle(color: Colors.black54, fontSize: 15)),
              Text(
                "₹${order.totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: isSmall ? 22 : 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== ORDER STATUS CHIP =====
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor(order.status).withOpacity(0.20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: getStatusColor(order.status)),
              ),
              child: Text(
                getStatusText(order.status),
                style: TextStyle(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(order.status),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== INFO SECTION ==================
  Widget _buildInfoSection(OrderDetail order, bool isSmall) {
    return Column(
      children: [
        _infoTile("Payment Method", order.mode, Icons.payment),
        const SizedBox(height: 12),
        _infoTile("Order Date", DateFormat('dd MMM yyyy • hh:mm a').format(order.createdAt),
            Icons.calendar_month),
      ],
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.deepPurple.withOpacity(.20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: Colors.black54, fontSize: 14)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ]),
          ),
        ],
      ),
    );
  }

  // ================== ADDRESS SECTION ==================
  Widget _buildAddressSection(ShippingAddress addr, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(.08),
            Colors.white,
          ],
        ),
        border: Border.all(color: Colors.deepPurple.withOpacity(.25)),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(.10), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(CupertinoIcons.location_fill, color: Colors.deepPurple, size: 20),
            SizedBox(width: 8),
            Text("Shipping Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ]),
          const SizedBox(height: 12),

          Text(addr.username, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(addr.phone),
          const SizedBox(height: 8),
          Text(addr.address),
          const SizedBox(height: 4),
          Text(addr.pincode, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ================= PRODUCTS SECTION =================
  Widget _buildProductsSection(List<OrderProduct> products, bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.shopping_bag_rounded, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text("Order Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        ]),
        const SizedBox(height: 12),

        ...products.map((p) => _productTile(p, isSmall)),
      ],
    );
  }

  // ============== SINGLE PRODUCT CARD ==============
  Widget _productTile(OrderProduct product, bool isSmall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.withOpacity(.20)),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(.10), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 60,
                height: 60,
                color: Colors.deepPurple.withOpacity(.10),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.deepPurple.withOpacity(.10),
                child: const Icon(Icons.broken_image, color: Colors.deepPurple),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.title,
                  style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("₹${product.price}",
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              if (product.quantity > 1)
                Text("Qty: ${product.quantity}", style: const TextStyle(color: Colors.black54)),
            ]),
          ),

          Text(
            "₹${(product.price * product.quantity).toStringAsFixed(0)}",
            style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 14 : 16),
          ),
        ],
      ),
    );
  }
}
