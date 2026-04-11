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
  List<String> _loggedMeals = []; // IDs or names of meals logged today (e.g., "Breakfast")

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

    // 3. Load Food DB (Optional: in case admin edits persisted)
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('current_meal_plan');
    await prefs.remove('meal_plan_date');
    await prefs.remove('consumed_calories');
    await prefs.remove('logged_meals');
    notifyListeners();
  }

  Future<void> getDietPlan() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    
    // AI Context Sync: Passing Food Database to AI
    _currentMealPlan = await _aiService.generateMealPlan(_user!, _foodDatabase);
    
    _isLoading = false;
    
    // Persist session
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('current_meal_plan', _currentMealPlan!);
    await prefs.setString('meal_plan_date', today);
    
    // Reset daily logs on fresh generation
    _consumedCalories = 0;
    _loggedMeals = [];
    await prefs.setInt('consumed_calories', 0);
    await prefs.setStringList('logged_meals', []);
    
    notifyListeners();
  }

  void logMeal(String mealType, int calories) async {
    if (_loggedMeals.contains(mealType)) return; // Prevent double logging

    _consumedCalories += calories;
    _loggedMeals.add(mealType);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consumed_calories', _consumedCalories);
    await prefs.setStringList('logged_meals', _loggedMeals);
    
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
