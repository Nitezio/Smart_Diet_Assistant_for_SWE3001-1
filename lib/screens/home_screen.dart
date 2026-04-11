import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../models/meal_plan.dart';

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

  void _showSourcePicker(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Analyze Meal Photo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                state.scanPlate(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                state.scanPlate(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: () => _showSourcePicker(context, state),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan Plate"),
            )
          : null,
    );
  }
}

// --- TAB 1: MEAL PLAN (AI) ---
class MealPlanTab extends StatelessWidget {
  const MealPlanTab({super.key});

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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Timing Mismatch"),
          content: Text("Did you have $mealType for $currentPeriod as the timing do not match?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No", style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); state.logMeal(mealType, dishName, calories); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Yes, I ate this"),
            ),
          ],
        ),
      );
    } else {
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
            onPressed: () { Navigator.pop(ctx); _showMealSelectionDialog(context, state); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Yes"),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("No")),
        ],
      ),
    );
  }

  void _showMealSelectionDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => _MealSelectionDialog(
        onContinue: (selectedMeals) { Navigator.pop(ctx); _showCuisinePicker(context, state, selectedMeals); },
      ),
    );
  }

  void _showCuisinePicker(BuildContext context, AppState state, List<String> mealsToChange) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
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
      ),
    );
  }

  Widget _cuisineOption(BuildContext context, AppState state, String title, IconData icon, List<String> mealsToChange, {bool isSpecial = false}) {
    return ListTile(
      leading: Icon(icon, color: isSpecial ? Colors.orange : Colors.green),
      title: Text(title, style: TextStyle(fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal)),
      onTap: () { Navigator.pop(context); state.getDietPlan(cuisineType: title, mealsToChange: mealsToChange); },
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
          children: [
            const Text("Meal Plan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(todayDate, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (hasPlan && !state.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FilledButton.icon(
                onPressed: () => _showChangeConfirmation(context, state),
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12)),
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text("Change Menu", style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 20),
              Text("AI is processing...", style: TextStyle(color: Colors.grey)),
            ]));
          }

          if (hasPlan) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStructuredDietList(state.currentMealPlan!, context),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.carrot, size: 60, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text("Ready to Eat Healthy?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("Tap 'Scan Plate' below or generate a manual plan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("Generate First Meal Plan"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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

  Widget _buildStructuredDietList(MealPlan plan, BuildContext context) {
    return Column(
      children: [
        _buildMealCard("Breakfast", plan.breakfast, Colors.orange, context),
        _buildMealCard("Lunch", plan.lunch, Colors.green, context),
        _buildMealCard("Dinner", plan.dinner, Colors.blue, context),
        _buildMealCard("Snack", plan.snack, Colors.purple, context),
        const SizedBox(height: 10),
        Card(
          color: Colors.teal.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade100)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.analytics, color: Colors.teal),
                  const SizedBox(width: 10),
                  Text("Nutrients: ${plan.totalCalories} kcal, ${plan.protein}g Protein", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                ]),
                const Divider(),
                Text("Reasoning: ${plan.reasoning}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.teal)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMealCard(String type, Meal meal, Color color, BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isLogged = state.loggedMeals.contains(type);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: isLogged ? Colors.grey : color, width: 6))),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(backgroundColor: (isLogged ? Colors.grey : color).withOpacity(0.1), child: Icon(isLogged ? Icons.done_all : Icons.restaurant, color: isLogged ? Colors.grey : color)),
          title: Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: isLogged ? Colors.grey : color)),
          subtitle: Text("${meal.dishName}\n${meal.ingredients} (${meal.calories} kcal)", style: TextStyle(color: isLogged ? Colors.grey : Colors.black87)),
          trailing: IconButton(
            icon: Icon(isLogged ? Icons.check_circle : Icons.check_circle_outline, color: isLogged ? Colors.green : Colors.grey),
            onPressed: isLogged ? null : () => _handleLogAttempt(context, state, type, meal.dishName, meal.calories),
          ),
        ),
      ),
    );
  }
}

class _MealSelectionDialog extends StatefulWidget {
  final Function(List<String>) onContinue;
  const _MealSelectionDialog({required this.onContinue});
  @override
  State<_MealSelectionDialog> createState() => _MealSelectionDialogState();
}

