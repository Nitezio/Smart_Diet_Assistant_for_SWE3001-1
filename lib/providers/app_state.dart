import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/meal_plan.dart';
import '../services/gemini_service.dart';
import '../services/database_helper.dart';

class FoodItem {
  String id;
  String name;
  String details;
  bool isWarning;
  FoodItem({required this.id, required this.name, required this.details, required this.isWarning});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'details': details, 'isWarning': isWarning ? 1 : 0};
  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'],
    name: json['name'],
    details: json['details'],
    isWarning: json['isWarning'] == 1 || json['isWarning'] == true,
  );
}

class MealHistoryItem {
  final String mealType;
  final String dishName;
  final int calories;
  final DateTime timestamp;
  MealHistoryItem({required this.mealType, required this.dishName, required this.calories, required this.timestamp});
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
  final DatabaseHelper _db = DatabaseHelper.instance;

  UserProfile? _user;
  MealPlan? _currentMealPlan;
  bool _isLoading = false;
  String _selectedRole = 'Elderly';
  bool _isProfileLoaded = false;

  // --- PERSISTENCE DATA ---
  int _consumedCalories = 0;
  final int _calorieGoal = 1800;
  List<String> _loggedMeals = []; 
  List<MealHistoryItem> _history = []; 
  List<FoodItem> _foodDatabase = [];
  
  // --- 🟢 NEW: CHAT DATA ---
  List<ChatMessage> _chatHistory = [];
  bool _isTyping = false;

  AppState() {
    _init();
  }

  // Getters
  UserProfile? get user => _user;
  MealPlan? get currentMealPlan => _currentMealPlan;
  bool get isLoading => _isLoading;
  String get selectedRole => _selectedRole;
  List<FoodItem> get foodDatabase => _foodDatabase;
  bool get isProfileLoaded => _isProfileLoaded;
  int get consumedCalories => _consumedCalories;
  int get calorieGoal => _calorieGoal;
  List<MealHistoryItem> get history => _history;
  List<String> get loggedMeals => _loggedMeals;
  List<ChatMessage> get chatHistory => _chatHistory;
  bool get isTyping => _isTyping;

  Future<void> _init() async {
    await _loadProfile();
    await _syncFromDatabase();
    await _loadDailyState();
    await _loadChatHistory();
    _isProfileLoaded = true;
    notifyListeners();
  }

  Future<void> _syncFromDatabase() async {
    _foodDatabase = await _db.getAllFood();
    if (_foodDatabase.isEmpty) {
      _foodDatabase = [
        FoodItem(id: '1', name: "Nasi Lemak", details: "High Fat, High Sodium", isWarning: true),
        FoodItem(id: '2', name: "Teh Tarik", details: "High Sugar (Avoid for Diabetics)", isWarning: true),
        FoodItem(id: '3', name: "Bubur Ayam", details: "Safe: Easy Chew, Low Fat", isWarning: false),
        FoodItem(id: '4', name: "Steamed Fish", details: "Safe: High Protein, Healthy Fats", isWarning: false),
        FoodItem(id: '5', name: "Roti Canai", details: "High Fat, Low Nutritional Value", isWarning: true),
      ];
      for (var item in _foodDatabase) { await _db.insertFood(item); }
    }
    _history = await _db.getAllHistory();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = prefs.getString('user_profile');
    if (profileData != null) {
      _user = UserProfile.fromJson(json.decode(profileData));
      _selectedRole = _user!.role;
    }
  }

