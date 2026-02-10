import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/user_model.dart';
import '../data/repositories/user_repo.dart';
import 'password_services.dart';

class AuthService {
  final UserRepository userRepo;

  AuthService(this.userRepo);

  Future<User> login(String username, String password) async {
    final user = await userRepo.fetchUserByUsername(username);

    if (user == null) {
      throw AuthException.userNotFound();
    }

    final isMatch = await PasswordService.verifyPassword(
      password,
      user.password,
    );

    if (!isMatch) {
      throw AuthException.invalidPassword();
    }

    return user;
  }
}

class AuthException implements Exception {
  final String message;

  AuthException._(this.message);

  factory AuthException.userNotFound() =>
      AuthException._("ไม่พบชื่อผู้ใช้นี้");

  factory AuthException.invalidPassword() =>
      AuthException._("รหัสผ่านไม่ถูกต้อง");
}

// อยู่ท้ายไฟล์เท่านั้น naja
final authServiceProvider = Provider<AuthService>((ref) {
  final userRepo = ref.read(userRepoProvider);
  return AuthService(userRepo);
});
