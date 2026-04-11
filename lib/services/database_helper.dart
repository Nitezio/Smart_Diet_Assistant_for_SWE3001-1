import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/app_state.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diet_assistant.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        isWarning INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealType TEXT NOT NULL,
        dishName TEXT NOT NULL,
        calories INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // --- FOOD ITEMS CRUD ---

  Future<void> insertFood(FoodItem item) async {
    final db = await instance.database;
    await db.insert('food_items', item.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FoodItem>> getAllFood() async {
    final db = await instance.database;
    final result = await db.query('food_items');
    return result.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<void> updateFood(FoodItem item) async {
    final db = await instance.database;
    await db.update('food_items', item.toJson(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteFood(String id) async {
    final db = await instance.database;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  // --- MEAL HISTORY CRUD ---

  Future<void> insertHistory(MealHistoryItem item) async {
    final db = await instance.database;
    await db.insert('meal_history', item.toJson());
  }

  Future<List<MealHistoryItem>> getAllHistory() async {
    final db = await instance.database;
    final result = await db.query('meal_history', orderBy: 'timestamp DESC');
    return result.map((json) => MealHistoryItem.fromJson(json)).toList();
  }

  // 🟢 NEW: Get aggregated stats for charts
  Future<Map<String, int>> getDailyCalorieStats(int days) async {
    final db = await instance.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    // Grouping by date string (YYYY-MM-DD)
    final result = await db.rawQuery('''
      SELECT substr(timestamp, 1, 10) as date, SUM(calories) as total 
      FROM meal_history 
      WHERE timestamp >= ?
      GROUP BY date 
      ORDER BY date ASC
    ''', [startDate.toIso8601String()]);

    return { for (var row in result) row['date'] as String : row['total'] as int };
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('food_items');
    await db.delete('meal_history');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
