import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MealPlanTab(),
    const TrackerTab(),
    const ChatTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final role = state.selectedRole;

    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Meals'),
          const BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Tracker'),
          const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: role == 'Elderly' ? 'Me' : 'Patient'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- TAB 1: MEAL PLAN (AI) ---
class MealPlanTab extends StatelessWidget {
  const MealPlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          title: const Text("Daily Meal Plan"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.currentMealPlan != null)
              _buildParsedDietList(state.currentMealPlan!)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Generate Meal Plan"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    onPressed: () => state.getDietPlan(),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: state.currentMealPlan != null ? FloatingActionButton(
        onPressed: () => state.getDietPlan(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildParsedDietList(String planText) {
    if (planText.startsWith("Error")) {
      return Text(planText, style: const TextStyle(color: Colors.red));
    }

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
      } else if (line.contains("Nutrients")) {
        cards.add(Card(
            color: Colors.teal.shade50,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(line.trim(), style: const TextStyle(fontWeight: FontWeight.bold))
            )
        ));
      }
    }
    return Column(children: cards);
  }

  Widget _buildCard(String title, String content, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.restaurant, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(content.trim()),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: (){},
        ),
      ),
    );
  }
}

// --- TAB 2: TRACKER ---
class TrackerTab extends StatelessWidget {
  const TrackerTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nutritional Tracker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.chartPie, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Calories Today", style: TextStyle(fontSize: 18)),
            const Text("1250 / 1800 kcal", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 30),
            Container(
                height: 20,
                width: 300,
                color: Colors.green.shade100,
                child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.7,
                    child: Container(color: Colors.green)
                )
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 3: CHAT ---
class ChatTab extends StatelessWidget {
  const ChatTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with Nutritionist")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _chatBubble("Hello! I am Dr. Lee. How can I help you?", false),
                _chatBubble("Is Nasi Lemak okay for my diabetes?", true),
                _chatBubble("A small portion is okay, but avoid the extra rice and sambal due to sugar content.", false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                decoration: InputDecoration(
                    hintText: "Type message...",
                    suffixIcon: const Icon(Icons.send),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))
                )
            ),
          )
        ],
      ),
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isMe ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(15)
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
      ),
    );
  }
}

// --- TAB 4: PROFILE ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).user;
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: user == null ? const Center(child: Text("No Profile Data")) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          ListTile(title: const Text("Name"), subtitle: Text(user.name), leading: const Icon(Icons.person)),
          ListTile(title: const Text("Conditions"), subtitle: Text(user.conditions.join(", ")), leading: const Icon(Icons.medical_services)),
          ListTile(title: const Text("Allergies"), subtitle: Text(user.allergies.join(", ")), leading: const Icon(Icons.warning)),
          const Divider(),
          ListTile(title: const Text("Link Caregiver"), leading: const Icon(Icons.people), onTap: (){}),
          ListTile(title: const Text("Settings"), leading: const Icon(Icons.settings), onTap: (){}),
        ],
      ),
    );
  }
}