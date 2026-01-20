import 'dart:math'; // Import for Random
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';

class GeminiService {
  // 🔴 Ensure your API Key is correct here
  static const String _apiKey = "ENTER YOUR API KEY HERE";

  late final GenerativeModel _model;

  // List of variations to ensure the elderly don't get bored
  final List<String> _culinaryThemes = [
    "Focus on comforting Soups and Porridges (Bubur/Sup).",
    "Focus on Light Rice dishes (Nasi Ayam/Nasi Air).",
    "Focus on Noodle/Mee options (Mee Sup/Kway Teow).",
    "Focus on Traditional Kampung flavors (Masak Lemak/Pindang).",
    "Focus on Steamed and clear broth dishes (Chinese Muslim style)."
  ];

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> generateMealPlan(UserProfile profile) async {
    // 1. Pick a random theme to ensure variety
    final randomTheme = _culinaryThemes[Random().nextInt(_culinaryThemes.length)];

    final prompt = '''
      Act as a professional medical nutritionist for an elderly person in Malaysia.
      User Profile: ${profile.toPromptString()}
      
      Generate a FRESH 1-Day Meal Plan using LOCAL MALAYSIAN DISHES.
      
      VARIATION INSTRUCTION: $randomTheme
      (Do not repeat generic meals. Offer variety so the user does not get bored).
      
      STRICT OUTPUT FORMAT (Plain text, no markdown):
      Breakfast: [Local Dish Name] - [Brief Ingredients]
      Lunch: [Local Dish Name] - [Brief Ingredients]
      Dinner: [Local Dish Name] - [Brief Ingredients]
      Snack: [Local Kuih/Fruit]
      Reasoning: [1 sentence medical explanation why this fits their condition]
      Nutrients: [Total Calories] kcal, [Protein]g
    ''';

    debugPrint("🔵 STATUS: Connecting to Google AI with Theme: $randomTheme...");

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        debugPrint("🟢 SUCCESS: Received response!");
        return response.text!;
      } else {
        return "Error: AI returned empty response.";
      }
    } catch (e) {
      debugPrint("🔴 ERROR: Connection failed. Reason: $e");
      return "Error: $e";
    }
  }
}