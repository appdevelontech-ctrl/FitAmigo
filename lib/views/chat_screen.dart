import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../controllers/friendss_controller.dart';
import '../services/api_service.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendEmail;

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  late IO.Socket _socket;
  bool _isLoading = true;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _initChat();

    final controller = Get.find<FriendController>();
    controller.activeChatUserId.value = widget.friendId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.unreadCountPerUser.containsKey(widget.friendId)) {
        controller.unreadCountPerUser.remove(widget.friendId);
      }

      controller.totalUnread.value = controller.unreadCountPerUser.values.fold(0, (a, b) => a + b);
      controller.lastMessages.refresh();
    });
  }

  @override
  void dispose() {
    final controller = Get.find<FriendController>();
    controller.activeChatUserId.value = "";

    _socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    _userId = await _apiService.getUserId();

    _socket = IO.io(
      'wss://dharma-back-dbxy.onrender.com/',
      IO.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    _socket.on('chat message', (data) {
      if ((data['senderId'] == widget.friendId && data['userId'] == _userId) ||
          (data['senderId'] == _userId && data['userId'] == widget.friendId)) {
        setState(() {
          _messages.add({
            'text': data['text'] ?? '',
            'isMe': data['senderId'] == _userId,
            'time': DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    });

    _socket.connect();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _apiService.getMessages(_userId, widget.friendId);

      if (response['success'] == true) {
        final List<dynamic> messages = response['messages'];

        setState(() {
          _messages
            ..clear()
            ..addAll(messages.map((msg) => {
              'text': msg['text'] ?? '',
              'isMe': msg['sender'] == _userId,
              'time': DateTime.tryParse(msg['createdAt'] ?? '') ?? DateTime.now(),
            }));
        });
      }
    } finally {
      setState(() => _isLoading = false);
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final data = {
      "text": text,
      "userId": widget.friendId,
      "senderId": _userId,
      "type": "message",
    };

    _socket.emit('chat message', data);
    _messageController.clear();
    _scrollToBottom();

    try {
      await _apiService.sendMessage({
        "senderId": _userId,
        "userId": widget.friendId,
        "text": text,
      });
    } catch (_) {}
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  String _time(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== PURPLE MODERN APPBAR =====================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            final controller = Get.find<FriendController>();
            controller.activeChatUserId.value = "";
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.friendName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  )),
            ),
            const SizedBox(width: 10),
            Text(widget.friendName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(child: _chatBody()),
          _messageInput(),
        ],
      ),
    );
  }

  // ===================== CHAT BODY =====================
  Widget _chatBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
    }

    if (_messages.isEmpty) {
      return const Center(
          child: Text(
            "Start a conversation 🗨️",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(14),
      itemCount: _messages.length,
      itemBuilder: (_, index) {
        final msg = _messages[index];

        return Align(
          alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: msg['isMe'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // ------------------ CHAT BUBBLE ------------------
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: msg['isMe']
                      ? Colors.deepPurple
                      : Colors.deepPurple.withOpacity(.08),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: msg['isMe']
                        ? const Radius.circular(18)
                        : const Radius.circular(6),
                    bottomRight: msg['isMe']
                        ? const Radius.circular(6)
                        : const Radius.circular(18),
                  ),
                ),
                child: Text(
                  msg['text'],
                  style: TextStyle(
                    fontSize: 16,
                    color: msg['isMe'] ? Colors.white : Colors.black87,
                    fontWeight: msg['isMe'] ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),

              // ------------------ TIME ------------------
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _time(msg['time']),
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== MESSAGE INPUT =====================
  Widget _messageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              cursorColor: Colors.deepPurple,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.deepPurple.withOpacity(.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple,
              child: const Icon(CupertinoIcons.paperplane_fill,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
