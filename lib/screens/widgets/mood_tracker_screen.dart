import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SleepQualityApp());
}

class SleepQualityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      home: MoodTrackerScreen(userId: 'f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d'), // Replace with actual userId
      debugShowCheckedModeBanner: false,
    );
  }
}

class MoodTrackerScreen extends StatefulWidget {
  final String userId;
  const MoodTrackerScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MoodTrackerScreenState createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            MoodTrackerPage(currentPage: _currentPage, userId: widget.userId),
            AssessmentPage(currentPage: _currentPage, userId: widget.userId),
          ],
        ),
      ),
    );
  }
}

// Mood Tracker Page
class MoodTrackerPage extends StatefulWidget {
  final int currentPage;
  final String userId;

  const MoodTrackerPage({Key? key, required this.currentPage, required this.userId}) : super(key: key);

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  double _sliderValue = 4;

  final List<Map<String, dynamic>> sleepLevels = [
    {"label": "Excellent", "hours": "7–9 HOURS", "icon": "😊", "color": Colors.green},
    {"label": "Good", "hours": "6–7 HOURS", "icon": "🙂", "color": Colors.yellow[700]},
    {"label": "Fair", "hours": "5 HOURS", "icon": "😐", "color": Colors.grey},
    {"label": "Poor", "hours": "3–4 HOURS", "icon": "☹️", "color": Colors.red},
    {"label": "Worst", "hours": "<3 HOURS", "icon": "😵", "color": Colors.purple},
  ];

  Future<void> submitSleep(int level) async {
    final response = await http.post(
      Uri.parse("http://192.168.55.75:5000/sleep"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": widget.userId, "sleepLevel": level}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sleep quality submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
              const SizedBox(width: 4),
              const Text("Assessment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text("${widget.currentPage + 1} OF 2", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("How would you rate\nyour sleep quality?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sleepLevels.map((level) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(level["label"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(level["hours"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 24),
                    // Slider
                    RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.deepOrange,
                          inactiveTrackColor: Colors.orange.shade100,
                          thumbColor: Colors.deepOrange,
                          overlayColor: Colors.orange.withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (value) => setState(() => _sliderValue = value),
                          onChangeEnd: (value) => submitSleep(value.toInt()),
                          min: 0,
                          max: 4,
                          divisions: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Icons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: sleepLevels.asMap().entries.map((entry) {
                        int index = entry.key;
                        var level = entry.value;
                        bool isSelected = _sliderValue.round() == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? level["color"].withOpacity(0.2) : Colors.transparent,
                            boxShadow: isSelected
                                ? [BoxShadow(color: level["color"].withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(level["icon"], style: TextStyle(fontSize: 26, color: level["color"])),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Assessment Page
class AssessmentPage extends StatefulWidget {
  final int currentPage;
  final String userId;

  const AssessmentPage({Key? key, required this.currentPage, required this.userId}) : super(key: key);

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  Future<void> submitExpression() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse("http://192.168.55.75:5000/expression"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": widget.userId, "content": content}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expression submitted')),
      );
    }
  }

  void _startVoiceInput() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') setState(() => _isListening = false);
      },
      onError: (val) {
        print('Speech recognition error: $val');
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            setState(() {
              _controller.text += (_controller.text.isNotEmpty ? " " : "") + val.recognizedWords;
              _charCount = _controller.text.length;
            });
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
                          const SizedBox(width: 4),
                          const Text("Assessment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text("${widget.currentPage + 1} OF 2", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Expression Analysis", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        "Freely write down anything that’s on your mind. Dr is here to listen…",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller,
                              maxLines: 6,
                              maxLength: 250,
                              decoration: const InputDecoration.collapsed(hintText: "Type your thoughts here..."),
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text("$_charCount/250", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isListening ? null : _startVoiceInput,
                        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                        label: Text(_isListening ? "Listening..." : "Use voice instead"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAF0DC),
                          foregroundColor: Colors.green,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: submitExpression,
                child: const Text("Continue"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
