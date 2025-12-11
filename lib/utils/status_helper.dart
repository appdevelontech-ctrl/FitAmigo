// lib/utils/status_helper.dart
import 'dart:ui';
import 'package:flutter/material.dart';
Map<int, String> orderStatusMap = {
  1: "Placed",
  2: "Accepted",
  3: "Processing / Packed",
  4: "Dispatched",
  5: "Out for Delivery",
  6: "Delivered",
};

String getStatusText(int status) => orderStatusMap[status] ?? "Unknown";

Color getStatusColor(int status) {
  switch (status) {
    case 1: return const Color(0xFFFFA726); // orange
    case 2: return const Color(0xFF42A5F5); // blue
    case 3: return const Color(0xFFAB47BC); // purple
    case 4: return const Color(0xFF5C6BC0); // indigo
    case 5: return const Color(0xFF26A69A); // teal
    case 6: return const Color(0xFF66BB6A); // green
    default: return Colors.grey;
  }
}