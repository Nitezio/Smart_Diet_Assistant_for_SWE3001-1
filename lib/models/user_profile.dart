class UserProfile {
  String role;
  String name;
  int age;
  String gender;
  double weight;
  double height;
  String activityLevel;
  String goal;
  List<String> conditions;
  List<String> allergies;
  String? connectionCode; // 🟢 NEW: 7-char alphanumeric code for linking family

  UserProfile({
    required this.role,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.goal,
    required this.conditions,
    required this.allergies,
    this.connectionCode,
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
      goal: json['goal'] ?? 'Healthy Aging',
      conditions: List<String>.from(json['conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      connectionCode: json['connectionCode'],
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
      'goal': goal,
      'conditions': conditions,
      'allergies': allergies,
      'connectionCode': connectionCode,
    };
  }

  String toPromptString() {
    return """
    User Role: $role.
    Profile Name: $name.
    Goal: $goal.
    Details: $age year old $gender living in Malaysia.
    Body: Weight ${weight}kg, Height ${height}cm.
    Activity: $activityLevel.
    Medical Conditions: ${conditions.join(', ')}.
    Allergies: ${allergies.join(', ')}.
    
    CONTEXT:
    - Requirement: Local Malaysian Cuisine (Halal).
    - Advice should align with the specific GOAL of $goal.
    """;
  }
}
