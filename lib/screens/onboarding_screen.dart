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
  final _condCtrl = TextEditingController(); // e.g. Diabetes
  final _allergyCtrl = TextEditingController();

  String _gender = "Male";
  String _activityLevel = "Moderate";

  void _save(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
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
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Health Profile")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text("Personal Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(controller: _ageCtrl, decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField(
                value: _gender,
                items: ["Male", "Female"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _gender = v!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(controller: _weightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(controller: _heightCtrl, decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 20),
            const Text("Health Context", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(controller: _condCtrl, decoration: const InputDecoration(labelText: "Medical Conditions (e.g. Diabetes)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextFormField(controller: _allergyCtrl, decoration: const InputDecoration(labelText: "Allergies", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: _activityLevel,
              decoration: const InputDecoration(labelText: "Activity Level", border: OutlineInputBorder()),
              items: ["Sedentary", "Moderate", "Active"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _save(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
              child: const Text("Create Profile", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}