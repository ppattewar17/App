import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // <-- Import added
import 'dart:io';

class DoctorResourcesPage extends StatefulWidget {
  @override
  _DoctorResourcesPageState createState() => _DoctorResourcesPageState();
}

class _DoctorResourcesPageState extends State<DoctorResourcesPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  late IO.Socket socket;
  final String doctorId = "1e598be7-980a-4314-859e-94c2a97edc1b";
  final String userId = "f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d";
  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = userId.compareTo(doctorId) < 0
        ? "${userId}_$doctorId"
        : "${doctorId}_$userId";
    print("🧾 Doctor chatId: $chatId");
    connectSocket();
    fetchOldMessages();
  }

  void connectSocket() {
    socket = IO.io('http://192.168.55.75:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Doctor socket connected');
      socket.emit('joinRoom', {'chatId': chatId});
    });

    socket.on('receive_resource', (data) {
      print("📥 Doctor received: $data");
      if (mounted) {
        setState(() {
          messages.add({
            'senderId': data['senderId'],
            'content': data['content'],
          });
        });
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      socket.emit('send_resource', {
        "chatId": chatId,
        "senderId": doctorId,
        "receiverId": userId,
        "content": text,
      });

      _messageController.clear();
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.bytes != null) {
      final name = result.files.single.name;

      // Optionally: upload to server or store
      socket.emit('send_resource', {
        "chatId": chatId,
        "senderId": doctorId,
        "receiverId": userId,
        "content": "[Document] $name",
      });
    }
  }

  Future<void> fetchOldMessages() async {
    final response = await http.get(Uri.parse('http://192.168.55.75:5000/resources/$chatId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = data.map((msg) => {
          'senderId': msg['sender_id'],
          'content': msg['content'],
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Shared to User (Doctor View)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isDoctor = message['senderId'] == doctorId;

                return Align(
                  alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDoctor ? Colors.white : Colors.teal[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['content'],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.teal),
                  onPressed: _pickDocument,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
