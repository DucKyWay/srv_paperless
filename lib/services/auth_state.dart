import '../data/model/user_model.dart';

class AuthState {
  final bool isLoading;
  final User? currentUser;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.currentUser,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? currentUser,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      error: error,
    );
  }
}
