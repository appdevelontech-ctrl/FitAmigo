// lib/views/friends_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/friendss_controller.dart';
import 'chat_screen.dart';
import 'findfriends.dart';

class FriendsScreen extends StatelessWidget {
  final FriendController friendController = Get.find();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Obx(() {
          if (friendController.isLoading.value) {
            return _buildShimmer();
          }

          return RefreshIndicator(
            onRefresh: friendController.fetchAllData,
            color: Colors.deepPurple,
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              children: [
                // =================== TOP HEADER ===================
                _buildTopHeader(context),

                const SizedBox(height: 18),

                // =================== FRIEND REQUESTS ===================
                if (friendController.friendRequests.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: "Friend Requests",
                    count: friendController.friendRequests.length,
                  ),
                  const SizedBox(height: 12),
                  ...friendController.friendRequests.map((req) {
                    final username = req["username"] ?? "User";
                    final email = req["email"] ?? "";

                    return _buildRequestCard(
                      name: username,
                      email: email,
                      onAccept: () => friendController.acceptFriendRequest(req["_id"]),
                    );
                  }).toList(),
                  const SizedBox(height: 26),
                ],

                // =================== MESSAGES SECTION ===================
                _buildSectionHeader(
                  title: "Messages",
                  count: friendController.friends.length,
                ),
                const SizedBox(height: 12),

                friendController.friends.isEmpty
                    ? _buildEmptyState()
                    : Column(
                  children: friendController.friends.map((friend) {
                    final unread = friendController.unreadCountPerUser[friend.id] ?? 0;
                    final lastMsg =
                    friendController.lastMessages[friend.id]?.trim().isNotEmpty == true
                        ? friendController.lastMessages[friend.id]!
                        : "Say hi!";

                    return _buildChatCard(
                      name: friend.username,
                      lastMessage: lastMsg,
                      unreadCount: unread,
                      onTap: () {
                        friendController.clearUnread(friend.id);
                        Get.to(() => ChatScreen(
                          friendId: friend.id,
                          friendName: friend.username,
                          friendEmail: friend.email,
                        ));
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 100), // bottom nav ke liye space
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 350;         // very small screens (iPhone SE)
    final isMedium = width < 430;        // normal 5–6 inch phones

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // LEFT SIDE TITLE + SUBTITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chats",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 20 : isMedium ? 22 : 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmall ? 2 : 4),

                Text(
                  "Stay connected with your fitness buddies",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 9 : isMedium ? 11 : 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isSmall ? 6 : 12),

          // RIGHT SIDE — RESPONSIVE BUTTON
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 350),
                    pageBuilder: (_, __, ___) => FindFriendFilterScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                      return SlideTransition(position: offset, child: child);
                    },
                  ));
            },
            icon: Icon(
              Icons.search,
              size: isSmall ? 14 : 18,
            ),
            label: Text(
              isSmall ? "Find" : (isMedium ? "Find" : "Find Friends"),
              style: TextStyle(
                fontSize: isSmall ? 10 : isMedium ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 8 : isMedium ? 12 : 16,
                vertical: isSmall ? 6 : isMedium ? 8 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // =================== SECTION HEADER ===================
  Widget _buildSectionHeader({required String title, int? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        if (count != null && count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
      ],
    );
  }

  // =================== EMPTY STATE ===================
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 90, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No messages yet",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap on \"Find Friends\" above to start a conversation",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =================== SHIMMER LOADING ===================
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
        itemCount: 8,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // =================== FRIEND REQUEST CARD ===================
  Widget _buildRequestCard({
    required String name,
    required String email,
    required VoidCallback onAccept,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green.shade50,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              "Accept",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // =================== CHAT CARD ===================
  Widget _buildChatCard({
    required String name,
    required String lastMessage,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Avatar + Unread Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? "99+" : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Name + Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Icon(
              CupertinoIcons.chevron_forward,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
