# AI English Tutor: Design & Architecture

## Overview
This document outlines the architecture, design choices, and implementation details for the MVP of the AI English Tutor Android application. The app leverages the **Bring Your Own Key (BYOK)** model with Gemini 1.5 Flash models to provide users with an intelligent and interactive English tutor without requiring backend server processing.

## Architecture Structure

The application follows a clean layered architecture, primarily separating the UI, state management, and external service interactions.

### Directory Structure
```text
lib/
 ├── main.dart
 ├── providers/
 │   └── tutor_provider.dart      # State management (ChangeNotifier)
 ├── screens/
 │   ├── onboarding_screen.dart   # API Key input UI
 │   └── chat_screen.dart         # Main chat interface with Markdown support
 └── services/
     ├── api_key_service.dart     # Secure storage operations (Android Keystore)
     └── gemini_service.dart      # Gemini API communication module
```

### High-Level Architecture Diagram
The architecture is designed to decouple logic, making dependencies explicitly manageable via the `provider` state manager. 

```mermaid
graph TD
    subgraph UI Layer
        O[OnboardingScreen]
        C[ChatScreen]
    end

    subgraph State Management
        P((TutorProvider))
    end

    subgraph Service Layer
        S[ApiKeyService]
        G[GeminiService]
    end

    O -->|Listens & Dispatches| P
    C -->|Listens & Dispatches| P

    P <-->|Fetches/Saves Key| S
    P <-->|Passes Text & Gets Reply| G

    S -.->|Encrypted via flutter_secure_storage| KS[(Device Secure Storage)]
    G -.->|Network call via google_generative_ai| API((Gemini API))
```

## Core Components
1. **ApiKeyService**: Utilizes `flutter_secure_storage` which relies on the Android Keystore (or iOS Keychain) to safely persist the user's Gemini API key.
2. **GeminiService**: Initializes the `GenerativeModel` from the `google_generative_ai` SDK. A strict System Instruction is applied upon initialization to enforce the AI into an "English Tutor" persona.
3. **TutorProvider (`ChangeNotifier`)**: The single source of truth for the app's current state. It stores:
   - The chat message history (`List<ChatMessage>`).
   - The loading status when waiting for Gemini.
   - The presence of the API key to dynamically route the user.
4. **Onboarding & Chat Screens**: Reactive boundaries that only rebuild when changes happen to the `TutorProvider`. The `ChatScreen` supports `flutter_markdown` so that Gemini's rich text responses are properly rendered.

## User Journey / Data Flow Diagram

The following sequence diagram represents the typical application flow, from launching the app to receiving an AI response.

```mermaid
sequenceDiagram
    participant User
    participant Main as MainApp/Router
    participant Storage as ApiKeyService
    participant GEM as Gemini API

    User->>Main: Launch App
    Main->>Storage: getApiKey()
    
    alt No API Key Found
        Storage-->>Main: Returns Null
        Main->>User: Display OnboardingScreen
        User->>Main: Enters & Submits API Key
        Main->>Storage: saveApiKey()
        Main->>Main: Load ChatScreen
    else API Key Exists
        Storage-->>Main: Returns Valid Key
        Main->>GEM: Initialize GenerativeModel
        Main->>Main: Load ChatScreen
    end

    Main->>User: Display ChatScreen
    
    User->>Main: Types English sentence
    Main->>GEM: sendMessage(Prompt)
    GEM-->>Main: Corrected Grammar + Feedback (Markdown)
    Main->>User: Renders Chat Bubble
```

## Application Details
### System Instructions (The Tutor Prompt)
The core logic for defining how the AI acts is hard-coded into the service layer:
> *"You are a strict but encouraging English tutor. Your goal is to help the user improve their English. If the user makes grammar or vocabulary mistakes, correct them gently and explain why. Keep your responses engaging and ask follow-up questions to keep the conversation going."*
