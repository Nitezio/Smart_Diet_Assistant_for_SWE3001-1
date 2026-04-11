import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/gemini_service.dart';

// Simple Model for Food Items
class FoodItem {
  String id;
  String name;
  String details;
  bool isWarning;

  FoodItem({required this.id, required this.name, required this.details, required this.isWarning});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'details': details, 'isWarning': isWarning};
  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'],
    name: json['name'],
    details: json['details'],
    isWarning: json['isWarning'],
  );
}

// 🟢 NEW: Model for Meal History
class MealHistoryItem {
  final String mealType;
  final String dishName;
  final int calories;
  final DateTime timestamp;

  MealHistoryItem({
    required this.mealType,
    required this.dishName,
    required this.calories,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'mealType': mealType,
    'dishName': dishName,
    'calories': calories,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MealHistoryItem.fromJson(Map<String, dynamic> json) => MealHistoryItem(
    mealType: json['mealType'],
    dishName: json['dishName'],
    calories: json['calories'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class AppState with ChangeNotifier {
  final GeminiService _aiService = GeminiService();

  UserProfile? _user;
  String? _currentMealPlan;
  bool _isLoading = false;
  String _selectedRole = 'Elderly';
  bool _isProfileLoaded = false;

  // --- PERSISTENCE & LOGGING DATA ---
  int _consumedCalories = 0;
  final int _calorieGoal = 1800;
  List<String> _loggedMeals = []; // IDs of meals logged today (e.g., "Breakfast")
  List<MealHistoryItem> _history = []; // 🟢 Global history list

  // --- ADMIN DATA (FOOD DATABASE) ---
  List<FoodItem> _foodDatabase = [
    FoodItem(id: '1', name: "Nasi Lemak", details: "High Fat, High Sodium", isWarning: true),
    FoodItem(id: '2', name: "Teh Tarik", details: "High Sugar (Avoid for Diabetics)", isWarning: true),
    FoodItem(id: '3', name: "Bubur Ayam", details: "Safe: Easy Chew, Low Fat", isWarning: false),
    FoodItem(id: '4', name: "Steamed Fish", details: "Safe: High Protein, Healthy Fats", isWarning: false),
    FoodItem(id: '5', name: "Roti Canai", details: "High Fat, Low Nutritional Value", isWarning: true),
  ];

  AppState() {
    _loadState();
  }

  // Getters
  UserProfile? get user => _user;
  String? get currentMealPlan => _currentMealPlan;
  bool get isLoading => _isLoading;
  String get selectedRole => _selectedRole;
  List<FoodItem> get foodDatabase => _foodDatabase;
  bool get isProfileLoaded => _isProfileLoaded;
  int get consumedCalories => _consumedCalories;
  int get calorieGoal => _calorieGoal;
  List<String> get loggedMeals => _loggedMeals;
  List<MealHistoryItem> get history => _history; // 🟢 Getter for history

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Load Profile
    final profileData = prefs.getString('user_profile');
    if (profileData != null) {
      try {
        _user = UserProfile.fromJson(json.decode(profileData));
        _selectedRole = _user!.role;
      } catch (e) {
        debugPrint("Error parsing stored profile: $e");
      }
    }

    // 2. Load Meal Plan (if date matches)
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('meal_plan_date');
    if (savedDate == today) {
      _currentMealPlan = prefs.getString('current_meal_plan');
      _consumedCalories = prefs.getInt('consumed_calories') ?? 0;
      _loggedMeals = prefs.getStringList('logged_meals') ?? [];
    }

    // 3. Load Global History
    final historyData = prefs.getString('meal_history');
    if (historyData != null) {
      final List decoded = json.decode(historyData);
      _history = decoded.map((e) => MealHistoryItem.fromJson(e)).toList();
    }

    // 4. Load Food DB
    final dbData = prefs.getString('food_database');
    if (dbData != null) {
      final List decoded = json.decode(dbData);
      _foodDatabase = decoded.map((e) => FoodItem.fromJson(e)).toList();
    }

    _isProfileLoaded = true;
    notifyListeners();
  }

  // --- LOGIC METHODS ---

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setUser(UserProfile profile) {
    _user = profile;
    notifyListeners();
    _saveProfile(profile);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
  }

  Future<void> logout() async {
    _user = null;
    _currentMealPlan = null;
    _consumedCalories = 0;
    _loggedMeals = [];
    _history = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all on logout
    notifyListeners();
  }

  Future<void> getDietPlan({String? cuisineType, List<String>? mealsToChange}) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    
    final newPlan = await _aiService.generateMealPlan(
      _user!, 
      _foodDatabase, 
      cuisineType: cuisineType,
      mealsToChange: mealsToChange,
      currentPlan: _currentMealPlan,
    );

    if (newPlan.startsWith("Error")) {
      _currentMealPlan = newPlan;
    } else {
      _currentMealPlan = newPlan;
      if (mealsToChange == null || mealsToChange.length >= 4) {
        _consumedCalories = 0;
        _loggedMeals = [];
      } else {
        _consumedCalories = 0; 
        _loggedMeals.removeWhere((m) => mealsToChange.contains(m));
      }

      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('current_meal_plan', _currentMealPlan!);
      await prefs.setString('meal_plan_date', today);
      await prefs.setInt('consumed_calories', _consumedCalories);
      await prefs.setStringList('logged_meals', _loggedMeals);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // 🟢 UPDATED: Log meal with history tracking
  void logMeal(String mealType, String dishName, int calories) async {
    if (_loggedMeals.contains(mealType)) return;

    _consumedCalories += calories;
    _loggedMeals.add(mealType);
    
    // Add to History
    _history.insert(0, MealHistoryItem(
      mealType: mealType,
      dishName: dishName,
      calories: calories,
      timestamp: DateTime.now(),
    ));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consumed_calories', _consumedCalories);
    await prefs.setStringList('logged_meals', _loggedMeals);
    await prefs.setString('meal_history', json.encode(_history.map((e) => e.toJson()).toList()));
    
    notifyListeners();
  }

  // --- CRUD OPERATIONS FOR FOOD DB ---
  void addFood(String name, String details, bool isWarning) {
    final newItem = FoodItem(
        id: DateTime.now().toString(),
        name: name,
        details: details,
        isWarning: isWarning
    );
    _foodDatabase.add(newItem);
    _saveFoodDatabase();
    notifyListeners();
  }

  void updateFood(String id, String newName, String newDetails, bool newIsWarning) {
    final index = _foodDatabase.indexWhere((item) => item.id == id);
    if (index != -1) {
      _foodDatabase[index] = FoodItem(
          id: id,
          name: newName,
          details: newDetails,
          isWarning: newIsWarning
      );
      _saveFoodDatabase();
      notifyListeners();
    }
  }

  void deleteFood(String id) {
    _foodDatabase.removeWhere((item) => item.id == id);
    _saveFoodDatabase();
    notifyListeners();
  }

  Future<void> _saveFoodDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_foodDatabase.map((e) => e.toJson()).toList());
    await prefs.setString('food_database', encoded);
  }
}
