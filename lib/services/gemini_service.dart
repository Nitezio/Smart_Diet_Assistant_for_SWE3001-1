import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';

class GeminiService {
  // 🔴 Ensure your API Key is correct here
  static const String _apiKey = "AIzaSyD2KIl0H3a9F-ptCRnNMKFmJfmj89aX0gQ";

  late final GenerativeModel _model;

  GeminiService() {
    // 🟢 UPDATED: Using 'gemini-2.5-flash' correctly in Dart
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> generateMealPlan(UserProfile profile) async {
    final prompt = '''
      Act as a professional medical nutritionist for an elderly patient.
      Patient Profile: ${profile.toPromptString()}
      
      Generate a customized 1-day meal plan.
      
      STRICT OUTPUT FORMAT (No markdown, no bolding, plain text only):
      Breakfast: [Meal Name] - [Ingredients]
      Lunch: [Meal Name] - [Ingredients]
      Dinner: [Meal Name] - [Ingredients]
      Snack: [Snack Name]
      Reasoning: [1 sentence medical explanation]
      Nutrients: [Total Calories], [Protein amount]
    ''';

    print("🔵 STATUS: Connecting to Google AI (Model: gemini-2.5-flash)...");

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        print("🟢 SUCCESS: Received ${response.text!.length} characters from Google!");
        return response.text!;
      } else {
        return "Error: AI returned empty response.";
      }

    } catch (e) {
      print("🔴 ERROR: Connection failed. Reason: $e");
      return "Error: $e";
    }
  }
}