class _MealSelectionDialogState extends State<_MealSelectionDialog> {
  final List<String> _options = ["Breakfast", "Lunch", "Dinner", "Snack"];
  final List<String> _selected = [];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Meals to Change"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        CheckboxListTile(
          title: const Text("Select All"), 
          value: _selected.length == 4, 
          onChanged: (v) => setState(() => v! ? (_selected..clear()..addAll(_options)) : _selected.clear())
        ),
        const Divider(),
        ..._options.map((m) => CheckboxListTile(
          title: Text(m), 
          value: _selected.contains(m), 
          onChanged: (v) => setState(() => v! ? _selected.add(m) : _selected.remove(m))
        )),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _selected.isEmpty ? null : () => widget.onContinue(_selected), child: const Text("Continue")),
      ],
    );
  }
}

// --- 🟢 UPDATED: TRACKER TAB WITH GRAPHS ---
class TrackerTab extends StatelessWidget {
  const TrackerTab({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final percentage = (state.consumedCalories / state.calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Health Analytics"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // 1. Weekly Trends Graph
          const Align(alignment: Alignment.centerLeft, child: Text("Weekly Calorie Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _WeeklyBarChart(stats: state.weeklyStats),
          ),
          
          const Divider(height: 40),

          // 2. Today's Progress
          const Align(alignment: Alignment.centerLeft, child: Text("Today's Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          const FaIcon(FontAwesomeIcons.chartPie, size: 40, color: Colors.green),
          Text("${state.consumedCalories} / ${state.calorieGoal} kcal", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: percentage, color: Colors.green, backgroundColor: Colors.green.shade100, minHeight: 10),
          const SizedBox(height: 8),
          Text("${(percentage * 100).toInt()}% of daily goal"),

          const SizedBox(height: 40),

          // 3. Recent History
          const Align(alignment: Alignment.centerLeft, child: Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          if (state.history.isEmpty) const Text("No history yet.") else ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.history.length,
            itemBuilder: (context, i) {
              final item = state.history[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: Text(item.dishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.mealType} • ${DateFormat('d MMM, h:mm a').format(item.timestamp)}"),
                  trailing: Text("+${item.calories} kcal", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final Map<String, int> stats;
  const _WeeklyBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Fill in last 7 days even if no data
    final List<double> values = [];
    final List<String> labels = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      values.add((stats[dateKey] ?? 0).toDouble());
      labels.add(DateFormat('E').format(date)); // e.g. "Mon"
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2500, // Reasonable max for Malaysian diet
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) => Text(labels[val.toInt()], style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: values[i], color: values[i] > 2000 ? Colors.orange : Colors.green, width: 18, borderRadius: BorderRadius.circular(4))],
        )),
      ),
    );
  }
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});
  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  void _send(AppState state) async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final msg = _msgCtrl.text;
    _msgCtrl.clear();
    await state.sendChatMessage(msg);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final history = state.chatHistory;
    return Scaffold(
      appBar: AppBar(title: const Text("AI Nutritionist Chat"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text("Ask me about Malaysian food or your diet goal!", style: TextStyle(color: Colors.grey[600])),
                  ]))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, i) => _chatBubble(history[i]),
                  ),
          ),
          if (state.isTyping) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: Colors.green, minHeight: 2)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgCtrl, decoration: InputDecoration(hintText: "Ask Dr. Lee...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)), onSubmitted: (_) => _send(state))),
                const SizedBox(width: 8),
                CircleAvatar(backgroundColor: Colors.green, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _send(state)))
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _chatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(color: msg.isUser ? Colors.green : Colors.white, borderRadius: BorderRadius.only(topLeft: const Radius.circular(15), topRight: const Radius.circular(15), bottomLeft: Radius.circular(msg.isUser ? 15 : 0), bottomRight: Radius.circular(msg.isUser ? 0 : 15)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
        child: Text(msg.text, style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 15)),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.user;
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Profile"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: user == null ? const Center(child: Text("No Profile")) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.person, size: 50, color: Colors.white))),
          const SizedBox(height: 20),
          ListTile(title: const Text("Name"), subtitle: Text(user.name), leading: const Icon(Icons.person)),
          ListTile(title: const Text("Goal"), subtitle: Text(user.goal), leading: const Icon(Icons.flag), tileColor: Colors.green.shade50),
          ListTile(title: const Text("Conditions"), subtitle: Text(user.conditions.join(", ")), leading: const Icon(Icons.medical_services)),
          
          const Divider(height: 40),
          
          // 🟢 NEW: Export Medical Report Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => state.exportMedicalReport(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Export Medical PDF Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () { state.logout(); Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
