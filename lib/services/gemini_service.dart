import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';

class GeminiService {
  // 🔴 Ensure your API Key is correct here
  static const String _apiKey = "AIzaSyD2KIl0H3a9F-ptCRnNMKFmJfmj89aX0gQ";

  late final GenerativeModel _model;

  GeminiService() {
    // Using the efficient flash model
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> generateMealPlan(UserProfile profile) async {
    final prompt = '''
      Act as a professional medical nutritionist for an elderly person in Malaysia.
      User Profile: ${profile.toPromptString()}
      
      Generate a 1-Day Meal Plan using LOCAL MALAYSIAN DISHES.
      
      STRICT OUTPUT FORMAT (Plain text, no markdown):
      Breakfast: [Local Dish Name] - [Brief Ingredients]
      Lunch: [Local Dish Name] - [Brief Ingredients]
      Dinner: [Local Dish Name] - [Brief Ingredients]
      Snack: [Local Kuih/Fruit]
      Reasoning: [1 sentence medical explanation why this fits their condition]
      Nutrients: [Total Calories] kcal, [Protein]g
    ''';

    debugPrint("🔵 STATUS: Connecting to Google AI (Malaysian Context)...");

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