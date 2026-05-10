# AI English Tutor

An intelligent, interactive English tutoring application built with **Flutter** and the **Gemini 3.1 Live API**. This application helps users improve their English through real-time conversational practice, grammar correction, and tailored feedback.

The application follows a **Bring Your Own Key (BYOK)** architecture to ensure complete privacy. API keys are safely stored in your device's native encrypted storage (Android Keystore / iOS Keychain / Browser Storage) and are strictly managed locally.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-%238E75B2.svg?style=for-the-badge&logo=googlebard&logoColor=white)

## 🚀 Recent Upgrade: Dual Mode Support (2026)

The application now supports two distinct ways to practice your English:
- **Classic Chat Mode**: Traditional text-based interaction with grammar correction & rich markdown feedback.
- **Live Voice Mode**: Real-time, low-latency bidirectional voice conversation using the **Gemini 3.1 Flash Live** model. Practice speaking naturally with the AI, hear its corrections, and experience instant interruptions (Barge-in).

## Features

- **BYOK Architecture**: No backend accounts needed. Just plug in your Gemini API key and start using the app.
- **Secure Storage**: Your API Key is encrypted using `flutter_secure_storage`.
- **Live Conversational AI**: Native audio-to-audio streaming via WebSockets for a fluid "Siri-like" tutoring experience.
- **Grammar & Pronunciation Feedback**: Real-time analysis of your spoken and written English.
- **Rich Text Support**: Markdown rendering for responses to neatly display code blocks, lists, and emphasis in the explanations.
- **Microphone Integration**: Optimized PCM 16-bit audio streaming using the `record` package for robust cross-platform performance (including Web).

## Technical Stack

- **Framework**: Flutter (Dart)
- **AI Models**: Gemini 1.5/2.0/3.1 Flash-Lite (Text), Gemini 2.0/3.1 Flash Live (Voice)
- **Networking**: WebSockets (`web_socket_channel`) for low-latency live streams.
- **Audio Engine**: `record` (for recording) and `audioplayers` (for high-compatibility Windows/Mobile playback).
- **State Management**: Dual-provider architecture using the `provider` package.

## Project Structure

- `lib/`: **Main Dart source code.** 
  - `services/`: Contains `gemini_live_client.dart` (WebSocket) and `audio_service.dart`.
  - `providers/`: State management for both text and live sessions.
- `android/`, `ios/`: Platform-specific configurations. Note: Android requires `RECORD_AUDIO` permission.
- `web/`: Web-specific configuration and assets.
- `docs/`: Deployment plans and architecture diagrams.

## 🚀 Try It Now (Web Version)

You can try the fully functional Web version of the AI English Tutor directly from your browser (including mobile browsers) without installing anything!

**[👉 Open AI English Tutor on GitHub Pages](https://yun989.github.io/ai_tutor/)**

### How to use on mobile:
1. Open the link above in Chrome (Android) or Safari (iOS).
2. You can tap "Share" -> **"Add to Home Screen"** to install it as an app (PWA).
3. Ensure you allow **Microphone Access** when prompted to use the voice tutoring feature.
*(Note: If you experience no sound on iOS Safari after starting a call, ensure your phone is not in silent mode.)*

## Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- **Android Studio** (for emulator testing) or **Chrome/Edge** (for web development)
- A **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

### Installation

1. Switch into the project root directory:
   ```bash
   cd ai_tutor
   ```

2. Fetch all required dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:

   **For Web (Recommended for Development):**
   ```bash
   flutter run -d chrome
   ```

   **For Mobile (Android/iOS):**
   ```bash
   flutter run
   ```
   *(Note: Recommended to run on a physical device to test microphone and audio streaming performance.)*

## Architecture and Design

Please refer to `docs/design.md` for our more detailed system and architecture descriptions, covering data flows and service breakdowns.
