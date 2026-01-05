class UserProfile {
  String name;
  int age;
  String gender;
  double weight; // kg
  double height; // cm [SRS FR-01.4]
  String activityLevel; // [SRS FR-01.4]
  List<String> conditions; // e.g., Diabetes
  List<String> allergies;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.conditions,
    required this.allergies,
  });

  // Updated to specifically request MALAYSIAN cuisine [SRS FR-03.2]
  String toPromptString() {
    return """
    Profile: $age year old $gender living in Malaysia.
    Weight: ${weight}kg, Height: ${height}cm.
    Activity Level: $activityLevel.
    Medical Conditions: ${conditions.join(', ')}.
    Allergies: ${allergies.join(', ')}.
    
    CRITICAL CONTEXT:
    - User requires Local Malaysian Cuisine (Halal preferred).
    - If Diabetic: Suggest low-GI options (e.g., Basmati rice, less sugar).
    - If Hypertensive: Suggest low sodium (kurang manis/masin).
    """;
  }
}