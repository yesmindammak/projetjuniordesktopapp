import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<Map<String, dynamic>> registerUser(
    String username,
    String password,
    String role,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if username exists
      final existing = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (existing.isNotEmpty) {
        return {
          'success': false,
          'message': 'Username already exists',
          'code': 'username_exists',
        };
      }

      // Insert new user
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return {
        'success': true,
        'message': 'Account created successfully! Please login.',
        'code': 'registration_success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration error: $e',
        'code': 'registration_error',
      };
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if username exists
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (results.isEmpty) {
        return {
          'success': false,
          'message': 'Username not found',
          'code': 'username_not_found',
        };
      }

      final user = results.first;

      // Check password
      if (user['password'] != password) {
        return {
          'success': false,
          'message': 'Password is incorrect',
          'code': 'password_incorrect',
        };
      }

      return {
        'success': true,
        'message': 'Login successful',
        'code': 'login_success',
        'role': user['role'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: $e',
        'code': 'login_error',
      };
    }
  }

  Future<String?> getUserRole(String username) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (results.isNotEmpty) {
        return results.first['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
}