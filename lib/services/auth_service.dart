import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/user_model.dart';
import '../data/repositories/user_repo.dart';

class AuthService {
  final UserRepository userRepo;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  AuthService(this.userRepo);

  Future<User> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await userRepo.fetchUserById(credential.user!.uid);

      if (user == null) {
        throw AuthException._("ไม่พบข้อมูลโปรไฟล์ผู้ใช้ในระบบ");
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException.userNotFound();
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw AuthException.invalidPassword();
      } else {
        throw AuthException._(e.message ?? "เกิดข้อผิดพลาดในการเข้าสู่ระบบ");
      }
    } catch (e) {
      throw AuthException._("เกิดข้อผิดพลาด: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException._(this.message);

  factory AuthException.userNotFound() => AuthException._("ไม่พบชื่อผู้ใช้นี้");
  factory AuthException.invalidPassword() => AuthException._("รหัสผ่านไม่ถูกต้อง");

  @override
  String toString() => message;
}

final authServiceProvider = Provider<AuthService>((ref) {
  final userRepo = ref.watch(userRepoProvider);
  return AuthService(userRepo);
});