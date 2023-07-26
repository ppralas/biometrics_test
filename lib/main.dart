import 'package:biometric/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Biometrics App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer(builder: (context, watch, _) {
          return const LoginPage();
        }),
      ),
    );
  }
}
