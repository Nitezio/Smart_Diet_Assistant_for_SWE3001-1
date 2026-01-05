import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
    final String todayDate = DateFormat('EEEE, d MMM y').format(DateTime.now());

    // Check if we have data to decide layout
    final bool hasPlan = state.currentMealPlan != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "Meal Plan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            Text(
                todayDate,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70)
            ),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // 🟢 LOGIC: Only show "Change Menu" button in AppBar if a plan ALREADY exists.
          if (hasPlan && !state.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: () => state.getDietPlan(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text("Change Menu"),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // STATE 1: LOADING
          if (state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 20),
                  Text("Chefs are preparing your menu...", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // STATE 2: PLAN EXISTS (Show List)
          if (hasPlan) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildParsedDietList(state.currentMealPlan!),
            );
          }

          // STATE 3: NO PLAN / FIRST TIME (Show Big Button)
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(FontAwesomeIcons.carrot, size: 60, color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                      "Ready to Eat Healthy?",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tap below to generate a personalized Malaysian meal plan based on your health profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  // 🟢 THE REQUESTED BIG BUTTON FOR FIRST TIME USE
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("Generate First Meal Plan", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => state.getDietPlan(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParsedDietList(String planText) {
    if (planText.startsWith("Error")) {
      return Center(child: Text(planText, style: const TextStyle(color: Colors.red, fontSize: 16)));
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
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade100)),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.teal),
                    const SizedBox(width: 10),
                    Expanded(child: Text(line.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal))),
                  ],
                )
            )
        ));
      } else if (line.contains("Reasoning")) {
        // Reasoning hidden for cleaner UI, or can be added as a footnote
      }
    }
    return Column(children: cards);
  }

  Widget _buildCard(String title, String content, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 6))
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(Icons.restaurant, color: color),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(content.trim(), style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
            tooltip: "Log this meal",
            onPressed: (){},
          ),
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
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10)
                      ),
                    )
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
          const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.person, size: 50, color: Colors.white))),
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