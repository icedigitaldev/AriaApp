import 'package:refena_flutter/refena_flutter.dart';

// Estado inmutable de autenticación
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String currentStep;
  final Map<String, dynamic>? pendingStaff;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentStep = 'phone',
    this.pendingStaff,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? currentStep,
    Map<String, dynamic>? pendingStaff,
    bool clearError = false,
    bool clearPendingStaff = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentStep: currentStep ?? this.currentStep,
      pendingStaff: clearPendingStaff
          ? null
          : (pendingStaff ?? this.pendingStaff),
    );
  }
}

// Notifier base para el estado de autenticación
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState init() => const AuthState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, clearError: error == null);
  }

  void setStep(String step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  void setPendingStaff(Map<String, dynamic>? staff) {
    state = state.copyWith(
      pendingStaff: staff,
      clearPendingStaff: staff == null,
    );
  }

  void reset() {
    state = const AuthState();
  }
}
