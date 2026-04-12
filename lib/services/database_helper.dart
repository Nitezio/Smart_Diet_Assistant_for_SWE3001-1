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
      version: 2, // 🟢 Incremented version for Users table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Table for Admin Food Database
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        isWarning INTEGER NOT NULL
      )
    ''');

    // 2. Table for Meal History
    await db.execute('''
      CREATE TABLE meal_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealType TEXT NOT NULL,
        dishName TEXT NOT NULL,
        calories INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 3. 🟢 NEW: Table for Persistent User Accounts
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        connectionCode TEXT NOT NULL,
        profileJson TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE users (
          email TEXT PRIMARY KEY,
          password TEXT NOT NULL,
          connectionCode TEXT NOT NULL,
          profileJson TEXT NOT NULL
        )
      ''');
    }
  }

  // --- 🟢 USER ACCOUNT METHODS ---

  Future<void> saveUserAccount(String email, String password, String code, String profileJson) async {
    final db = await instance.database;
    await db.insert('users', {
      'email': email,
      'password': password,
      'connectionCode': code,
      'profileJson': profileJson
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserAccount(String email) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<Map<String, dynamic>?> getUserByCode(String code) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'connectionCode = ?', whereArgs: [code.toUpperCase()]);
    if (maps.isNotEmpty) return maps.first;
    return null;
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

  Future<Map<String, int>> getDailyCalorieStats(int days) async {
    final db = await instance.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
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
    await db.delete('users');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
