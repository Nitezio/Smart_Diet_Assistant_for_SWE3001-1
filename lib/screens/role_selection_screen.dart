import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              const Icon(FontAwesomeIcons.users, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Welcome to\nSmart Diet Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please select your role to continue",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(flex: 1),

              // --- MAIN ROLES (Big Buttons) ---
              _buildRoleButton(
                  context,
                  "Elderly User",
                  "I am using this for myself",
                  FontAwesomeIcons.personCane,
                  "Elderly"
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                  context,
                  "Caregiver",
                  "I care for an elderly patient",
                  FontAwesomeIcons.userNurse,
                  "Caregiver"
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                  context,
                  "Family Member",
                  "I am tracking a relative's diet",
                  FontAwesomeIcons.houseUser,
                  "Family"
              ),

              const Spacer(flex: 2),

              // --- ADMIN ROLE (Small, Bottom Center) ---
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate directly to Admin Login
                    Navigator.pushNamed(context, '/admin_login');
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.grey),
                  label: const Text(
                      "Admin Access",
                      style: TextStyle(color: Colors.grey, fontSize: 14)
                  ),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, String subtitle, IconData icon, String roleKey) {
    return InkWell(
      onTap: () {
        // Save role and go to Standard User Login
        Provider.of<AppState>(context, listen: false).setRole(roleKey);
        Navigator.pushNamed(context, '/login');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
          ],
        ),
      ),
    );
  }
}