import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class HasilSkriningTidakBerisikoScreen extends StatefulWidget {
  const HasilSkriningTidakBerisikoScreen({super.key});

  @override
  State<HasilSkriningTidakBerisikoScreen> createState() =>
      _HasilSkriningTidakBerisikoScreenState();
}

class _HasilSkriningTidakBerisikoScreenState
    extends State<HasilSkriningTidakBerisikoScreen> {
  int _selectedIndex = 1;

  // ===============================================================
  // COLORS
  // ===============================================================

  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color resultCardColor = Color(0xFFFFE8D7);
  static const Color primaryBrown = Color(0xFF493028);
  static const Color accentBrown = Color(0xFFB65339);
  static const Color greenColor = Color(0xFF159B7D);

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

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
            26,
            8,
            26,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 12),

              _buildResultCard(),

              const SizedBox(height: 25),

              _buildAdvice(),

              const SizedBox(height: 31),

              _buildDisclaimer(),

              const SizedBox(height: 105),
            ],
          ),
        ),
      ),

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
      height: 50,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Hasil Skrining',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: primaryBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // ===============================================================
  // RESULT CARD
  // ===============================================================

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      height: 328,
      decoration: BoxDecoration(
        color: resultCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ---------------------------------------------------------
          // MASKOT
          // ---------------------------------------------------------

          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/images/mascot_happy.png.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 2),

          // ---------------------------------------------------------
          // HASIL
          // ---------------------------------------------------------

          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryBrown,
              ),
              children: [
                TextSpan(
                  text: 'Kamu ',
                ),
                TextSpan(
                  text: 'tidak berisiko',
                  style: TextStyle(
                    color: greenColor,
                  ),
                ),
                TextSpan(
                  text: ' mengalami',
                ),
              ],
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'GERD',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 25,
              fontWeight: FontWeight.w500,
              color: greenColor,
            ),
          ),

          const SizedBox(height: 2),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              'Berdasarkan jawaban yang kamu masukkan, tidak\n'
              'ditemukan pola gejala yang mengarah pada risiko\n'
              'Gastroeophageal Reflux Disease (GERD).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.35,
                color: Color(0xFF332823),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SARAN
  // ===============================================================

  Widget _buildAdvice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 8,
          ),
          child: Text(
            'Saran untuk tetap sehat',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryBrown,
            ),
          ),
        ),

        const SizedBox(height: 9),

        _buildAdviceItem(
          'Jaga pola makan teratur',
        ),

        _buildAdviceItem(
          'Hindari makanan yang memicu keluhan',
        ),

        _buildAdviceItem(
          'Istirahat yang cukup',
        ),

        _buildAdviceItem(
          'Tetap perhatikan perubahan gejala',
        ),
      ],
    );
  }

  // ===============================================================
  // ITEM SARAN
  // ===============================================================

  Widget _buildAdviceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 17,
        bottom: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: accentBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 10,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF332823),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DISCLAIMER
  // ===============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      height: 37,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD7B8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentBrown,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Hasil skrining ini bukan merupakan diagnosis medis.',
              style: TextStyle(
                fontSize: 8.5,
                color: Color(0xFF332823),
              ),
            ),
          ),
        ],
      ),
    );
  }
}