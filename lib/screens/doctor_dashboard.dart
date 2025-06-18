import 'package:flutter/material.dart';
import '../screens/doctor_chat_screen.dart'; // Ensure this exists
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/resources_doctor.dart';

class DoctorAdminApp extends StatelessWidget {
  final String doctorName;

  const DoctorAdminApp({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Admin',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFFFFF9F1),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF455A64),
        ),
      ),
      home: DoctorHomeScreen(doctorName: doctorName),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DoctorHomeScreen extends StatelessWidget {
  final String doctorName;

  const DoctorHomeScreen({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    final List<_FeatureCard> features = [
      _FeatureCard(title: 'Schedule Requests', icon: Icons.schedule, route: const AppointmentRequestsScreen()),
      _FeatureCard(
        title: 'Chat with Patients',
        icon: Icons.chat,
        route: DoctorChatScreen(
          userId: 'f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d',
          doctorId: '1e598be7-980a-4314-859e-94c2a97edc1b',
          role: 'doctor',
        ),
      ),
      _FeatureCard(title: 'Resources', icon: Icons.menu_book, route: DoctorResourcesPage()),
      _FeatureCard(title: 'Patient Records', icon: Icons.folder_shared, route: const PlaceholderScreen(title: 'Records')),
      _FeatureCard(title: 'Video Sessions', icon: Icons.video_call, route: const PlaceholderScreen(title: 'Video Sessions')),
      _FeatureCard(title: 'Notifications', icon: Icons.notifications, route: const PlaceholderScreen(title: 'Notifications')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $doctorName', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF8D6E63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => feature.route));
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(feature.icon, size: 40, color: const Color(0xFF6D4C41)),
                      const SizedBox(height: 10),
                      Text(
                        feature.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard {
  final String title;
  final IconData icon;
  final Widget route;

  _FeatureCard({required this.title, required this.icon, required this.route});
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title Screen (Coming Soon)', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ------------------- Appointment Requests -----------------------

class AppointmentRequestsScreen extends StatefulWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  State<AppointmentRequestsScreen> createState() => _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState extends State<AppointmentRequestsScreen> {
  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final response = await http.get(
      Uri.parse('http://192.168.55.75:5000/api/appointments'),
    );

    if (response.statusCode == 200) {
      setState(() {
        appointments = json.decode(response.body);
      });
    } else {
      print('Failed to fetch appointments');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('http://192.168.55.75:5000/api/appointments/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status[0].toUpperCase() + status.substring(1)}),
    );

    if (response.statusCode == 200) {
      await fetchAppointments(); // Refresh data
    } else {
      print('Failed to update status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final data = appointments[index];
          final date = DateTime.parse(data['appointment_datetime']);
          final status = data['status'];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['user_name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Date: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                  Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                  const SizedBox(height: 12),
                  if (status.toLowerCase() == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          onPressed: () => updateStatus(data['id'], 'accepted'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => updateStatus(data['id'], 'rejected'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
