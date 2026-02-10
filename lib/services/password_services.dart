import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

class PasswordService {
  static Future<String> hashPassword(String password) async {
    return await compute(_generateHash, password);
  }

  static Future<bool> verifyPassword(String password, String hashed) async {
    return await compute(_checkPassword, {'pw': password, 'hash': hashed});
  }

  static String _generateHash(String password) {
    final String salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  static bool _checkPassword(Map<String, String> data) {
    return BCrypt.checkpw(data['pw']!, data['hash']!);
  }
}