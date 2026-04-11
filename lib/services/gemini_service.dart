import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_profile.dart';
import '../models/meal_plan.dart';
import '../providers/app_state.dart';

class GeminiService {
  late final GenerativeModel _model;

  final List<String> _culinaryThemes = [
    "Focus on comforting Soups and Porridges (Bubur/Sup).",
    "Focus on Light Rice dishes (Nasi Ayam/Nasi Air).",
    "Focus on Noodle/Mee options (Mee Sup/Kway Teow).",
    "Focus on Traditional Kampung flavors (Masak Lemak/Pindang).",
    "Focus on Steamed and clear broth dishes (Chinese Muslim style)."
  ];

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<bool> hasInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Generates a meal plan stream. Returns JSON string chunks.
  Stream<String> generateMealPlanStream(
    UserProfile profile, 
    List<FoodItem> foodDb, 
    {String? cuisineType, List<String>? mealsToChange, String? currentPlan}
  ) async* {
    final randomTheme = _culinaryThemes[Random().nextInt(_culinaryThemes.length)];
    final safeFoods = foodDb.where((f) => !f.isWarning).map((f) => f.name).join(', ');
    final warningFoods = foodDb.where((f) => f.isWarning).map((f) => "${f.name} (${f.details})").join(', ');

    String cuisineInstruction = cuisineType != null && cuisineType != "Surprise me (Random)"
        ? "STRICTLY focus on $cuisineType Malaysian Cuisine."
        : "Use a mix of Malay, Chinese, and Indian Malaysian cuisines.";

    String partialContext = (mealsToChange != null && currentPlan != null && mealsToChange.isNotEmpty)
        ? "CURRENT PLAN TO MERGE: $currentPlan. REGENERATE ONLY: ${mealsToChange.join(', ')}."
        : "NEW PLAN GENERATION.";

    final prompt = """
    Act as a professional medical nutritionist for an elderly person in Malaysia.
    User Profile: ${profile.toPromptString()}
    VERIFIED FOOD DATABASE: Safe: $safeFoods. Avoid: $warningFoods.
    $partialContext
    CUISINE: $cuisineInstruction. THEME: $randomTheme.
    
    OUTPUT: Provide a JSON object exactly matching this schema:
    {
      "breakfast": {"dishName": "string", "ingredients": "string", "calories": int},
      "lunch": {"dishName": "string", "ingredients": "string", "calories": int},
      "dinner": {"dishName": "string", "ingredients": "string", "calories": int},
      "snack": {"dishName": "string", "ingredients": "string", "calories": int},
      "reasoning": "string (1 sentence)",
      "totalCalories": int,
      "protein": int
    }
    """;

    try {
      final content = [Content.text(prompt)];
      final responseStream = _model.generateContentStream(content);

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield "ERROR: $e";
    }
  }
}
