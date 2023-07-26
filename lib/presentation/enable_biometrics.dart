import 'package:biometric/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsPage extends StatefulWidget {
  const BiometricsPage({super.key});

  @override
  BiometricsPageState createState() => BiometricsPageState();
}

class BiometricsPageState extends State<BiometricsPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricsStatus();
    _checkBiometricPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Enable Biometrics',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                Switch(
                  value: _biometricsEnabled,
                  onChanged: (value) => _toggleBiometrics(value),
                ),
                ElevatedButton(
                  onPressed: () => _logout(),
                  child: const Text('Log out'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBiometrics(bool value) async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    setState(() {
      _biometricsEnabled = value && canCheckBiometrics;
    });
    _saveBiometricsStatus(_biometricsEnabled);
  }

  Future<void> _loadBiometricsStatus() async {
    String? enabled = await _secureStorage.read(key: 'biometricsEnabled');
    setState(() {
      _biometricsEnabled = enabled == 'true';
    });
  }

  Future<void> _checkBiometricPermission() async {
    try {
      bool isBiometricEnabled = await _localAuth.isDeviceSupported();
      if (!isBiometricEnabled) {
        setState(() {
          _biometricsEnabled = false;
        });
      }
    } on PlatformException catch (error) {
      setState(() {
        _biometricsEnabled = false;
      });
      print('Error checking biometric permission: ${error.message}');
    }
  }

  Future<void> _saveBiometricsStatus(bool value) async {
    await _secureStorage.write(
        key: 'biometricsEnabled', value: value.toString());
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
