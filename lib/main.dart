import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Splash tampil minimal 3 detik
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Cek sesi login yang tersimpan di perangkat
    User? user = FirebaseAuth.instance.currentUser;

    // Cadangan: kalau null, tunggu Firebase selesai
    // membaca sesi tersimpan (maksimal 2 detik)
    user ??= await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((u) => u != null)
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => FirebaseAuth.instance.currentUser,
        );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => user != null
            ? const HomeScreen()
            : const LandingScreen(),
      ),
      (route) => false,
    );
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