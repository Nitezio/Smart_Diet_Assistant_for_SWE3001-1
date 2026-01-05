import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, ${state.user?.name ?? 'Patient'}", style: const TextStyle(fontSize: 18)),
            const Text("Live AI Connection", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Control Panel
            _buildGenerateButton(context, state),

            const SizedBox(height: 20),

            // 2. Dynamic Output Area
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 15),
                    Text("Connecting to Google Gemini...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else if (state.currentMealPlan != null)
              _buildResultView(state.currentMealPlan!),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, AppState state) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text("Generate Real Meal Plan", style: TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        onPressed: state.isLoading ? null : () => state.getDietPlan(),
      ),
    );
  }

  Widget _buildResultView(String planText) {
    // ⚠️ ERROR HANDLING: Check if the text starts with "Error"
    if (planText.startsWith("Error")) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(planText, style: TextStyle(color: Colors.red.shade900))),
          ],
        ),
      );
    }

    // ✅ SUCCESS: Parse the AI text into Cards
    final lines = planText.split('\n');
    List<Widget> cards = [];

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.contains("Breakfast:")) {
        cards.add(_buildCard("Breakfast", line.replaceAll("Breakfast:", ""), Colors.orange));
      } else if (line.contains("Lunch:")) {
        cards.add(_buildCard("Lunch", line.replaceAll("Lunch:", ""), Colors.green));
      } else if (line.contains("Dinner:")) {
        cards.add(_buildCard("Dinner", line.replaceAll("Dinner:", ""), Colors.blue));
      } else if (line.contains("Snack:")) {
        cards.add(_buildCard("Snack", line.replaceAll("Snack:", ""), Colors.purple));
      } else if (line.contains("Reasoning:")) {
        cards.add(_buildInfoBox(line.replaceAll("Reasoning:", "")));
      }
    }

    if (cards.isEmpty) {
      // Fallback if AI formatting was weird but not an error
      return Text(planText);
    }

    return Column(children: cards);
  }

  Widget _buildCard(String title, String content, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.restaurant, color: color)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(content.trim(), style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoBox(String content) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.verified, size: 18, color: Colors.teal), SizedBox(width: 8), Text("AI Analysis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))]),
          const SizedBox(height: 8),
          Text(content.trim(), style: TextStyle(color: Colors.teal.shade900)),
        ],
      ),
    );
  }
}