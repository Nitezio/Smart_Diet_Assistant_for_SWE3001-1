# Smart Diet Assistant (SDA) 🥗

[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](https://github.com/Nitezio/Smart_Diet_Assistant_for_SWE3001-1)

**Smart Diet Assistant** is a professional-grade health platform designed specifically for the elderly population in Malaysia. Powered by **Google Gemini 1.5 Flash AI**, it provides culturally tailored, medically safe, and goal-directed nutritional guidance.

---

## 🛠️ Core Technology Stack

This project is built with a focus on stability, scalability, and accessibility.

| Technology | Implementation | Version |
|------------|----------------|---------|
| **Framework** | [Flutter](https://flutter.dev/) | Latest (Material 3) |
| **Language** | [Dart](https://dart.dev/) | ^3.7.2 |
| **AI Engine** | [Google Gemini API](https://ai.google.dev/) | ^0.4.0 |
| **Local Database**| [SQLite](https://pub.dev/packages/sqflite) (`sqflite`) | ^2.4.2 |
| **Data Visualization**| [FL Chart](https://pub.dev/packages/fl_chart) | ^1.2.0 |
| **Reporting** | [PDF Engine](https://pub.dev/packages/pdf) | ^3.12.0 |
| **UI Design** | [Material 3](https://m3.material.io/) | Native Implementation |
| **Status** | **Production Ready** | 1.0.0+1 |

---

## 🌟 What is it?
SDA is more than just a diet app; it's a digital health companion. It bridges the gap between complex chronic disease management (like Diabetes and Hypertension) and the rich culinary identity of Malaysia. It translates medical constraints into familiar meals—suggesting appropriate portions of Nasi Lemak, Bubur Ayam, or Chapati—ensuring seniors eat healthily without losing their cultural connection.

## 🚀 How it Works
1.  **Health Profiling:** Users input their health twin (age, conditions, goal, allergies).
2.  **AI Orchestration:** The app synchronizes the profile with a **Verified SQLite Food Database** and queries the AI.
3.  **Intelligent Generation:** The AI acts as a medical nutritionist, generating a meal plan using specific Malaysian culinary styles.
4.  **Interactive Tracking:** Users log meals via manual entry or the **AI Vision Plate Scanner**. The app validates timings using **Programmed Time Logic**.

## 💎 Key Features
*   🤖 **AI Vision Plate Scanner:** Identify dishes and estimate calories automatically using your camera or gallery.
*   🍱 **Partial Menu Updates:** Change only specific meals while keeping the rest of your daily plan intact.
*   💬 **AI Nutritionist Chat:** A persistent conversational agent for instant dietary advice.
*   📊 **Health Analytics:** Visualization of weekly calorie trends for users and caregivers.
*   📄 **Medical PDF Export:** Generate doctor-ready reports of your nutritional history.
*   🛡️ **Offline Resilience:** Automatically falls back to cached plans if internet is lost.

## 🏗️ Architecture Standards
*   **Service-Oriented Design:** Clear separation between UI, State (Provider), and Services.
*   **Structured JSON Output:** AI responses constrained by strict schemas for UI stability.
*   **Persistent SQLite Tracking:** High-performance storage for long-term health history.

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
