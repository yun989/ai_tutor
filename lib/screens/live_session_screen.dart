import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/live_tutor_provider.dart';
import '../providers/tutor_provider.dart';
import '../services/gemini_service.dart';
import '../services/api_key_service.dart';
import 'chat_screen.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _transcriptScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LiveTutorProvider>(context, listen: false).startSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transcriptScrollController.hasClients) {
        _transcriptScrollController.jumpTo(
          _transcriptScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<LiveTutorProvider>(context, listen: false).stopSession();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Remove API Key',
            onPressed: () async {
              Provider.of<LiveTutorProvider>(context, listen: false).stopSession();
              await Provider.of<TutorProvider>(context, listen: false).removeApiKey();
            },
          ),
          title: const Text(
            'Live English Tutor',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              tooltip: 'Text Mode',
              onPressed: () {
                Provider.of<LiveTutorProvider>(context, listen: false).stopSession();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                ).then((_) {
                  Provider.of<LiveTutorProvider>(context, listen: false).startSession();
                });
              },
            ),
          ],
        ),
        body: Consumer<LiveTutorProvider>(
          builder: (context, provider, child) {
            _scrollToBottom();
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(child: _buildVisualizer(provider.state)),
                  ),
                  _buildStatusText(provider.state),
                  const SizedBox(height: 20),
                  if (provider.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: \${provider.errorMessage}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _buildTranscriptArea(provider.currentAiText),
                  const SizedBox(height: 40),
                  _buildCallButton(context, provider.state),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisualizer(LiveSessionState state) {
    IconData icon;
    Color color;
    bool isAnimating = false;

    switch (state) {
      case LiveSessionState.disconnected:
      case LiveSessionState.connecting:
        icon = Icons.mic_none;
        color = Colors.grey;
        break;
      case LiveSessionState.listening:
        icon = Icons.mic;
        color = Colors.blueAccent;
        isAnimating = true;
        break;
      case LiveSessionState.aiSpeaking:
        icon = Icons.graphic_eq;
        color = Colors.greenAccent;
        isAnimating = true;
        break;
      case LiveSessionState.error:
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
    }

    Widget coreIcon = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 60, color: color),
    );

    if (isAnimating) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _pulseAnimation.value, child: child);
        },
        child: coreIcon,
      );
    }

    return coreIcon;
  }

  Widget _buildStatusText(LiveSessionState state) {
    String text;
    switch (state) {
      case LiveSessionState.disconnected:
        text = "Disconnected";
        break;
      case LiveSessionState.connecting:
        text = "Connecting to AI...";
        break;
      case LiveSessionState.listening:
        text = "Listening... Start speaking!";
        break;
      case LiveSessionState.aiSpeaking:
        text = "Tutor is speaking...";
        break;
      case LiveSessionState.error:
        text = "Connection Failed";
        break;
    }

    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTranscriptArea(String text) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        controller: _transcriptScrollController,
        child: Text(
          text.isEmpty ? "Transcription will appear here..." : text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context, LiveSessionState state) {
    if (state == LiveSessionState.disconnected || state == LiveSessionState.error) {
      return FloatingActionButton.large(
        onPressed: () {
          Provider.of<LiveTutorProvider>(context, listen: false).startSession();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.call, color: Colors.white, size: 36),
      );
    } else {
      return FloatingActionButton.large(
        onPressed: () {
          final provider = Provider.of<LiveTutorProvider>(context, listen: false);
          final transcript = provider.currentAiText;
          provider.stopSession();
          _showSummaryDialog(context, transcript);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.call_end, color: Colors.white, size: 36),
      );
    }
  }

  Future<void> _showSummaryDialog(BuildContext context, String transcript) async {
    if (transcript.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough conversation data to summarize.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text('Generating Teaching Notes...'),
          content: SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );

    try {
      final apiKey = await ApiKeyService.getApiKey() ?? '';
      final summary = await GeminiService.generateSummary(apiKey, transcript);
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading dialog
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('📝 Teaching Notes'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: MarkdownBody(data: summary ?? "No summary generated."),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (summary == null || summary.isEmpty) return;
                  try {
                    if (kIsWeb) {
                      final bytes = Uint8List.fromList(utf8.encode(summary));
                      final xfile = XFile.fromData(bytes, mimeType: 'text/markdown', name: 'Teaching_Notes.md');
                      await Share.shareXFiles([xfile], text: 'My Teaching Notes');
                    } else {
                      final directory = await getTemporaryDirectory();
                      final file = File('${directory.path}/Teaching_Notes.md');
                      await file.writeAsString(summary);
                      await Share.shareXFiles([XFile(file.path)], text: 'My Teaching Notes');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to export note: $e')),
                      );
                    }
                  }
                },
                child: const Text('Export Note'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate summary: $e')),
      );
    }
  }
}
