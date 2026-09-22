import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class AboutStomachyScreen extends StatefulWidget {
  const AboutStomachyScreen({super.key});

  @override
  State<AboutStomachyScreen> createState() => _AboutStomachyScreenState();
}

class _AboutStomachyScreenState extends State<AboutStomachyScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // BERANDA
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // SKRINING
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // DOKTER
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // PROFIL
    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            105,
          ),
          child: Column(
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 20),

              // =====================================================
              // ABOUT CARD
              // =====================================================

              _buildAboutCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ===========================================================
      // BOTTOM NAVIGATION
      // ===========================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          // TOMBOL KEMBALI
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // JUDUL
          Expanded(
            child: Center(
              child: Text(
                'Tentang Stomachy',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // PENYEIMBANG
          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ABOUT CARD
  // ===============================================================

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // =======================================================
          // LOGO STOMACHY
          // =======================================================

          Image.asset(
            'assets/images/logo_utama_stomachy.png',
            width: 205,
            height: 190,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 205,
                height: 190,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 45,
                    color: Color(0xFFB9543A),
                  ),
                ),
              );
            },
          ),

          // =======================================================
          // VERSI
          // =======================================================

          const Text(
            'Versi 1.0.0',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF30221E),
            ),
          ),

          const SizedBox(height: 17),

          // =======================================================
          // DIVIDER
          // =======================================================

          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0xFFF3C8B8),
          ),

          const SizedBox(height: 21),

          // =======================================================
          // DESKRIPSI
          // =======================================================

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              'Stomachy adalah aplikasi yang dirancang untuk '
              'membantu anda memantau kesehatan lambung dan '
              'mendeteksi risiko GERD lebih awal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: Color(0xFF30221E),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =======================================================
          // FITUR SKRINING
          // =======================================================

          _buildFeatureItem(
            icon: Icons.health_and_safety_outlined,
            title: 'Skrining GERD',
            description:
                'Lakukan pengecekan GERD lebih awal '
                'secara mandiri.',
          ),

          const SizedBox(height: 14),

          // =======================================================
          // FITUR SKOR
          // =======================================================

          _buildFeatureItem(
            icon: Icons.show_chart_rounded,
            title: 'Grafik',
            description:
                'Pantau perkembangan riwayat skrining '
                'anda dalam bentuk grafik.',
          ),

          const SizedBox(height: 14),

          // =======================================================
          // FITUR KONSULTASI
          // =======================================================

          _buildFeatureItem(
            icon: Icons.forum_outlined,
            title: 'Konsultasi',
            description:
                'Konsultasikan keluhan anda dengan dokter '
                'secara aman dan nyaman.',
          ),

          const SizedBox(height: 24),

          // =======================================================
          // DIVIDER BAWAH
          // =======================================================

          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0xFFF3C8B8),
          ),

          const SizedBox(height: 18),

          // =======================================================
          // PENUTUP
          // =======================================================

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Stomachy hadir untuk membantu anda menjaga '
              'kesehatan lambung dengan lebih mudah, kapan saja '
              'dan dimana saja.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: Color(0xFF30221E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FEATURE ITEM
  // ===============================================================

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ICON
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE1C8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF705044),
          ),
        ),

        const SizedBox(width: 10),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF493C37),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}