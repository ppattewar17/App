import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late String userId;

  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final String baseUrl = "http://192.168.55.75:5000"; // Use your backend URL

  @override
  void initState() {
    super.initState();

    // Generate a new UUID if not provided
    userId = widget.userId ?? const Uuid().v4();

    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse('$baseUrl/api/users/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data['name'] ?? '';
          birthdayController.text = data['birthday'] ?? '';
          phoneController.text = data['phone'] ?? '';
          emailController.text = data['email'] ?? '';
          passwordController.text = data['password'] ?? '';
        });
      } else {
        print("User not found, creating new profile...");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> updateUserProfile() async {
    final url = Uri.parse('$baseUrl/api/users/$userId');
    final body = json.encode({
      "name": nameController.text,
      "birthday": birthdayController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "password": passwordController.text,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        print("Profile updated successfully");
      } else {
        print("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F9),
      body: Column(
        children: [
          // Top Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 16, right: 16),
            width: double.infinity,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(height: 10),
                isEditing
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: "Enter Name",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                )
                    : Text(
                  nameController.text.isEmpty ? 'Your Name' : nameController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                buildEditableField(Icons.person_outline, "Name", nameController),
                buildEditableField(Icons.cake_outlined, "Birthday", birthdayController),
                buildEditableField(Icons.phone_outlined, "Phone", phoneController),
                buildEditableField(Icons.email_outlined, "Email", emailController),
                buildEditableField(Icons.visibility_outlined, "Password", passwordController),
                const SizedBox(height: 30),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (isEditing) {
                        await updateUserProfile();
                      }
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    child: Text(
                      isEditing ? 'Save' : 'Edit Profile',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField(IconData icon, String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63)),
          const SizedBox(width: 16),
          Expanded(
            child: isEditing
                ? TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(hintText: hint),
            )
                : Text(
              controller.text.isEmpty ? hint : controller.text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
