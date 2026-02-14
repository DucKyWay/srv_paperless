import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(username, password);

      state = state.copyWith(
        isLoading: false,
        currentUser: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "เกิดข้อผิดพลาดบางอย่าง",
      );
    }
  }

  void logout() {
    state = AuthState();
  }

  Future<void> getCurrentUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      
      final updatedUser = await authService.getCurrentUser(); 

      state = state.copyWith(
        currentUser: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      print("Refresh user failed: $e");
    }
  }
}
