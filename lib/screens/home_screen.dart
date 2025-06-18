import 'package:flutter/material.dart';
import 'widgets/inhale_exhale_screen.dart';
import 'widgets/breathe_in_screen.dart';
import 'widgets/deep_breaths_screen.dart';
import 'widgets/profile_screen.dart';
import 'widgets/chat_screen.dart';
import 'widgets/schedule_appointment_screen.dart';
import 'widgets/mood_tracker_screen.dart';
import 'widgets/emotion_list_screen.dart';
import 'widgets/resources.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF9F9),
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const HomeScreen(userName: 'Anna'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomIndex = 0;
  bool _isProficiencySelected = true;

  // Track selected emoji index (-1 means none selected)
  int _selectedMoodIndex = -1;

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleAppointmentScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SleepQualityApp()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => EmotionListScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserResourcesPage())); // NEW
        break;
    }
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  Widget buildToggle(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              : [],
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            },
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profile.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const CircleAvatar(radius: 20, child: Icon(Icons.error));
                                },
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.chat),
                            onPressed: () {
                              Navigator.push(
                                context,
                                  MaterialPageRoute(
                                    builder: (_) => UserChatScreen(
                                      userId: 'f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d',
                                      doctorId: '1e598be7-980a-4314-859e-94c2a97edc1b', role: 'user',
                                    ),
                                  )
                              );                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Greeting
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 26, color: Colors.black),
                          children: [
                            const TextSpan(text: 'Hey, '),
                            TextSpan(
                              text: widget.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('How are you doing today?', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 30),

                      // Toggle Buttons
                      Row(
                        children: [
                          buildToggle('Proficiency', _isProficiencySelected, () {
                            setState(() => _isProficiencySelected = true);
                          }),
                          const SizedBox(width: 12),
                          buildToggle('Uniqueness', !_isProficiencySelected, () {
                            setState(() => _isProficiencySelected = false);
                          }),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Mood Log with emoji tap effect
                      const Text('Daily mood Log', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (index) {
                          final emojis = ['😞', '😕', '😐', '🙂', '😄'];
                          final isSelected = index == _selectedMoodIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMoodIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                                    : [],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                emojis[index],
                                style: TextStyle(
                                  fontSize: 30,
                                  color: isSelected ? Colors.deepPurple : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      // Breathing Exercises
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const InhaleExhaleScreen()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                height: 300,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Inhale\nExhale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.4)),
                                    const SizedBox(height: 6),
                                    const Text('for Balance', style: TextStyle(fontSize: 14)),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset('assets/images/inhale_exhale.png', height: 100, width: 100),
                                        const Icon(Icons.arrow_outward),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BreatheInScreen()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    height: 170,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1F5FE),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Breathe in\nBreathe out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3)),
                                        const SizedBox(height: 4),
                                        const Text('for Calm', style: TextStyle(fontSize: 12)),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Image.asset('assets/images/breathe_in.png', height: 70),
                                              const Icon(Icons.arrow_outward, size: 20),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DeepBreathsScreen()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Deep Breaths', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3)),
                                        Text('for Mental Clarity', style: TextStyle(fontSize: 12)),
                                        SizedBox(height: 6),
                                        Align(alignment: Alignment.bottomRight, child: Icon(Icons.arrow_outward, size: 20)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures equal spacing
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.calendar_today),
            ),
            label: '',
            tooltip: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.book),
            ),
            label: '',
            tooltip: 'Mood Tracker',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.edit_note),
            ),
            label: '',
            tooltip: 'Journaling',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.library_books),
            ),
            label: '',
            tooltip: 'Resources',
          ),
        ],
      ),
    );
  }
}
