import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorChatScreen extends StatefulWidget {
  final String userId;
  final String doctorId;
  final String role;

  const DoctorChatScreen({
    super.key,
    required this.userId,
    required this.doctorId,
    required this.role,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  late String chatId;
  late String myId;

  @override
  void initState() {
    super.initState();
    chatId = '${widget.userId}_${widget.doctorId}';
    myId = widget.doctorId;
    _connectSocket();
    _loadMessages();
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.55.75:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      socket.emit('join', {'chatId': chatId});
      print('Connected to socket & joined room: $chatId');
    });

    socket.on('receive_message', (data) {
      print("Message received: $data");
      setState(() {
        messages.insert(0, Map<String, dynamic>.from(data));
      });
    });
  }

  Future<void> _loadMessages() async {
    final res = await http.get(
      Uri.parse('http://192.168.55.75:5000/messages/$chatId'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        messages = data.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = {
      'chatId': chatId,
      'senderId': myId,
      'receiverId': widget.userId,
      'content': text,
      'type': 'Text',
    };

    socket.emit('message', msg);
    _controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.call, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.video_call, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg['senderId'] == myId || msg['sender_id'] == myId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF9164CC) : Colors.grey[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['message'] ?? msg['content'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9164CC),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
