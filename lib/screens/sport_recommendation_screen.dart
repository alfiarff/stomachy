import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class RecommendationSportScreen extends StatefulWidget {
  const RecommendationSportScreen({super.key});

  @override
  State<RecommendationSportScreen> createState() =>
      _RecommendationSportScreenState();
}

class _RecommendationSportScreenState
    extends State<RecommendationSportScreen> {
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
              // CONTENT CARD
              // =====================================================

              _buildSportCard(),

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
          // =======================================================
          // TOMBOL KEMBALI
          // =======================================================

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

          // =======================================================
          // JUDUL
          // =======================================================

          Expanded(
            child: Center(
              child: Text(
                'Rekomendasi Olahraga',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // =======================================================
          // PENYEIMBANG HEADER
          // =======================================================

          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SPORT CARD
  // ===============================================================

  Widget _buildSportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        20,
        13,
        23,
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
          // JUDUL UTAMA
          // =======================================================

          const Text(
            'Olahraga Untuk\nLambung Lebih Sehat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB9543A),
            ),
          ),

          const SizedBox(height: 15),

          // =======================================================
          // GAMBAR OLAHRAGA
          // =======================================================

          Image.asset(
            'assets/images/rekomendasi_olahraga.png',
            width: 220,
            height: 135,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 220,
                height: 135,
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

          const SizedBox(height: 3),

          // =======================================================
          // DESKRIPSI
          // =======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              15,
              12,
              15,
              12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFE1C8),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Olahraga dengan jenis dan teknik yang tepat dapat  '
              'membantu mengendalikan gejala GERD, menjaga '
              'kesehatan pencernaan, serta mengurangi risiko '
              'kekambuhan asam lambung secara alami.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: Color(0xFF30221E),
              ),
            ),
          ),

          const SizedBox(height: 19),

          // =======================================================
          // YOGA
          // =======================================================

          _buildSportItem(
            imagePath: 'assets/images/yoga.png',
            title: 'Yoga',
            description:
                'Melatih pernapasan dalam, meningkatkan relaksasi '
                'tubuh dan membantu menurunkan stres.',
          ),

          const SizedBox(height: 9),

          // =======================================================
          // JALAN SANTAI
          // =======================================================

          _buildSportItem(
            imagePath: 'assets/images/jalan_kaki.png',
            title: 'Jalan Santai',
            description:
                'Membantu melancarkan pencernaan tanpa meningkatkan '
                'tekanan intraabdomen dan membuat tubuh lebih rileks.',
          ),

          const SizedBox(height: 9),

          // =======================================================
          // BERENANG
          // =======================================================

          _buildSportItem(
            imagePath: 'assets/images/berenang.png',
            title: 'Berenang',
            description:
                'Dilakukan dengan tempo ringan dan durasi yang secukupnya. '
                'Jeda setelah makan untuk mengurangi risiko refluks asam lambung.',
          ),

          const SizedBox(height: 9),

          // =======================================================
          // STRETCHING
          // =======================================================

          _buildSportItem(
            imagePath: 'assets/images/peregangan.png',
            title: 'Stretching',
            description:
                'Membantu melemaskan otot-otot tubuh, meningkatkan , '
                'fleksibilitas, dan membuat tubuh lebih rileks.',
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SPORT ITEM
  // ===============================================================

  Widget _buildSportItem({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 64,
      ),
      padding: const EdgeInsets.fromLTRB(
        10,
        7,
        10,
        7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =======================================================
          // GAMBAR
          // =======================================================

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_run_rounded,
                    size: 27,
                    color: Color(0xFFB9543A),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // =======================================================
          // TEKS
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // NAMA OLAHRAGA
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

                // DESKRIPSI
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF493C37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}