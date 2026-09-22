import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const StomachyApp());
}

class StomachyApp extends StatelessWidget {
  const StomachyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Stomachy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: const Color(0xFFFFF5ED),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5ED),
      body: Center(
        child: Image.asset(
          'assets/images/logo_utama_stomachy.png',
          width: 175,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}