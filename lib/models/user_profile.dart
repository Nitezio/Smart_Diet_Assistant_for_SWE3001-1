class UserProfile {
  String role;
  String name;
  int age;
  String gender;
  double weight;
  double height;
  String activityLevel;
  List<String> conditions;
  List<String> allergies;

  UserProfile({
    required this.role,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.conditions,
    required this.allergies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      role: json['role'] ?? 'Elderly',
      name: json['name'] ?? '',
      age: json['age'] ?? 60,
      gender: json['gender'] ?? 'Male',
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      height: (json['height'] as num?)?.toDouble() ?? 165.0,
      activityLevel: json['activityLevel'] ?? 'Moderate',
      conditions: List<String>.from(json['conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'activityLevel': activityLevel,
      'conditions': conditions,
      'allergies': allergies,
    };
  }

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