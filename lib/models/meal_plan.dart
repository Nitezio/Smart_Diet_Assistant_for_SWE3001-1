class Meal {
  final String dishName;
  final String ingredients;
  final int calories;

  Meal({
    required this.dishName,
    required this.ingredients,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
    'dishName': dishName,
    'ingredients': ingredients,
    'calories': calories,
  };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    dishName: json['dishName'] ?? '',
    ingredients: json['ingredients'] ?? '',
    calories: json['calories'] ?? 400,
  );
}

class MealPlan {
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final Meal snack;
  final String reasoning;
  final int totalCalories;
  final int protein;

  MealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
    required this.reasoning,
    required this.totalCalories,
    required this.protein,
  });

  Map<String, dynamic> toJson() => {
    'breakfast': breakfast.toJson(),
    'lunch': lunch.toJson(),
    'dinner': dinner.toJson(),
    'snack': snack.toJson(),
    'reasoning': reasoning,
    'totalCalories': totalCalories,
    'protein': protein,
  };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    breakfast: Meal.fromJson(json['breakfast'] ?? {}),
    lunch: Meal.fromJson(json['lunch'] ?? {}),
    dinner: Meal.fromJson(json['dinner'] ?? {}),
    snack: Meal.fromJson(json['snack'] ?? {}),
    reasoning: json['reasoning'] ?? '',
    totalCalories: json['totalCalories'] ?? 0,
    protein: json['protein'] ?? 0,
  );
}

// 🟢 NEW: Model for Chat Messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});

  Map<String, dynamic> toJson() => {'text': text, 'isUser': isUser, 'timestamp': timestamp.toIso8601String()};
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
