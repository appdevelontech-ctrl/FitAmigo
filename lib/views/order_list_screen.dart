// 📄 lib/views/order_list_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../services/api_service.dart';
import '../../utils/status_helper.dart';
import '../models/order_model.dart';
import 'order_detailscren.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late final OrderController controller;
  String? userId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrderController>();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final api = Get.find<ApiService>();
    userId = await api.getUserId();

    if (userId != null && userId!.isNotEmpty) {
      await controller.fetchUserOrders(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔮 Purple Theme AppBar
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        centerTitle: true,
        title: Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 21,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 18),
          );
        }

        final orders = controller.ordersResponse.value?.userOrder.orders ?? [];

        if (orders.isEmpty) return _emptyUI();

        return RefreshIndicator(
          color: Colors.deepPurple,
          onRefresh: () => controller.fetchUserOrders(userId!),
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: orders.length,
            itemBuilder: (_, i) => _orderCard(orders[i]),
          ),
        );
      }),
    );
  }

  // ❌ Empty UI – Purple friendly
  Widget _emptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.cube_box_fill,
              size: 85, color: Colors.deepPurple.shade200),
          const SizedBox(height: 16),
          Text(
            "No Orders Yet",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Place your first order now!",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // 🔹 Purple-Themed Order Card
  Widget _orderCard(OrderItem order) {
    final bool isSmall = MediaQuery.of(context).size.width < 370;

    return GestureDetector(
      onTap: () => Get.to(
            () => OrderDetailScreen(
          userId: userId!,
          orderId: order.id,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.deepPurple.withOpacity(.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Order ID + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Order #${order.orderId}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isSmall ? 16 : 18,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // 🔮 Status Tag (Purple)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: getStatusColor(order.status).withOpacity(.12),
                    border:
                    Border.all(color: getStatusColor(order.status), width: 1),
                  ),
                  child: Text(
                    getStatusText(order.status),
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(order.status),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 14),

            // 💰 Total Amount (Purple)
            Row(
              children: [
                Icon(Icons.currency_rupee,
                    size: 22, color: Colors.deepPurple),
                Text(
                  "${order.totalAmount.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 22 : 26,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 📅 Date + Payment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DATE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(order.createdAt),
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('hh:mm a').format(order.createdAt),
                      style:
                      const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),

                // PAYMENT MODE
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment,
                          size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        order.mode == "Razorpay"
                            ? "Online Payment"
                            : order.mode,
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ARROW
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 22,
                color: Colors.deepPurple.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
