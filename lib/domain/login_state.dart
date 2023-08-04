class LoginState {
  final String errorMessage;
  bool loggedIn;
  bool isLoading;
  bool isBiometricsEnabled;

  LoginState({
    this.errorMessage = '',
    this.loggedIn = false,
    this.isBiometricsEnabled = false,
    this.isLoading = false,
  });

  LoginState copyWith({
    String? errorMessage,
    bool? loggedIn,
    bool? isBiometricsEnabled,
    bool? isLoading,
  }) {
    return LoginState(
      errorMessage: errorMessage ?? this.errorMessage,
      loggedIn: loggedIn ?? this.loggedIn,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
