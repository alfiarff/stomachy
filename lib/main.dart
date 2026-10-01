import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/doctor/doctorr_home_screen.dart';

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
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    // Tunggu Firebase membaca sesi login jika currentUser belum tersedia.
    if (user == null) {
      try {
        user = await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(
              const Duration(seconds: 2),
            );
      } catch (e) {
        user = FirebaseAuth.instance.currentUser;
      }
    }

    if (!mounted) return;

    // =========================================================
    // BELUM LOGIN
    // =========================================================
    // Kalau aplikasi dibuka dan tidak ada sesi login,
    // masuk ke LandingScreen.
    if (user == null) {
      _goToLanding();
      return;
    }

    // =========================================================
    // SUDAH LOGIN
    // =========================================================
    // Cek role dari Firestore.
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!mounted) return;

      String role = '';

      if (userDoc.exists) {
        final Map<String, dynamic>? data = userDoc.data();

        if (data != null) {
          role = data['role']?.toString().trim().toLowerCase() ?? '';
        }
      }

      // Dokter
      if (role == 'doctor' || role == 'dokter') {
        _goToDoctorHome();
        return;
      }

      // User biasa
      _goToUserHome();
    } catch (e) {
      if (!mounted) return;

      // Kalau gagal membaca role, tetap masuk ke Home user
      // sebagai fallback.
      _goToUserHome();
    }
  }

  void _goToLanding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LandingScreen(),
      ),
      (route) => false,
    );
  }

  void _goToUserHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  void _goToDoctorHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorHomeScreen(),
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