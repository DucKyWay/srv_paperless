import '../data/model/user_model.dart';

class AuthState {
  final bool isLoading;
  final User? currentUser;
  final String? error;
  final String? message;

  AuthState({
    this.isLoading = false,
    this.currentUser,
    this.error,
    this.message,
  });

  AuthState copyWith({
    bool? isLoading,
    User? currentUser,
    String? error,
    String? message,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      error: error,
      message: message,
    );
  }
}
