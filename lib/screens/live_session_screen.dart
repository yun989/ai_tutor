import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/live_tutor_provider.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    super.dispose();
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
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Provider.of<LiveTutorProvider>(
                context,
                listen: false,
              ).stopSession();
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Live English Tutor',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Consumer<LiveTutorProvider>(
          builder: (context, provider, child) {
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
                  _buildEndCallButton(context),
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
        child: Text(
          text.isEmpty ? "Transcription will appear here..." : text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () {
        Provider.of<LiveTutorProvider>(context, listen: false).stopSession();
        Navigator.of(context).pop();
      },
      backgroundColor: Colors.red,
      child: const Icon(Icons.call_end, color: Colors.white, size: 36),
    );
  }
}
