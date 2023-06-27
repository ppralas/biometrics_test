import 'package:biometric/presentation/login_page.dart';
import 'package:flutter/material.dart';
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

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        setState(() {
          _biometricsEnabled = true;
        });
      } else {
        setState(() {
          _biometricsEnabled = false;
        });
        // Show error or display a message that the device does not support biometrics.
      }
    } else {
      setState(() {
        _biometricsEnabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBiometricsStatus();
  }

  Future<void> _loadBiometricsStatus() async {
    String? enabled = await _secureStorage.read(key: 'biometricsEnabled');
    setState(() {
      _biometricsEnabled = enabled == 'true';
    });
  }

  Future<void> _saveBiometricsStatus(bool value) async {
    await _secureStorage.write(
        key: 'biometricsEnabled', value: value.toString());
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
                  onChanged: (value) {
                    _toggleBiometrics(value);
                    _saveBiometricsStatus(value);
                  },
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  ),
                  child: const Text('Log out'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
