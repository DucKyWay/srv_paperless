import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      return AuthState(isLoading: false);
    }

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();
      return AuthState(currentUser: user, isLoading: false);
    } catch (e) {
      return AuthState(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(username, password);

      state = AsyncData(
        AuthState(
          currentUser: user,
          isLoading: false,
          message: "เข้าสู่ระบบสำเร็จ",
        ),
      );
    } on AuthException catch (e) {
      state = AsyncData(AuthState(isLoading: false, error: e.message));
    } catch (e) {
      state = AsyncData(
        AuthState(isLoading: false, error: "เกิดข้อผิดพลาดบางอย่าง"),
      );
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();

    state = AsyncData(AuthState(isLoading: false));
  }

  Future<void> refreshUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      final updatedUser = await authService.getCurrentUser();

      state = AsyncData(AuthState(currentUser: updatedUser, isLoading: false));
    } catch (e) {
      debugPrint("Failed to refresh");
    }
  }
}
