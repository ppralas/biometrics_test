// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:local_auth/local_auth.dart';

// final emailControllerProvider =
//     Provider<TextEditingController>((ref) => TextEditingController());
// final passwordControllerProvider =
//     Provider<TextEditingController>((ref) => TextEditingController());
// final secureStorageProvider =
//     Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
// final localAuthProvider =
//     Provider<LocalAuthentication>((ref) => LocalAuthentication());
// final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);
// final validCredentialsProvider = Provider<Map<String, String>>((ref) => {
//       'user1@example.com': 'Password1',
//       'user2@example.com': 'Password2',
//       'user3@example.com': 'Password3',
//     });
// final formKeyProvider =
//     Provider<GlobalKey<FormState>>((ref) => GlobalKey<FormState>());
// final errorMessageProvider = StateProvider<String>((ref) => '');
// final biometricsEnabledProvider = Provider<String>((ref) => '');
// final authenticationNotifierProvider =
//     StateNotifierProvider<AuthenticationNotifier, AuthenticationState>(
//         (ref) => AuthenticationNotifier(ref.read));

// class AuthenticationState {
//   final bool isAuthenticated;

//   AuthenticationState({required this.isAuthenticated});
// }

// class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
//   final _read;

//   AuthenticationNotifier(this._read)
//       : super(AuthenticationState(isAuthenticated: false));

//   Future<void> authenticate() async {
//     try {
//       final localAuth = _read(localAuthProvider);
//       final canCheckBiometrics = await localAuth.canCheckBiometrics;
//       if (!canCheckBiometrics) return;

//       final availableBiometrics = await localAuth.getAvailableBiometrics();
//       if (availableBiometrics.isEmpty) return;

//       final authenticated = await localAuth.authenticate(
//         localizedReason: 'Authenticate to access the app',
//       );

//       if (authenticated) {
//         state = AuthenticationState(isAuthenticated: true);
//       }
//     } catch (e) {
//       log('Authentication error: $e');
//     }
//   }

//   bool get isAuthenticated => state.isAuthenticated;
// }
