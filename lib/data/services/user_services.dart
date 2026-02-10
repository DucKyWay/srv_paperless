import 'package:srv_paperless/data/db_manager.dart';

import '../../model/user.dart';

final db = DbManager();

Future<List<User>> fetchAllUsers() async {
  final List<Map<String, dynamic>> rows = await db.query("SELECT * FROM users");

  return rows.map((item) => User.fromMap(item)).toList();
}

Future<User?> fetchUserById(String id) async {
  final rows = await db.query("SELECT * FROM users WHERE id = ?", [id]);

  if(rows.isEmpty) return null;
  return User.fromMap(rows.first);
}

Future<User?> fetchUserByUsername(String username) async {
  final rows = await db.query("SELECT * FROM users WHERE username = ?", [username]);

  if(rows.isEmpty) return null;
  return User.fromMap(rows.first);
}