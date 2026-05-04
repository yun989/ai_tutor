import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tutor_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/live_session_screen.dart';

import 'providers/live_tutor_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TutorProvider()),
        ChangeNotifierProvider(create: (_) => LiveTutorProvider()),
      ],
      child: const AITutorApp(),
    ),
  );
}

class AITutorApp extends StatelessWidget {
  const AITutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI English Tutor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: Consumer<TutorProvider>(
        builder: (context, tutorProvider, child) {
          if (tutorProvider.isApiKeySet) {
            return const LiveSessionScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}
