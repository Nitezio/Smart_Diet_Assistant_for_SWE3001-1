# Smart Diet Assistant (SDA) 🥗

[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](https://github.com/Nitezio/Smart_Diet_Assistant_for_SWE3001-1)

**Smart Diet Assistant** is a professional-grade health platform designed specifically for the elderly population in Malaysia. Powered by **Google Gemini 1.5 Flash AI**, it provides culturally tailored, medically safe, and goal-directed nutritional guidance.

---

## 🛠️ Technologies & Tools Used

To achieve production-grade stability and performance, the following technologies were integrated:

*   **Core Framework:** [Flutter](https://flutter.dev/) (Multi-platform Android/iOS)
*   **Programming Language:** [Dart](https://dart.dev/)
*   **AI Engine:** [Google Gemini 1.5 Flash](https://ai.google.dev/) (Multimodal AI)
*   **State Management:** [Provider](https://pub.dev/packages/provider)
*   **Local Database:** [SQLite](https://pub.dev/packages/sqflite) (`sqflite`) for high-performance history storage.
*   **Data Visualization:** [FL Chart](https://pub.dev/packages/fl_chart) for medical trend analytics.
*   **Reporting Engine:** [PDF](https://pub.dev/packages/pdf) & [Printing](https://pub.dev/packages/printing) for doctor-ready exports.
*   **Hardware Integration:** [Image Picker](https://pub.dev/packages/image_picker) for AI Vision camera access.
*   **Persistence:** `shared_preferences` for session and profile management.
*   **Networking:** `connectivity_plus` for offline fallback detection.
*   **Security:** `flutter_dotenv` for sensitive API key protection.
*   **UI Components:** [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter) & [Material 3](https://m3.material.io/).

---

## 🌟 What is it?
SDA is more than just a diet app; it's a digital health companion. It bridges the gap between complex chronic disease management (like Diabetes and Hypertension) and the rich culinary identity of Malaysia. It translates medical constraints into familiar meals—suggesting appropriate portions of Nasi Lemak, Bubur Ayam, or Chapati—ensuring seniors eat healthily without losing their cultural connection.

## 🚀 How it Works
1.  **Health Profiling:** Users input their age, medical conditions (e.g., Blood Sugar Control), allergies, and activity levels.
2.  **AI Orchestration:** The app synchronizes this profile with an internal **Verified Food Database** and sends a structured request to the Gemini AI.
3.  **Intelligent Generation:** The AI acts as a medical nutritionist, generating a 1-day or partial meal plan using specific Malaysian culinary styles (Malay, Chinese, or Indian).
4.  **Interactive Tracking:** Users log meals via manual checkmarks or the **AI Vision Plate Scanner**. The app validates if the meal timing is correct (e.g., flagging Dinner taken in the morning).

## 💎 Key Features
*   🤖 **AI Vision Plate Scanner:** Identify dishes and estimate calories automatically using your camera or gallery.
*   🍱 **Partial Menu Updates:** Change only specific meals (e.g., just Lunch) while keeping the rest of your daily plan intact.
*   💬 **AI Nutritionist Chat:** A persistent conversational agent available for instant dietary advice.
*   📊 **Health Analytics:** High-quality visualization of weekly calorie trends for users and caregivers.
*   📄 **Medical PDF Export:** Generate professional, doctor-ready reports of your nutritional history with one tap.
*   🛡️ **Offline Resilience:** Automatically falls back to the last generated plan if an internet connection is lost.

## 🏗️ Technical Architecture
The application is built on a **Reactive Modular Architecture** for maximum stability and performance:

*   **Frontend:** Developed in **Flutter** using **Material 3** for an accessible, high-contrast, elderly-friendly UI.
*   **Intelligence Layer:** Uses **Google Generative AI (Gemini Pro)** with strict **Structured JSON Output** and **AI Streaming**.
*   **Storage:** A high-performance **SQLite** database manages large-scale history.
*   **Security:** Environment-based API key management using `.env`.

---

## ⚙️ Getting Started

### Prerequisites
*   Flutter SDK (Stable channel)
*   A Gemini AI API Key

### Installation
1.  Clone the repository.
2.  Install dependencies: `flutter pub get`.
3.  Create a `.env` file in the root directory and add your key:
    ```env
    GEMINI_API_KEY=your_key_here
    ```
4.  Run the app: `flutter run`.

---

**Developed with ❤️ for the Elderly of Malaysia.**
