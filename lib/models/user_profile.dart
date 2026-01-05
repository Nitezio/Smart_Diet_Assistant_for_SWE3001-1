class UserProfile {
  String name;
  int age;
  String gender;
  double weight;
  List<String> conditions; // e.g., Diabetes, Hypertension
  List<String> allergies;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.conditions,
    required this.allergies,
  });

  // Converts data to a prompt string for Gemini
  String toPromptString() {
    return "Profile: $age year old $gender, weight ${weight}kg. Medical Conditions: ${conditions.join(', ')}. Allergies: ${allergies.join(', ')}.";
  }
}