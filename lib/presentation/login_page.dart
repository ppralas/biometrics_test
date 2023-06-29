import 'dart:developer';

import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsApp extends StatelessWidget {
  const BiometricsApp({Key? key}) : super(key: key);

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
      //stavit await localAuth itd u if
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;
      return _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
      );
    } catch (e) {
      log('Authentication error: $e');
    }
    return false;
  }

  void _login() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Wrong credentials. Please try again.';
      });
      return;
    }
    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    if (_validCredentials.containsKey(enteredEmail) &&
        _validCredentials[enteredEmail] == enteredPassword) {
      navigateToBiometricPage();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAuthentication();
  }

  void _initializeAuthentication() async {
    final canUseBiometrics =
        await _secureStorage.read(key: 'biometricsEnabled');

    if (canUseBiometrics == 'true') {
      _authenticateAndNavigate();
    }
  }

  Future<void> _authenticateAndNavigate() async {
    bool authenticated = await _authenticate();

    if (authenticated && mounted) {
      navigateToBiometricPage();
    }
  }

  void navigateToBiometricPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BiometricsPage(),
      ),
    );
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
                keyboardType: TextInputType.emailAddress,
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
              ElevatedButton(
                onPressed: _initializeAuthentication,
                child: const Text('Use Biometrics'),
              )
            ],
          ),
        ),
      ),
    );
  }

  String? emailValidator(String? value) {
    final emailRegex = RegExp(
      (r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
    );
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (value == null) return "Password can't be empty";
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    return null;
  }
}
