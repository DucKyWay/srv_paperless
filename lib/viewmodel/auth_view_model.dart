import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final String? role;
  final String? error;
  AuthState({this.isLoading = false, this.role, this.error});
  AuthState copyWith({bool? isLoading, String? role, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      error: error ?? this.error,
    );
  }
}
// create Providere for call of Viewpage
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});


class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // (Initial State)
    return AuthState();
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.delayed(const Duration(seconds: 2));

    if (username == "admin" && password == "1234") {
      state = state.copyWith(isLoading: false, role: "admin");
    } else if (username == "user" && password == "1234") {
      state = state.copyWith(isLoading: false, role: "user");
    } else {
      state = state.copyWith(isLoading: false, error: "Username หรือ Password ผิด");
    }
  }
  void logout() {
    state = AuthState();
  }
}