import 'dart:developer';

import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthApi {
  static const Map<String, String> _validCredentials = {
    'user1@example.com': 'Password1',
    'user2@example.com': 'Password2',
    'user3@example.com': 'Password3',
  };

  Future<String> login(String email, String password) async {
    if (_validCredentials.containsKey(email) &&
        _validCredentials[email] == password) {
      return 'testToken';
    } else {
      throw Exception('Invalid email or password.');
    }
  }
}

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
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _shouldUseLocalAuth();
    _initializeAuthentication();
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  return passwordValidator(value);
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  _login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                },
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

  void _navigateToBiometricPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BiometricsPage(),
      ),
    );
  }

  void _login(String email, String password) async {
    try {
      final token = await AuthApi().login(
        email,
        password,
      );
      print('Token: $token');
      await _storeEmailAndPassword(
        email,
        password,
      );
      _navigateToBiometricPage();
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _storeEmailAndPassword(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<String?> _getEmailFromSecureStorage() async {
    return await _secureStorage.read(key: 'email');
  }

  Future<void> _initializeAuthentication() async {
    final canUseBiometrics =
        await _secureStorage.read(key: 'biometricsEnabled');

    if (canUseBiometrics == 'true') {
      _loginWithBiometrics();
    }
  }

  Future<bool> _shouldUseLocalAuth() async {
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

  void _loginWithBiometrics() async {
    try {
      final email = await _getEmailFromSecureStorage();
      final password = await _secureStorage.read(key: 'password');
      final bool biometricResoult =
          await _localAuth.authenticate(localizedReason: 'kurac');
      if (email != null && password != null && biometricResoult == true) {
        _login(email, password);
      } else {
        setState(() {
          _errorMessage = 'Email or password not found.';
        });
      }
    } catch (error) {
      print('Exception: $error');
      setState(() {
        _errorMessage = 'An error occurred during login.';
      });
    }
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
      return 'Password must contain at least one uppercase letter and one digit';
    }
    return null;
  }
}
