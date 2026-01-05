class UserProfile {
  String role; // Added role field
  String name;
  int age;
  String gender;
  double weight;
  double height;
  String activityLevel;
  List<String> conditions;
  List<String> allergies;

  UserProfile({
    required this.role, // Now required
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.conditions,
    required this.allergies,
  });

  String toPromptString() {
    return """
    User Role: $role (The user is a $role).
    Profile Name: $name.
    Details: $age year old $gender living in Malaysia.
    Body: Weight ${weight}kg, Height ${height}cm.
    Activity: $activityLevel.
    Medical Conditions: ${conditions.join(', ')}.
    Allergies: ${allergies.join(', ')}.
    
    CONTEXT:
    - If Role is Caregiver: The user is managing diet for this patient.
    - If Role is Elderly: The user is managing their own diet.
    - Requirement: Local Malaysian Cuisine (Halal).
    """;
  }
}