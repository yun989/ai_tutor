# English AI Tutor MVP Application Plan

This plan details the recommended architecture for building your English AI Tutor MVP. We will build a custom Flutter solution aiming **directly at Android** for the MVP, using a "Bring Your Own Key" (BYOK) model.

## Target Platform
*   **Android App** (MVP): Running directly on an Android Emulator or physical device via Android Studio/VS Code.
*   **Future Platforms**: Because we use Flutter, the code can seamlessly be compiled to iOS if needed in the future.

## Architecture: Native Android via Flutter (BYOK Model)

### 1. Framework
*   **Flutter (Dart)**: A single codebase compiled perfectly to an Android `.apk` / `.aab`.

### 2. Core Packages
*   `google_generative_ai`: The official Google SDK for communicating directly with the Gemini API.
*   `flutter_secure_storage`: To safely encrypt and store the user's API Key inside the Android Keystore.
*   `provider`: For state management (handling chat messages, loading states, and API key availability).
*   `flutter_markdown`: To properly render Gemini's Markdown formatted text (bold, code blocks, bullet points).

### 3. Application Flow

1.  **Onboarding / Settings (First Launch):**
    *   The app detects if an API key is saved. If not, it prompts the user to input their Gemini API Key.
    *   The user inputs the key -> the app saves it securely to the device.
2.  **The English Tutor Chat Interface:**
    *   The app initializes the Gemini model using the saved key.
    *   A hidden **System Instruction** is injected (e.g., *"You are a strict English tutor. Correct grammar mistakes and explain why..."*).
    *   The user types -> App streams the educational response.

## Execution Steps

*   **Step 1:** Initialize Flutter project (`flutter create`) in the workspace.
*   **Step 2:** Add all necessary dependencies (`flutter pub add`).
*   **Step 3:** Setup a Git repository and commit the base structure.
*   **Step 4:** Implement the Onboarding Screen logic for secure API Key storage (`flutter_secure_storage`).
*   **Step 5:** Implement the Chat UI and the Gemini service layer with the Tutor prompt (`google_generative_ai`).
