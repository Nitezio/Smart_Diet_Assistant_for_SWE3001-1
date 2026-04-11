import 'dart:math'; // Import for Random
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_profile.dart';
import '../providers/app_state.dart';

class GeminiService {
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
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      debugPrint("🔴 ERROR: API Key is missing or default.");
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  /// Generates a meal plan based on user profile and local food database constraints.
  Future<String> generateMealPlan(UserProfile profile, List<FoodItem> foodDb) async {
    final randomTheme = _culinaryThemes[Random().nextInt(_culinaryThemes.length)];
    
    // AI Context Sync: Formatting Food Database items for the prompt
    final safeFoods = foodDb.where((f) => !f.isWarning).map((f) => f.name).join(', ');
    final warningFoods = foodDb.where((f) => f.isWarning).map((f) => "${f.name} (${f.details})").join(', ');

    final prompt = """
    Act as a professional medical nutritionist for an elderly person in Malaysia.
    User Profile: ${profile.toPromptString()}
    
    VERIFIED FOOD DATABASE CONTEXT:
    - Highly Recommended (Safe): $safeFoods.
    - Strictly Avoid/Limit: $warningFoods.
    
    Generate a FRESH 1-Day Meal Plan using LOCAL MALAYSIAN DISHES.
    
    VARIATION INSTRUCTION: $randomTheme
    (Do not repeat generic meals. Offer variety so the user does not get bored).
    
    STRICT OUTPUT FORMAT (Plain text, no markdown):
    Breakfast: [Local Dish Name] - [Brief Ingredients] (Approx. [Calories] kcal)
    Lunch: [Local Dish Name] - [Brief Ingredients] (Approx. [Calories] kcal)
    Dinner: [Local Dish Name] - [Brief Ingredients] (Approx. [Calories] kcal)
    Snack: [Local Kuih/Fruit] (Approx. [Calories] kcal)
    Reasoning: [1 sentence medical explanation why this fits their condition]
    Nutrients: [Total Calories] kcal, [Protein]g
    """;

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
