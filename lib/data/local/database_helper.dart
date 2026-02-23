import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eldercare.db');
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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const optionalTextType = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        auth_user_id $optionalTextType,
        name $textType,
        email $textType,
        created_at $textType
      )
    ''');

    // Health metrics table
    await db.execute('''
      CREATE TABLE health_metrics (
        id $idType,
        user_id $intType,
        heart_rate $intType,
        blood_pressure_systolic $intType,
        blood_pressure_diastolic $intType,
        spo2_level $intType,
        recorded_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Fall detection table
    await db.execute('''
      CREATE TABLE fall_detections (
        id $idType,
        user_id $intType,
        detected_at $textType,
        location_lat $realType,
        location_lng $realType,
        status TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id $idType,
        user_id $intType,
        title $textType,
        message $textType,
        type TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Emergency contacts table
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id $idType,
        user_id $intType,
        name $textType,
        phone $textType,
        relationship TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Ambulance requests table
    await db.execute('''
      CREATE TABLE ambulance_requests (
        id $idType,
        user_id $intType,
        location_lat $realType,
        location_lng $realType,
        address $textType,
        status TEXT NOT NULL,
        requested_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Health metrics operations
  Future<int> insertHealthMetric(Map<String, dynamic> metric) async {
    final db = await database;
    return await db.insert('health_metrics', metric);
  }

  Future<List<Map<String, dynamic>>> getHealthMetrics(int userId, {int limit = 7}) async {
    final db = await database;
    return await db.query(
      'health_metrics',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> getLatestHealthMetric(int userId) async {
    final db = await database;
    final result = await db.query(
      'health_metrics',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Fall detection operations
  Future<int> insertFallDetection(Map<String, dynamic> fall) async {
    final db = await database;
    return await db.insert('fall_detections', fall);
  }

  Future<List<Map<String, dynamic>>> getFallDetections(int userId) async {
    final db = await database;
    return await db.query(
      'fall_detections',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'detected_at DESC',
    );
  }

  // Notification operations
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> markNotificationAsRead(int notificationId) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Emergency contacts operations
  Future<int> insertEmergencyContact(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.insert('emergency_contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts(int userId) async {
    final db = await database;
    return await db.query(
      'emergency_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteEmergencyContact(int contactId) async {
    final db = await database;
    return await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  // Ambulance request operations
  Future<int> insertAmbulanceRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('ambulance_requests', request);
  }

  Future<List<Map<String, dynamic>>> getAmbulanceRequests(int userId) async {
    final db = await database;
    return await db.query(
      'ambulance_requests',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'requested_at DESC',
    );
  }

  Future<int> updateAmbulanceRequestStatus(int requestId, String status) async {
    final db = await database;
    return await db.update(
      'ambulance_requests',
      {'status': status},
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
