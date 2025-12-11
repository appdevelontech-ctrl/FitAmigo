import 'package:flutter/material.dart';

class FriendProfileScreen extends StatelessWidget {
  final dynamic friend; // You can replace with your Friend model type

  const FriendProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: Text(friend.username, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, child: Text(friend.username[0])),
            const SizedBox(height: 16),
            Text(friend.username, style: const TextStyle(color: Colors.white, fontSize: 22)),
            Text(friend.email, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
