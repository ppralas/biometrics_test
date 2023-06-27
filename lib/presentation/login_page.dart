import 'dart:developer';

import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final List<String> _validEmails = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
  ];
  final List<String> _validPasswords = [
    'password1',
    'password2',
    'password3',
  ];

  String _errorMessage = '';

  Future<bool> _authenticate() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics =
            await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          return await _localAuth.authenticate(
            localizedReason: 'Authenticate to access the app',
          );
        }
      }
    } catch (e) {
      log('Authentication error: $e');
    }
    return false;
  }

  void _login() async {
    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    if (_validEmails.contains(enteredEmail) &&
        _validPasswords.contains(enteredPassword)) {
      String? canUseBiometrics =
          await _secureStorage.read(key: 'biometricsEnabled');
      bool authenticated = true;
      if (canUseBiometrics == 'true') {
        authenticated = await _authenticate();
      }

      if (context.mounted && authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BiometricsPage(),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Wrong credentials. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
