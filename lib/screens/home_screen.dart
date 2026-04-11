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

  // 🔴 TIME LOGIC: Get current logical meal period
  String _getCurrentMealPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return "Breakfast";
    if (hour >= 11 && hour < 16) return "Lunch";
    if (hour >= 16 && hour < 18) return "Snack";
    if (hour >= 18 && hour < 23) return "Dinner";
    return "Late Snack";
  }

  void _handleLogAttempt(BuildContext context, AppState state, String mealType, String dishName, int calories) {
    final currentPeriod = _getCurrentMealPeriod();
    
    if (mealType != currentPeriod) {
      // 🟢 PROGRAMMED LOGIC: Ask for confirmation if timing doesn't match
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Timing Mismatch"),
          content: Text("Did you have $mealType for $currentPeriod as the timing do not match?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                state.logMeal(mealType, dishName, calories);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Yes, I ate this"),
            ),
          ],
        ),
      );
    } else {
      // Normal logging
      state.logMeal(mealType, dishName, calories);
    }
  }

  void _showChangeConfirmation(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Menu?"),
        content: const Text("Are you sure you want to change current menu? This will replace your selected meals."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showMealSelectionDialog(context, state);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  void _showMealSelectionDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _MealSelectionDialog(
          onContinue: (selectedMeals) {
            Navigator.pop(ctx);
            _showCuisinePicker(context, state, selectedMeals);
          },
        );
      },
    );
  }

  void _showCuisinePicker(BuildContext context, AppState state, List<String> mealsToChange) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose Your Cuisine", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Select a style for the regeneration:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              _cuisineOption(context, state, "Malay", Icons.restaurant, mealsToChange),
              _cuisineOption(context, state, "Chinese", Icons.ramen_dining, mealsToChange),
              _cuisineOption(context, state, "Indian", Icons.kebab_dining, mealsToChange),
              const Divider(),
              _cuisineOption(context, state, "Surprise me (Random)", Icons.auto_awesome, mealsToChange, isSpecial: true),
            ],
          ),
        );
      },
    );
  }

  Widget _cuisineOption(BuildContext context, AppState state, String title, IconData icon, List<String> mealsToChange, {bool isSpecial = false}) {
    return ListTile(
      leading: Icon(icon, color: isSpecial ? Colors.orange : Colors.green),
      title: Text(title, style: TextStyle(fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        Navigator.pop(context);
        state.getDietPlan(cuisineType: title, mealsToChange: mealsToChange);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final String todayDate = DateFormat('EEEE, d MMM y').format(DateTime.now());
    final bool hasPlan = state.currentMealPlan != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Meal Plan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(todayDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (hasPlan && !state.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: () => _showChangeConfirmation(context, state),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green, elevation: 2),
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text("Change Menu"),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 20),
                  Text("Chefs are preparing your menu...", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          if (hasPlan) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildParsedDietList(state.currentMealPlan!, context),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.carrot, size: 60, color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  const Text("Ready to Eat Healthy?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  const Text(
                    "Tap below to generate a personalized Malaysian meal plan based on your health profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 32),
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
                      onPressed: () => _showCuisinePicker(context, state, ["Breakfast", "Lunch", "Dinner", "Snack"]),
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

  Widget _buildParsedDietList(String planText, BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    if (planText.startsWith("Error")) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text("Oops! Something went wrong.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(planText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => state.getDietPlan(),
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    final lines = planText.split('\n');
    List<Widget> cards = [];

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.contains("Breakfast:")) {
        cards.add(_buildCard("Breakfast", line.replaceAll("Breakfast:", ""), Colors.orange, context));
      } else if (line.contains("Lunch:")) {
        cards.add(_buildCard("Lunch", line.replaceAll("Lunch:", ""), Colors.green, context));
      } else if (line.contains("Dinner:")) {
        cards.add(_buildCard("Dinner", line.replaceAll("Dinner:", ""), Colors.blue, context));
      } else if (line.contains("Snack:")) {
        cards.add(_buildCard("Snack", line.replaceAll("Snack:", ""), Colors.purple, context));
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
      }
    }
    return Column(children: cards);
  }

  Widget _buildCard(String title, String content, Color color, BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isLogged = state.loggedMeals.contains(title);

    int calories = 400; 
    final calMatch = RegExp(r'(\d+)\s*kcal').firstMatch(content);
    if (calMatch != null) {
      calories = int.tryParse(calMatch.group(1)!) ?? 400;
    }

    // Extract dish name
    String dishName = content.split('-').first.trim();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: isLogged ? Colors.grey : color, width: 6))
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: (isLogged ? Colors.grey : color).withOpacity(0.1),
            child: Icon(isLogged ? Icons.done_all : Icons.restaurant, color: isLogged ? Colors.grey : color),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isLogged ? Colors.grey : color, fontSize: 18)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(content.trim(), style: TextStyle(fontSize: 16, color: isLogged ? Colors.grey : Colors.black87)),
          ),
          trailing: IconButton(
            icon: Icon(isLogged ? Icons.check_circle : Icons.check_circle_outline, color: isLogged ? Colors.green : Colors.grey),
            tooltip: isLogged ? "Logged" : "Log this meal",
            onPressed: isLogged ? null : () => _handleLogAttempt(context, state, title, dishName, calories),
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGET: MEAL SELECTION DIALOG ---
class _MealSelectionDialog extends StatefulWidget {
  final Function(List<String>) onContinue;
  const _MealSelectionDialog({required this.onContinue});

  @override
  State<_MealSelectionDialog> createState() => _MealSelectionDialogState();
}

class _MealSelectionDialogState extends State<_MealSelectionDialog> {
  final List<String> _options = ["Breakfast", "Lunch", "Dinner", "Snack"];
  final List<String> _selected = [];

  void _toggleAll(bool? val) {
    setState(() {
      if (val == true) {
        _selected.clear();
        _selected.addAll(_options);
      } else {
        _selected.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = _selected.length == _options.length;

    return AlertDialog(
      title: const Text("Select Meals to Change"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text("Select All", style: TextStyle(fontWeight: FontWeight.bold)),
              value: isAllSelected,
              onChanged: _toggleAll,
              activeColor: Colors.green,
            ),
            const Divider(),
            ..._options.map((meal) => CheckboxListTile(
              title: Text(meal),
              value: _selected.contains(meal),
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selected.add(meal);
                  } else {
                    _selected.remove(meal);
                  }
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _selected.isEmpty ? null : () => widget.onContinue(_selected),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text("Continue"),
        ),
      ],
    );
  }
}

// --- TAB 2: TRACKER ---
class TrackerTab extends StatelessWidget {
  const TrackerTab({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final percentage = (state.consumedCalories / state.calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Nutritional Tracker"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.chartPie, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            const Text("Calories Today", style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text("${state.consumedCalories} / ${state.calorieGoal} kcal", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            Container(
                height: 15,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)))
                )
            ),
            const SizedBox(height: 8),
            Text("${(percentage * 100).toInt()}% of daily goal", style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            if (state.history.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text("No meals logged yet today.", style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final item = state.history[index];
                  final timeStr = DateFormat('h:mm a').format(item.timestamp);
                  final dateStr = DateFormat('d MMM').format(item.timestamp);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade50,
                        child: Text(item.mealType[0], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(item.dishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.mealType} • $dateStr, $timeStr"),
                      trailing: Text("+${item.calories} kcal", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
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
                decoration: InputDecoration(hintText: "Type message...", suffixIcon: const Icon(Icons.send), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)))
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
        decoration: BoxDecoration(color: isMe ? Colors.green : Colors.grey[300], borderRadius: BorderRadius.circular(15)),
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
    final state = Provider.of<AppState>(context);
    final user = state.user;
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                state.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
