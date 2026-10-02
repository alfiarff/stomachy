import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';

import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/doctor/doctorr_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

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
        scaffoldBackgroundColor:
            const Color(0xFFFFF5ED),
      ),

      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () async {
        if (!mounted) return;

        await NotificationService
            .syncWeeklyScreeningFromSettings();

        if (!mounted) return;

        await _navigateBasedOnRole();
      },
    );
  }

  // =============================================================
  // NAVIGASI BERDASARKAN ROLE
  //
  // Belum login      -> Landing
  // role admin       -> Beranda Admin
  // role doctor      -> Beranda Dokter
  // role user/kosong -> Beranda User
  // =============================================================

  Future<void> _navigateBasedOnRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LandingScreen(),
        ),
      );
      return;
    }

    Widget target = const HomeScreen();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';

      debugPrint('SPLASH: role = $role');

      if (role == 'admin') {
        target = const AdminHomeScreen();
      } else if (role == 'doctor' ||
          role == 'dokter') {
        target = const DoctorHomeScreen();
      }
    } catch (e) {
      debugPrint('SPLASH: gagal ambil role = $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => target,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF5ED),

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