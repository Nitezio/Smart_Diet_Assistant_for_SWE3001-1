import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _condCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  String _gender = "Male";
  String _activityLevel = "Moderate";

  void _save(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // 1. Get the selected role from the Provider
      final role = Provider.of<AppState>(context, listen: false).selectedRole;

      final profile = UserProfile(
        role: role, // 🟢 FIXED: Passing the required 'role' here
        name: _nameCtrl.text,
        age: int.tryParse(_ageCtrl.text) ?? 60,
        gender: _gender,
        weight: double.tryParse(_weightCtrl.text) ?? 70.0,
        height: double.tryParse(_heightCtrl.text) ?? 165.0,
        activityLevel: _activityLevel,
        conditions: _condCtrl.text.split(','),
        allergies: _allergyCtrl.text.split(','),
      );

      Provider.of<AppState>(context, listen: false).setUser(profile);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get role to change title text (UX improvement)
    final role = Provider.of<AppState>(context).selectedRole;
    final isManagingSelf = role == 'Elderly';
    final titleText = isManagingSelf ? "Setup Your Profile" : "Setup Patient Profile";
    final nameLabel = isManagingSelf ? "Full Name" : "Patient's Name";

    return Scaffold(
      appBar: AppBar(title: Text(titleText), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text(
                "Please enter health details for accurate AI diet planning.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14)
            ),
            const SizedBox(height: 20),

            const Text("Personal Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: nameLabel, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person)),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                  keyboardType: TextInputType.number
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField(
                value: _gender,
                items: ["Male", "Female"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _gender = v!),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Gender"),
              )),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.monitor_weight)),
                  keyboardType: TextInputType.number
              )),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(
                  controller: _heightCtrl,
                  decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.height)),
                  keyboardType: TextInputType.number
              )),
            ]),

            const SizedBox(height: 25),
            const Text("Health Context", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),

            TextFormField(
                controller: _condCtrl,
                decoration: const InputDecoration(
                    labelText: "Medical Conditions (e.g. Diabetes, Hypertension)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital)
                )
            ),
            const SizedBox(height: 10),
            TextFormField(
                controller: _allergyCtrl,
                decoration: const InputDecoration(
                    labelText: "Allergies (e.g. Peanuts, Seafood)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning)
                )
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: _activityLevel,
              decoration: const InputDecoration(labelText: "Activity Level", border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_run)),
              items: ["Sedentary", "Moderate", "Active"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () => _save(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("Save Health Profile", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}