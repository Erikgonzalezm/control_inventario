import 'dart:convert'; // Para utf8.encode
import 'package:crypto/crypto.dart'; // Para sha256
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Función para hacer hash de la contraseña
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Inicializa la base de datos
  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'test.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');

        // Inserta usuario por defecto con contraseña hacheada
        await db.insert('users', {
          'username': 'erik',
          'password': hashPassword('1234'),
        });
      },
    );
  }

  // Verifica si existe el usuario y contraseña usando hash
  static Future<bool> validateUser(String username, String password) async {
    final db = await initDB();
    final hashedPassword = hashPassword(password);
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );
    return result.isNotEmpty;
  }

  // Registra un nuevo usuario con contraseña hasheada
  static Future<bool> registerUser(String username, String password) async {
    final db = await initDB();

    // Verifica si el usuario ya existe
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (existing.isNotEmpty) {
      // Usuario ya existe
      return false;
    }

    // Inserta el nuevo usuario con contraseña hasheada
    final hashedPassword = hashPassword(password);
    await db.insert('users', {
      'username': username,
      'password': hashedPassword,
    });

    return true;
  }
}
