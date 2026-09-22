import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ScreeningResultScreen extends StatefulWidget {
  final String? date;
  final String? status;
  final String? complaint;
  final String? age;
  final String? gender;
  final String? symptom;
  final String? image;
  final bool? isRisk;

  final Map<String, bool?>? step2Answers;
  final Map<String, String?>? step3Answers;

  const ScreeningResultScreen({
    super.key,
    this.date,
    this.status,
    this.complaint,
    this.age,
    this.gender,
    this.symptom,
    this.image,
    this.isRisk,
    this.step2Answers,
    this.step3Answers,
  });

  @override
  State<ScreeningResultScreen> createState() =>
      _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen > {
  int _selectedIndex = 1;

  // ===============================================================
  // COLORS
  // ===============================================================

  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color cardColor = Color(0xFFFFE8D7);
  static const Color primaryBrown = Color(0xFF493028);
  static const Color accentBrown = Color(0xFFB65339);
  static const Color orangeBrown = Color(0xFFB65339);

  // ===============================================================
  // NAVIGATION
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

              _buildAdviceSection(),

              const SizedBox(height: 31),

              _buildDisclaimer(),

              const SizedBox(height: 35),

              _buildDoctorButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // =============================================================
      // BOTTOM NAVIGATION
      // =============================================================

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
                  fontSize: 22,
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
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ---------------------------------------------------------
          // MASCOT
          // ---------------------------------------------------------

          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/images/maskot_berisiko.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 3),

          // ---------------------------------------------------------
          // KETERANGAN
          // ---------------------------------------------------------

          const Text(
            'Kamu berisiko mengalami',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryBrown,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'GERD',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 25,
              fontWeight: FontWeight.w500,
              color: accentBrown,
            ),
          ),

          const SizedBox(height: 2),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Text(
              'Berdasarkan jawaban yang kamu masukkan, terdapat\n'
              'pola gejala yang sesuai dengan risiko Gastrophaeal\n'
              'Reflux Disease (GERD)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
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

  Widget _buildAdviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 8,
          ),
          child: Text(
            'Saran untuk kamu',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryBrown,
            ),
          ),
        ),

        const SizedBox(height: 9),

        _buildAdviceItem(
          'Perhatikan pola makan dan gaya hidup',
        ),

        _buildAdviceItem(
          'Hindari makanan pemicu',
        ),

        _buildAdviceItem(
          'Jaga berat badan ideal',
        ),

        _buildAdviceItem(
          'Jika keluhan berlanjut, konsultasikan ke dokter',
        ),
      ],
    );
  }

  // ===============================================================
  // ADVICE ITEM
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
              shape: BoxShape.circle,
              color: accentBrown,
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
                fontFamily: 'Nunito',
                fontSize: 14,
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
                fontSize: 14,
                color: Color(0xFF332823),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DOKTER BUTTON
  // ===============================================================

  Widget _buildDoctorButton() {
    return Center(
      child: SizedBox(
        width: 228,
        height: 39,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBrown,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: const Text(
            'Konsultasi Dokter',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}