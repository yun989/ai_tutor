import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/tutor_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid API key.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TutorProvider>(
        context,
        listen: false,
      ).setApiKey(apiKey);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving API key: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to AI English Tutor")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.language, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                "Welcome! To start learning, you need a Gemini API Key.\n\n"
                "1. Click the button below to go to Google AI Studio.\n"
                "2. Sign in with your Google account.\n"
                "3. Click 'Create API Key' and copy the key.\n"
                "4. Paste it below to start your personalized tutor!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://aistudio.google.com/app/apikey',
                  );
                  if (!await launchUrl(url)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the website'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Get Free API Key'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: "Gemini API Key",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveApiKey,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Start Chatting",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                "By using this app, you agree to the following:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "• Your API key is stored securely on your device and is never sent to any third-party server.\n"
                "• Voice audio is streamed directly to Google for AI processing. No audio is stored by this app.\n"
                "• You are responsible for any API usage costs associated with your key.\n"
                "• AI-generated teaching content may not always be accurate.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
