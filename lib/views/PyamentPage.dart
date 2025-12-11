// // lib/views/payment_page.dart
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:get/get.dart';
//
// class PaymentPage extends StatefulWidget {
//   final Map<String, dynamic> orderData;
//   const PaymentPage({required this.orderData, super.key});
//
//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _openCheckout();
//   }
//
//   void _openCheckout() {
//     var options = {
//       'key': 'YOUR_RAZORPAY_KEY',
//       'amount': (widget.orderData['totalAmount'] * 100).toInt(),
//       'name': 'Dharma App',
//       'description': 'Order Payment',
//       'prefill': {
//         'contact': widget.orderData['phone'],
//         'email': widget.orderData['email'],
//       },
//     };
//     _razorpay.open(options);
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     Get.snackbar('Success', 'Payment ID: ${response.paymentId}');
//     Get.offAllNamed('/main');
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     Get.snackbar('Failed', 'Error: ${response.message}');
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }