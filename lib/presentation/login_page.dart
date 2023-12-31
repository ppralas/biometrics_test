import 'package:biometric/domain/login_state.dart';
import 'package:biometric/domain/login_state_notifier.dart';
import 'package:biometric/presentation/enable_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthApi {
  static const Map<String, String> _validCredentials = {
    'user1@example.com': 'Password1',
    'user2@example.com': 'Password2',
    'user3@example.com': 'Password3',
  };

  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 3));
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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  void _navigateToBiometricsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BiometricsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.loggedIn) {
        _navigateToBiometricsPage();
      }
    });
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
                  if (!ref.read(loginNotifierProvider).isLoading) {
                    if (_formKey.currentState!.validate()) {
                      ref.read(loginNotifierProvider.notifier).login(
                            _emailController.text,
                            _passwordController.text,
                          );
                    }
                  }
                },
                child: ref.watch(loginNotifierProvider).isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              Text(
                ref.watch(loginNotifierProvider).errorMessage,
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
