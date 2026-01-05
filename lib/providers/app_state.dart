import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/gemini_service.dart';

// Simple Model for Food Items
class FoodItem {
  String id;
  String name;
  String details;
  bool isWarning; // True = Red flag (e.g. High Sugar), False = Green flag (Safe)

  FoodItem({required this.id, required this.name, required this.details, required this.isWarning});
}

class AppState with ChangeNotifier {
  final GeminiService _aiService = GeminiService();

  UserProfile? _user;
  String? _currentMealPlan;
  bool _isLoading = false;
  String _selectedRole = 'Elderly';

  // --- ADMIN DATA (FOOD DATABASE) ---
  // Initial Mock Data
  final List<FoodItem> _foodDatabase = [
    FoodItem(id: '1', name: "Nasi Lemak", details: "High Fat, High Sodium", isWarning: true),
    FoodItem(id: '2', name: "Teh Tarik", details: "High Sugar (Avoid for Diabetics)", isWarning: true),
    FoodItem(id: '3', name: "Bubur Ayam", details: "Safe: Easy Chew, Low Fat", isWarning: false),
    FoodItem(id: '4', name: "Steamed Fish", details: "Safe: High Protein, Healthy Fats", isWarning: false),
    FoodItem(id: '5', name: "Roti Canai", details: "High Fat, Low Nutritional Value", isWarning: true),
  ];

  // Getters
  UserProfile? get user => _user;
  String? get currentMealPlan => _currentMealPlan;
  bool get isLoading => _isLoading;
  String get selectedRole => _selectedRole;
  List<FoodItem> get foodDatabase => _foodDatabase;

  // --- ROLE & USER LOGIC ---
  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setUser(UserProfile profile) {
    _user = profile;
    notifyListeners();
  }

  Future<void> getDietPlan() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    _currentMealPlan = await _aiService.generateMealPlan(_user!);
    _isLoading = false;
    notifyListeners();
  }

  // --- CRUD OPERATIONS FOR FOOD DB ---

  // 1. CREATE
  void addFood(String name, String details, bool isWarning) {
    final newItem = FoodItem(
        id: DateTime.now().toString(), // Simple unique ID
        name: name,
        details: details,
        isWarning: isWarning
    );
    _foodDatabase.add(newItem);
    notifyListeners();
  }

  // 2. UPDATE
  void updateFood(String id, String newName, String newDetails, bool newIsWarning) {
    final index = _foodDatabase.indexWhere((item) => item.id == id);
    if (index != -1) {
      _foodDatabase[index] = FoodItem(
          id: id,
          name: newName,
          details: newDetails,
          isWarning: newIsWarning
      );
      notifyListeners();
    }
  }

  // 3. DELETE
  void deleteFood(String id) {
    _foodDatabase.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}