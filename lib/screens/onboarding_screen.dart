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
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _condCtrl = TextEditingController(); // e.g. Diabetes
  final _allergyCtrl = TextEditingController();

  void _save(BuildContext context) {
    final profile = UserProfile(
      name: _nameCtrl.text,
      age: int.tryParse(_ageCtrl.text) ?? 70,
      gender: "Male", // Hardcoded for prototype simplicity
      weight: 70.0,
      conditions: _condCtrl.text.split(','),
      allergies: _allergyCtrl.text.split(','),
    );

    Provider.of<AppState>(context, listen: false).setUser(profile);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Health Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person))),
            TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: "Age", prefixIcon: Icon(Icons.calendar_today)), keyboardType: TextInputType.number),
            TextField(controller: _condCtrl, decoration: const InputDecoration(labelText: "Medical Conditions (e.g. Diabetes)", prefixIcon: Icon(Icons.local_hospital))),
            TextField(controller: _allergyCtrl, decoration: const InputDecoration(labelText: "Allergies", prefixIcon: Icon(Icons.warning))),
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