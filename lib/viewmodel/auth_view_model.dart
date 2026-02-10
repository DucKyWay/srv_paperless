import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/user.dart';

import '../data/repositories/user_repo.dart';
import '../services/password_services.dart';
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
class AuthState {
  final bool isLoading;
  final User? currentUser; // เปลี่ยนจาก String? role
  final String? error;

  AuthState({this.isLoading = false, this.currentUser, this.error});

  AuthState copyWith({bool? isLoading, User? currentUser, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {

  @override
  AuthState build() => AuthState();

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await fetchUserByUsername(username);

      if (user == null) {
        state = state.copyWith(isLoading: false, error: "ไม่พบชื่อผู้ใช้นี้");
        return;
      }

      final isMatch = await PasswordService.verifyPassword(password, user.password);

      if (isMatch) {
        state = state.copyWith(isLoading: false, currentUser: user);
      } else {
        print("Password from DB length: ${user.password.length}");
        state = state.copyWith(isLoading: false, error: "รหัสผ่านไม่ถูกต้อง");
      }

    } catch (e) {
      state = state.copyWith(isLoading: false, error: "เกิดข้อผิดพลาด: $e");
      print("Login Error: $e");
    }
  }

  void logout() => state = AuthState();
}