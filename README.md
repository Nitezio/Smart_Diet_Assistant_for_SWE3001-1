# Smart Diet Assistant (SDA) 🥗

[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](https://github.com/Nitezio/Smart_Diet_Assistant_for_SWE3001-1)

**Smart Diet Assistant** is a professional-grade health platform designed specifically for the elderly population in Malaysia. Powered by **Google Gemini 1.5 Flash AI**, it provides culturally tailored, medically safe, and goal-directed nutritional guidance.

---

## 🛠️ Full Technology Stack

To achieve production-grade stability and multimodal AI performance, the following tools and technologies were integrated:

### **Languages & Frameworks**
*   **Language:** [Dart](https://dart.dev/) (Optimized for fast UI and high performance)
*   **Framework:** [Flutter](https://flutter.dev/) (Multi-platform support for Android and iOS)
*   **Design System:** [Material 3](https://m3.material.io/) (Google's latest design language for modern, accessible UIs)

### **Artificial Intelligence**
*   **AI Engine:** [Google Gemini 1.5 Flash](https://ai.google.dev/) (Multimodal capabilities: Text, Vision, and JSON output)
*   **Vision API:** Gemini Multimodal (Dishes identification and calorie estimation via photos)
*   **Prompt Engineering:** Forced-merging and specialized context synchronization for localized Malaysian nutrition.

### **Data & Persistence**
*   **Local Database:** [SQLite](https://pub.dev/packages/sqflite) (`sqflite`) for high-speed, persistent storage of meal history and food databases.
*   **Session Storage:** `shared_preferences` for user profiles and offline cache.
*   **File Management:** `path` & `path_provider` for secure local database pathing.

### **Advanced UI & Reporting**
*   **Data Visualization:** [FL Chart](https://pub.dev/packages/fl_chart) (Professional bar charts for weekly calorie trends)
*   **Reporting:** [PDF](https://pub.dev/packages/pdf) (Generating doctor-ready medical documents)
*   **Printing:** [Printing](https://pub.dev/packages/printing) (Native PDF preview and sharing logic)
*   **Icons:** [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter) & [Cupertino Icons](https://pub.dev/packages/cupertino_icons)

### **Hardware & Networking**
*   **Hardware Integration:** [Image Picker](https://pub.dev/packages/image_picker) (Camera and Gallery access)
*   **Connectivity:** [Connectivity Plus](https://pub.dev/packages/connectivity_plus) (Real-time internet detection for offline fallback)

### **Security & Development Tools**
*   **Secrets Management:** `flutter_dotenv` (Protecting API keys via environment variables)
*   **State Management:** [Provider](https://pub.dev/packages/provider) (Central logic coordination)
*   **Version Control:** [Git](https://git-scm.com/) (Feature-branch workflow)
*   **Localization:** `intl` (Complex date and time formatting)

---

## 🌟 What is it?
SDA is more than just a diet app; it's a digital health companion. It bridges the gap between complex chronic disease management (like Diabetes and Hypertension) and the rich culinary identity of Malaysia. It translates medical constraints into familiar meals—suggesting appropriate portions of Nasi Lemak, Bubur Ayam, or Chapati—ensuring seniors eat healthily without losing their cultural connection.

## 🚀 How it Works
1.  **Health Profiling:** Users input their health twin (age, conditions, goal, allergies).
2.  **AI Orchestration:** The app synchronizes the profile with a **Verified SQLite Food Database** and queries the AI.
3.  **Intelligent Generation:** The AI act as a medical nutritionist, generating a meal plan using specific Malaysian culinary styles.
4.  **Interactive Tracking:** Users log meals via manual entry or the **AI Vision Plate Scanner**. The app validates timings using **Programmed Time Logic**.

## 🏗️ Architecture Standards
*   **Service-Oriented Design:** Clear separation between UI, State (Provider), and Services (AI, PDF, DB).
*   **Structured JSON Output:** AI responses are constrained by a strict schema for 100% UI stability.
*   **Offline First:** The app is designed to be fully functional without internet, using cached plans as a fallback.

---

## ⚙️ Getting Started

### Prerequisites
*   Flutter SDK (Stable)
*   Android Studio / VS Code
*   A Gemini AI API Key

### Installation
1.  Clone the repository.
2.  Install dependencies: `flutter pub get`.
3.  Create a `.env` file in the root directory:
    ```env
    GEMINI_API_KEY=your_key_here
    ```
4.  Run the app: `flutter run`.

---

**Developed with ❤️ for the health and dignity of Malaysian Seniors.**
