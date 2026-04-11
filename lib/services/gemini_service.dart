import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
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
    HEALTH GOAL: ${profile.goal}.
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

  /// Handles Chat with AI Nutritionist
  Future<String> getChatResponse(UserProfile profile, List<ChatMessage> history, String userMessage) async {
    final chatModel = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? "",
    );

    final historyContext = history.take(10).map((m) => "${m.isUser ? 'User' : 'Assistant'}: ${m.text}").join("\n");

    final prompt = """
    You are a professional medical nutritionist in Malaysia helping a user named ${profile.name}.
    User Profile: ${profile.toPromptString()}
    User Goal: ${profile.goal}.
    
    Previous Conversation:
    $historyContext
    
    Current User Question: $userMessage
    
    Instructions:
    - Provide helpful, medically accurate, and culturally appropriate nutritional advice.
    - Keep responses concise (2-3 sentences).
    - If they ask about local Malaysian food, be specific about ingredients or cooking styles.
    """;

    try {
      final response = await chatModel.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      return "Error connecting to nutritionist: $e";
    }
  }

  /// 🟢 AI VISION - Analyze meal image
  Future<Map<String, dynamic>?> analyzeMealImage(Uint8List imageBytes, String mimeType) async {
    final prompt = """
    Act as an AI nutritionist specialized in Malaysian cuisine. 
    Analyze this photo of a meal. Identify the main dish and estimate the calories.
    
    OUTPUT: Provide a JSON object exactly matching this schema:
    {
      "dishName": "string (name of the dish)",
      "calories": int (estimated calories),
      "ingredients": "string (comma separated list of visible ingredients)"
    }
    """;

    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ])
      ]);

      if (response.text != null) {
        return json.decode(response.text!);
      }
    } catch (e) {
      debugPrint("🔴 Vision Error: $e");
    }
    return null;
  }
}
