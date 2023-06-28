import 'dart:developer';

import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final Map<String, String> _validCredentials = {
    'user1@example.com': 'Password1',
    'user2@example.com': 'Password2',
    'user3@example.com': 'Password3',
  };

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  Future<bool> _authenticate() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (canCheckBiometrics) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
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
    if (_formKey.currentState!.validate()) {
      final enteredEmail = _emailController.text.trim();
      final enteredPassword = _passwordController.text.trim();

      if (_validCredentials.containsKey(enteredEmail) &&
          _validCredentials[enteredEmail] == enteredPassword) {
        final canUseBiometrics =
            await _secureStorage.read(key: 'biometricsEnabled');
        bool authenticated = true;
        if (canUseBiometrics == 'true') {
          authenticated = await _authenticate();
        }

        if (authenticated) {
          _navigateToBiometricsPage();
        }
      } else {
        setState(() {
          _errorMessage = 'Wrong credentials. Please try again.';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAuthentication();
  }

  void _initializeAuthentication() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final canUseBiometrics =
        await _secureStorage.read(key: 'biometricsEnabled');

    if (canCheckBiometrics && canUseBiometrics == 'true') {
      _authenticateAndNavigate();
    }
  }

  Future<void> _authenticateAndNavigate() async {
    bool authenticated = await _authenticate();

    if (authenticated) {
      _navigateToBiometricsPage();
    }
  }

  Future<void> _navigateToBiometricsPage() async {
    await Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BiometricsPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  return emailValidator(value);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  return passwordValidator(value);
                },
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
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'Email is required';
    } else if (!_validCredentials.containsKey(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Password is required';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    return null;
  }
}