  Future<void> _loadDailyState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('meal_plan_date');
    if (savedDate == today) {
      final planData = prefs.getString('current_meal_plan_json');
      if (planData != null) { _currentMealPlan = MealPlan.fromJson(json.decode(planData)); }
      _consumedCalories = prefs.getInt('consumed_calories') ?? 0;
      _loggedMeals = prefs.getStringList('logged_meals') ?? [];
    }
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      final List decoded = json.decode(data);
      _chatHistory = decoded.map((e) => ChatMessage.fromJson(e)).toList();
    }
  }

  // --- ACTIONS ---

  void setRole(String role) { _selectedRole = role; notifyListeners(); }

  void setUser(UserProfile profile) {
    _user = profile;
    _saveProfile(profile);
    notifyListeners();
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
  }

  Future<void> logout() async {
    _user = null;
    _currentMealPlan = null;
    _chatHistory = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _db.clearAllData();
    _history = [];
    notifyListeners();
  }

  // --- 🟢 CHAT LOGIC ---
  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty || _user == null) return;

    // 1. Add User Message
    final userMsg = ChatMessage(text: message, isUser: true, timestamp: DateTime.now());
    _chatHistory.add(userMsg);
    _isTyping = true;
    notifyListeners();

    // 2. Get AI Response
    final aiResponse = await _aiService.getChatResponse(_user!, _chatHistory, message);
    
    // 3. Add AI Message
    final aiMsg = ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now());
    _chatHistory.add(aiMsg);
    _isTyping = false;
    
    // 4. Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(_chatHistory.map((e) => e.toJson()).toList()));
    
    notifyListeners();
  }

  Future<void> getDietPlan({String? cuisineType, List<String>? mealsToChange}) async {
    if (_user == null) return;

    bool online = await _aiService.hasInternet();
    if (!online && _currentMealPlan != null) return;

    _isLoading = true;
    notifyListeners();

    final currentPlanStr = _currentMealPlan != null ? json.encode(_currentMealPlan!.toJson()) : null;
    final stream = _aiService.generateMealPlanStream(_user!, _foodDatabase, cuisineType: cuisineType, mealsToChange: mealsToChange, currentPlan: currentPlanStr);

    String buffer = "";
    await for (final chunk in stream) {
      if (chunk.startsWith("ERROR")) break;
      buffer += chunk;
    }

    try {
      _currentMealPlan = MealPlan.fromJson(json.decode(buffer));
      if (mealsToChange == null || mealsToChange.length >= 4) {
        _consumedCalories = 0;
        _loggedMeals = [];
      } else {
        _loggedMeals.removeWhere((m) => mealsToChange.contains(m));
        _recalculateCalories();
      }
      _persistDailyState();
    } catch (e) { debugPrint("JSON Error: $e"); }

    _isLoading = false;
    notifyListeners();
  }

  void _recalculateCalories() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _consumedCalories = _history.where((item) => DateFormat('yyyy-MM-dd').format(item.timestamp) == today).fold(0, (sum, item) => sum + item.calories);
  }

  Future<void> _persistDailyState() async {
    if (_currentMealPlan == null) return;
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('current_meal_plan_json', json.encode(_currentMealPlan!.toJson()));
    await prefs.setString('meal_plan_date', today);
    await prefs.setInt('consumed_calories', _consumedCalories);
    await prefs.setStringList('logged_meals', _loggedMeals);
  }

  void logMeal(String mealType, String dishName, int calories) async {
    if (_loggedMeals.contains(mealType)) return;
    _consumedCalories += calories;
    _loggedMeals.add(mealType);
    final item = MealHistoryItem(mealType: mealType, dishName: dishName, calories: calories, timestamp: DateTime.now());
    _history.insert(0, item);
    await _db.insertHistory(item);
    _persistDailyState();
    notifyListeners();
  }

  // --- FOOD DB CRUD ---
  void addFood(String name, String details, bool isWarning) async {
    final item = FoodItem(id: DateTime.now().toString(), name: name, details: details, isWarning: isWarning);
    _foodDatabase.add(item); await _db.insertFood(item); notifyListeners();
  }
  void updateFood(String id, String newName, String newDetails, bool newIsWarning) async {
    final index = _foodDatabase.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = FoodItem(id: id, name: newName, details: newDetails, isWarning: newIsWarning);
      _foodDatabase[index] = item; await _db.updateFood(item); notifyListeners();
    }
  }
  void deleteFood(String id) async { _foodDatabase.removeWhere((item) => item.id == id); await _db.deleteFood(id); notifyListeners(); }
}
