import 'dart:developer';

import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:biometric/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod/riverpod.dart';

final loginProvider = Provider<LoginNotifier>((ref) {
  return LoginNotifier(
    const FlutterSecureStorage(),
    LocalAuthentication(),
  );
});

class LoginNotifier extends StateNotifier<LoginState> {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  LoginNotifier(
    this._secureStorage,
    this._localAuth,
  ) : super(
          LoginState(),
        );

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final token = await AuthApi().login(email, password);
      print('Token: $token');
      await storeEmailAndPassword(email, password);
      state.onSuccess();
      _navigateToBiometricsPage(context);
    } catch (e) {
      print('Exception: $e');
      setErrorMessage(e.toString());
    }
  }

  Future<void> storeEmailAndPassword(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<String?> getEmailFromSecureStorage() async {
    return await _secureStorage.read(key: 'email');
  }

  Future<bool> canUseBiometrics() async {
    final canUseBiometrics =
        await _secureStorage.read(key: 'biometricsEnabled');
    return canUseBiometrics == 'true';
  }

  Future<void> initializeAuthentication(BuildContext context) async {
    if (await canUseBiometrics()) {
      loginWithBiometrics(context);
    }
  }

  Future<bool> shouldUseLocalAuth() async {
    try {
      final supportedBiometrics = await _localAuth.canCheckBiometrics;
      if (!supportedBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      return true;
    } catch (error) {
      log('Authentication error: $error');
      return false;
    }
  }

  void loginWithBiometrics(BuildContext context) async {
    try {
      final email = await getEmailFromSecureStorage();
      final password = await _secureStorage.read(key: 'password');
      final bool biometricResult =
          await _localAuth.authenticate(localizedReason: 'something');
      if (email != null && password != null && biometricResult == true) {
        await login(email, password, context);
      } else {
        setErrorMessage('Email or password not found.');
      }
    } catch (error) {
      print('Exception: $error');
      setErrorMessage('An error occurred during login.');
    }
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void _navigateToBiometricsPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const BiometricsPage(), // Replace 'BiometricsPage' with the actual name of your biometrics page class.
      ),
    );
  }
}

class LoginState {
  final String errorMessage;
  bool loggedIn;

  LoginState({
    this.errorMessage = '',
    this.loggedIn = false,
    bool? isBiometricsEnabled,
  });

  LoginState copyWith({
    String? errorMessage,
    bool? loggedIn,
  }) {
    return LoginState(
      errorMessage: errorMessage ?? this.errorMessage,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }

  void onSuccess() {
    if (loggedIn) {
      loggedIn = true;
    }
  }
}
