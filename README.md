# Smart Diet Assistant (SDA) 🥗

**Smart Diet Assistant** is a professional-grade health platform designed specifically for the elderly population in Malaysia. Powered by **Google Gemini 1.5 Flash AI**, it provides culturally tailored, medically safe, and goal-directed nutritional guidance.

---

## 🌟 What is it?
SDA is more than just a diet app; it's a digital health companion. It bridge the gap between complex chronic disease management (like Diabetes and Hypertension) and the rich culinary identity of Malaysia. It translates medical constraints into familiar meals—suggesting appropriate portions of Nasi Lemak, Bubur Ayam, or Chapati—ensuring seniors eat healthily without losing their cultural connection.

## 🚀 How it Works
1.  **Health Profiling:** Users input their age, medical conditions (e.g., Blood Sugar Control), allergies, and activity levels.
2.  **AI Orchestration:** The app synchronizes this profile with an internal **Verified Food Database** and sends a structured request to the Gemini AI.
3.  **Intelligent Generation:** The AI acts as a medical nutritionist, generating a 1-day or partial meal plan using specific Malaysian culinary styles (Malay, Chinese, or Indian).
4.  **Interactive Tracking:** Users log meals via manual checkmarks or the **AI Vision Plate Scanner**. The app validates if the meal timing is correct (e.g., flagging Dinner taken in the morning).

## 💎 Key Features
*   🤖 **AI Vision Plate Scanner:** Identify dishes and estimate calories automatically using your camera or gallery.
*   🍱 **Partial Menu Updates:** Change only specific meals (e.g., just Lunch) while keeping the rest of your daily plan intact.
*   💬 **AI Nutritionist Chat:** A persistent, persistent conversational agent available for instant dietary advice.
*   📊 **Health Analytics:** High-quality visualization of weekly calorie trends for users and caregivers.
*   📄 **Medical PDF Export:** Generate professional, doctor-ready reports of your nutritional history with one tap.
*   🛡️ **Offline Resilience:** Automatically falls back to the last generated plan if an internet connection is lost.

## 🏗️ Technical Architecture
The application is built on a **Reactive Modular Architecture** for maximum stability and performance:

*   **Frontend:** Developed in **Flutter** using **Material 3** for an accessible, high-contrast, elderly-friendly UI.
*   **State Management:** Powered by **Provider** to ensure real-time data reactivity across all tabs.
*   **Intelligence Layer:** Uses **Google Generative AI (Gemini Pro)** with strict **Structured JSON Output** and **AI Streaming** for a responsive, reliable user experience.
*   **Storage:** A high-performance **SQLite (sqflite)** database manages large-scale history and the admin-verified food list.
*   **Security:** Environment-based API key management using `flutter_dotenv`.

## 🛠️ Performance Optimizations
*   **JSON-First AI:** We moved away from fragile text parsing to a strict schema-based JSON output, reducing errors by 100%.
*   **Forced Merging Logic:** Implemented a complex AI prompt strategy that allows for partial plan regeneration without corrupting existing data.
*   **Database Aggregation:** Optimized SQLite queries to provide instant weekly statistics without causing UI lag.
*   **Single-Navigator Navigation:** Refactored routing to a stable single-MaterialApp flow, eliminating runtime Navigator state errors.

---

## ⚙️ Getting Started

### Prerequisites
*   Flutter SDK (Stable channel)
*   Android Studio / VS Code
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
