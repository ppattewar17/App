import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// App Entry Point
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Journal',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const EmotionListScreen(),
    );
  }
}

Future<void> submitEntry(String userId, String emotion, String intensity, String prompt) async {
  final uri = Uri.parse("http://192.168.55.75:5000/journal");

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "user_id": userId, // dynamically passed
      "emotion": emotion,
      "intensity": intensity,
      "prompt": prompt,
    }),
  );

  if (response.statusCode == 201) {
    print("Submitted successfully: ${json.decode(response.body)}");
  } else {
    print("Failed to submit: ${response.body}");
  }
}

// Emotion Selection Grid Screen
class EmotionListScreen extends StatelessWidget {
  const EmotionListScreen({super.key});

  final emotions = const ["Joy", "Trust", "Sadness", "Disgust", "Anticipation", "Surprise"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journaling")),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        children: emotions.map((emotion) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IntensityScreen(emotion: emotion)),
              );
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  emotion,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Intensity List Screen
class IntensityScreen extends StatelessWidget {
  final String emotion;
  const IntensityScreen({super.key, required this.emotion});

  @override
  Widget build(BuildContext context) {
    final intensities = journalPrompts[emotion]?.keys.toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('$emotion Intensities')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: intensities.length,
        itemBuilder: (_, i) {
          final intensity = intensities[i];
          return Card(
            child: ListTile(
              title: Text(intensity),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PromptScreen(emotion: emotion, intensity: intensity),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Prompt List Screen
class PromptScreen extends StatefulWidget {
  final String emotion;
  final String intensity;

  const PromptScreen({super.key, required this.emotion, required this.intensity});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final prompts = journalPrompts[widget.emotion]?[widget.intensity] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.intensity} Prompts')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prompts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final isSelected = index == selectedIndex;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.edit,
                    color: isSelected ? Colors.green : null,
                  ),
                  title: Text(
                    prompts[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.green.shade800 : null,
                    ),
                  ),
                  tileColor: isSelected ? Colors.green.shade50 : null,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          if (selectedIndex != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Submit"),
                  onPressed: () async {
                    final selectedPrompt = prompts[selectedIndex!];

                    await submitEntry(
                      "f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d", // Replace with actual user ID
                      widget.emotion,
                      widget.intensity,
                      selectedPrompt,
                    );

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Submitted"),
                        content: Text("You selected:\n\n$selectedPrompt"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Prompt Data
final Map<String, Map<String, List<String>>> journalPrompts = {
  "Joy": {
    "Serenity": [
      "Describe a moment today where you felt peaceful or quietly happy. What created that feeling?",
      "What small, everyday things bring you a sense of calm joy?",
      "When do you feel most at ease with yourself or your surroundings?",
      "How can you invite more serenity into your life this week?",
    ],
    "Ecstasy": [
      "Recall a time you felt overwhelmed by happiness or excitement. What triggered it?",
      "How did you express or share your ecstatic joy with others?",
      "Did that experience shift your perspective or goals in any way?",
      "What fears (if any) come up when you feel this level of joy?",
    ],
  },
  "Trust": {
    "Acceptance": [
      "Who or what do you feel accepted by? How does that acceptance impact you?",
      "In what situations do you find it easy to open up and be yourself?",
      "What does 'being accepted' mean to you emotionally and socially?",
      "Describe a recent interaction where you felt accepted — what stood out?",
    ],
    "Admiration": [
      "Who do you deeply admire, and what qualities in them stand out to you?",
      "When have you experienced admiration that inspired change in your life?",
      "How do you handle admiration — does it motivate, intimidate, or both?",
      "Reflect on a time someone admired you. How did you respond?",
    ],
  },
  "Sadness": {
    "Pensiveness": [
      "What thoughts have you been quietly sitting with lately?",
      "Is there something unresolved that keeps coming up in your reflections?",
      "Describe a moment that left you feeling thoughtful or emotionally distant.",
      "What do you learn about yourself during these pensive states?",
    ],
    "Grief": [
      "What loss (recent or distant) still impacts you emotionally?",
      "How does your body feel when you are grieving?",
      "In grief, what do you most need but often struggle to ask for?",
      "Write a letter to someone or something you’ve lost — what do you want to say?",
    ],
  },
  "Disgust": {
    "Boredom": [
      "What part of your day or life feels dull or unstimulating right now? Why do you think that is?",
      "How do you usually respond to boredom — avoidance, creativity, distraction?",
      "Is boredom trying to point you toward change or unmet needs?",
      "What could bring more engagement into that area of your life?",
    ],
    "Loathing": [
      "What experiences, behaviors, or traits bring up strong feelings of revulsion in you?",
      "Can you identify the values or boundaries being threatened in those moments?",
      "When you feel loathing, how do you usually react — and how do you want to respond?",
      "Explore if any part of your self-perception brings discomfort. What does that reveal?",
    ],
  },
  "Anticipation": {
    "Interest": [
      "What is something you’re currently curious about or intrigued by? Why does it capture your attention?",
      "Describe a recent moment when you felt drawn to explore or learn more about something.",
      "How does being interested in something impact your energy or motivation?",
      "What topics or activities consistently hold your interest — and what do they say about you?",
    ],
    "Vigilance": [
      "What are you currently keeping a close watch on in your life — and why?",
      "Describe a time when you were hyper-aware or cautious about something approaching. What were you trying to protect?",
      "Does heightened anticipation make you feel empowered, anxious, or both?",
      "How do you balance preparation with trust when facing the unknown?",
    ],
  },
  "Surprise": {
    "Distraction": [
      "What has recently caught you off guard or pulled your attention away unexpectedly?",
      "How do you usually handle interruptions or sudden changes in your day?",
      "When are distractions helpful, and when do they feel intrusive or overwhelming?",
      "What does your reaction to minor surprises say about your current mental state?",
    ],
    "Amazement": [
      "Recall a moment when you were completely taken aback — in awe, shock, or disbelief. What happened?",
      "How did that experience shift your understanding or emotional landscape?",
      "Do you find it easy or difficult to embrace wonder and awe? Why?",
      "When was the last time something amazed you in a positive way — and how did you savor that moment?",
    ],
  },
};