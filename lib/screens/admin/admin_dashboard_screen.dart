import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const _AdminStatsTab(),
    const _FoodDatabaseTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Statistics"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Food DB"),
        ],
      ),
    );
  }
}

// --- TAB 1: STATISTICS (With Graph) ---
class _AdminStatsTab extends StatelessWidget {
  const _AdminStatsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("System Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard("Total Users", "12,450", Colors.blue, Icons.people),
            const SizedBox(width: 16),
            _buildStatCard("Active Today", "854", Colors.green, Icons.person_pin),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard("Countries", "Malaysia", Colors.orange, Icons.public),
            const SizedBox(width: 16),
            _buildStatCard("Pending Reports", "3", Colors.red, Icons.report_problem),
          ],
        ),
        const SizedBox(height: 30),

        // --- REALISTIC GRAPH SECTION ---
        const Text("User Growth (Last 5 Weeks)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Consistent upward trend in new signups.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: const _UserGrowthChart(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Simple Bar Chart Widget
class _UserGrowthChart extends StatelessWidget {
  const _UserGrowthChart();

  @override
  Widget build(BuildContext context) {
    // Fake Data: Growth over 5 weeks
    final data = [45, 60, 75, 80, 120];
    final max = 120;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(data.length, (index) {
        final heightPercentage = data[index] / max;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // The Bar
            Container(
              width: 30,
              height: 150 * heightPercentage, // Max height 150
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade700]
                  )
              ),
            ),
            const SizedBox(height: 8),
            Text("Wk ${index + 1}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text("+${data[index]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        );
      }),
    );
  }
}

// --- TAB 2: FOOD DATABASE MANAGEMENT (CRUD) ---
class _FoodDatabaseTab extends StatelessWidget {
  const _FoodDatabaseTab();

  // Helper to show Add/Edit Dialog
  void _showFoodDialog(BuildContext context, {FoodItem? item}) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final detailsCtrl = TextEditingController(text: item?.details ?? '');
    bool isWarning = item?.isWarning ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(isEditing ? "Edit Food Item" : "Add New Food"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Food Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: detailsCtrl,
                      decoration: const InputDecoration(labelText: "Nutritional Info / Tags", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Mark as Unsafe/Warning?"),
                      value: isWarning,
                      activeColor: Colors.red,
                      onChanged: (val) => setState(() => isWarning = val),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final provider = Provider.of<AppState>(context, listen: false);
                      if (isEditing) {
                        // UPDATE
                        provider.updateFood(item.id, nameCtrl.text, detailsCtrl.text, isWarning);
                      } else {
                        // CREATE
                        provider.addFood(nameCtrl.text, detailsCtrl.text, isWarning);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                    child: Text(isEditing ? "Update" : "Add"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to AppState so list updates automatically
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Manage Food & Tags", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                        "Current Database Items: ${state.foodDatabase.length}",
                        style: const TextStyle(color: Colors.grey)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.foodDatabase.length,
                  itemBuilder: (context, index) {
                    final food = state.foodDatabase[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          food.isWarning ? Icons.warning_amber : Icons.check_circle_outline,
                          color: food.isWarning ? Colors.orange : Colors.green,
                        ),
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(food.details),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // EDIT BUTTON
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () => _showFoodDialog(context, item: food),
                            ),
                            // DELETE BUTTON
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, food.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // CREATE BUTTON
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFoodDialog(context),
            backgroundColor: Colors.blueGrey,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add New Food", style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).deleteFood(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}