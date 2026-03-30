# AI English Tutor

An intelligent, interactive English tutoring application built with **Flutter** and the **Gemini API**. This application helps users improve their English through conversational practice, grammar correction, and tailored feedback.

The application follows a **Bring Your Own Key (BYOK)** architecture to ensure complete privacy. API keys are safely stored in your device's native encrypted storage (Android Keystore / iOS Keychain) and are strictly managed locally without hitting any intermediate server.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-%238E75B2.svg?style=for-the-badge&logo=googlebard&logoColor=white)

## Features

- **BYOK Architecture**: No backend accounts needed. Just plug in your Gemini API key and start using the app.
- **Secure Storage**: Your API Key is encrypted using `flutter_secure_storage`.
- **Intelligent Feedback**: The app communicates with Gemini 1.5 Flash using a strict "English Tutor" prompt, providing grammar corrections and vocabulary explanations.
- **Rich Text Support**: Markdown rendering for responses to neatly display code blocks, lists, and emphasis in the explanations.
- **State Management**: Clean architecture provided by the `provider` package to handle seamless transitions between the Onboarding and Chat interfaces.

## Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- **Android Studio** (for emulator testing or physical device) or Xcode (if compiling for macOS/iOS)
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

   ```bash
   flutter run
   ```

## Architecture and Design

Please refer to `docs/design.md` for our more detailed system and architecture descriptions, covering data flows and service breakdowns.

## How to find your API Key

To use the application, you'll need an active Google Gemini API key:
1. Head over to [Google AI Studio](https://aistudio.google.com/).
2. Sign in with your Google account.
3. Click "Get API Key" -> "Create API Key in new project".
4. Copy the generated API Key and paste it into the application upon launching the Onboarding screen.
