import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final bool isLoading;
  final Map<String, dynamic>? userProfile;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.userProfile,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    Map<String, dynamic>? userProfile,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repository.getCurrentUserProfile();
      state = state.copyWith(isLoading: false, userProfile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithEmail(email, password);
      await loadUser();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
