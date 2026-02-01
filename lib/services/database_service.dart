// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DatabaseService {
  // シングルトン
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _tableName = 'items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'last_price.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        currentPrice INTEGER NOT NULL,
        previousPrice INTEGER,
        updatedAt TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        sortOrder INTEGER NOT NULL
      )
    ''');
  }

  /// 全商品を取得（ピン留め順 → 登録順）
  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'isPinned DESC, sortOrder ASC',
    );
    return maps.map((map) => Item.fromJson(map)).toList();
  }

  /// 商品を追加
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert(
      _tableName,
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 商品を更新
  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      _tableName,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 商品を削除
  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 商品IDで取得
  Future<Item?> getItemById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Item.fromJson(maps.first);
  }

  /// 商品数を取得
  Future<int> getItemCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 次のsortOrderを取得
  Future<int> getNextSortOrder() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(sortOrder), 0) + 1 as nextOrder FROM $_tableName',
    );
    return Sqflite.firstIntValue(result) ?? 1;
  }
}
