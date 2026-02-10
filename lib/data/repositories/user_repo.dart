import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db_manager.dart';
import '../model/user_model.dart';

abstract class UserRepository {
  Future<List<User>> fetchAllUsers();
  Future<User?> fetchUserById(String id);
  Future<User?> fetchUserByUsername(String username);
}

class UserRepositoryImpl implements UserRepository {
  final DbManager db;
  UserRepositoryImpl(this.db);

  @override
  Future<List<User>> fetchAllUsers() async {
    final rows = await db.query("SELECT * FROM users");
    return rows.map((e) => User.fromMap(e)).toList();
  }

  @override
  Future<User?> fetchUserById(String id) async {
    final rows = await db.query(
      "SELECT * FROM users WHERE id = ?",
      [id],
    );

    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  @override
  Future<User?> fetchUserByUsername(String username) async {
    final rows = await db.query(
      "SELECT * FROM users WHERE username = ?",
      [username],
    );

    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }
}

// อยู่ท้ายไฟล์เท่านั้น naja
final userRepoProvider = Provider<UserRepository>((ref) {
  final db = DbManager();
  return UserRepositoryImpl(db);
});