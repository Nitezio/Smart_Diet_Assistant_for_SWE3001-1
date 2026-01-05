import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/gemini_service.dart';

class AppState with ChangeNotifier {
  final GeminiService _aiService = GeminiService();

  UserProfile? _user;
  String? _currentMealPlan;
  bool _isLoading = false;

  UserProfile? get user => _user;
  String? get currentMealPlan => _currentMealPlan;
  bool get isLoading => _isLoading;

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
}