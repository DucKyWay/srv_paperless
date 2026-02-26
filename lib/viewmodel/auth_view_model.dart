import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkInitialAuth();
    return AuthState(isLoading: true);
  }

  Future<void> _checkInitialAuth() async {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      try {
        final authService = ref.read(authServiceProvider);
        final user = await authService.getCurrentUser();
        state = AuthState(currentUser: user, isLoading: false);
      } catch (e) {
        state = AuthState(isLoading: false);
      }
    } else {
      state = AuthState(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(username, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "เกิดข้อผิดพลาดบางอย่าง");
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = AuthState();
  }

  Future<void> getCurrentUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      final updatedUser = await authService.getCurrentUser();
      state = state.copyWith(currentUser: updatedUser, isLoading: false);
    } catch (e) {
      print("Refresh user failed: $e");
    }
  }
}
