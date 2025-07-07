import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'test.db');
    return openDatabase(
      path,
      version: 2, // ← CAMBIA la versión si ya habías creado la base de datos
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          password TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE qr_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          descripcion TEXT,
          fecha TEXT,
          contenido TEXT,
          imagenPath TEXT
        )
      ''');

        // Usuario por defecto
        await db.insert('users', {
          'username': 'erik',
          'password': hashPassword('1234'),
        });
      },
    );
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> validateUser(String username, String password) async {
    final db = await database;
    final hashedPassword = hashPassword(password);
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );
    return result.isNotEmpty;
  }

  static Future<bool> registerUser(String username, String password) async {
    final db = await database;
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) return false;

    final hashedPassword = hashPassword(password);
    await db.insert('users', {
      'username': username,
      'password': hashedPassword,
    });
    return true;
  }

  // Inserta un nuevo QR
  static Future<void> insertarQR(
    String nombre,
    String descripcion,
    String fecha,
    String contenido,
    String imagenPath,
  ) async {
    final db = await database;
    await db.insert('qr_data', {
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': fecha,
      'contenido': contenido,
      'imagenPath': imagenPath,
    });
  }

  // Obtiene todos los QR guardados
  static Future<List<Map<String, dynamic>>> obtenerTodosQR() async {
    final db = await database;
    return await db.query('qr_data', orderBy: 'id DESC');
  }
}
