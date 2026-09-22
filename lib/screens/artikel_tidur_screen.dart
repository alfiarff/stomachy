import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ArtikelTidurScreen extends StatefulWidget {
  const ArtikelTidurScreen({super.key});

  @override
  State<ArtikelTidurScreen> createState() => _ArtikelTidurScreenState();
}

class _ArtikelTidurScreenState extends State<ArtikelTidurScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);
  final Color accentBrown = const Color(0xFFB65339);

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
            18,
            8,
            18,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 14),

              // =====================================================
              // GAMBAR UTAMA
              // =====================================================

              _buildHeroImage(),

              const SizedBox(height: 15),

              // =====================================================
              // JUDUL ARTIKEL
              // =====================================================

              const Text(
                'Tips Tidur Nyenyak untuk Penderita GERD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF493028),
                ),
              ),

              const SizedBox(height: 5),

              // =====================================================
              // PEMBUKA ARTIKEL
              // =====================================================

              const Text(
                'Tidur yang cukup dan berkualitas sangat penting untuk menjaga '
                'kesehatan tubuh, termasuk bagi penderita GERD. Kurang tidur dapat '
                'meningkatkan produksi asam lambung dan memperparah gejala GERD '
                'seperti heartburn, rasa panas di dada, dan regurgitasi.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF332823),
                ),
              ),

              const SizedBox(height: 12),

              // =====================================================
              // BOX TIPS
              // =====================================================

              _buildTipsHeader(),

              const SizedBox(height: 7),

              // =====================================================
              // TIPS 1
              // =====================================================

              _buildTipItem(
                number: '1',
                title: 'Atur Pola Tidur',
                description:
                    'Usahakan tidur dan bangun pada jam yang sama setiap '
                    'hari agar ritme tubuh lebih stabil.',
              ),

              const SizedBox(height: 7),

              // =====================================================
              // TIPS 2
              // =====================================================

              _buildTipItem(
                number: '2',
                title: 'Hindari Makan Sebelum Tidur',
                description:
                    'Berikan jeda minimal 2–3 jam setelah makan sebelum '
                    'berbaring untuk mengurangi risiko refluks asam lambung.',
              ),

              const SizedBox(height: 7),

              // =====================================================
              // TIPS 3
              // =====================================================

              _buildTipItem(
                number: '3',
                title: 'Gunakan Posisi Tidur yang Tepat',
                description:
                    'Tidur dengan posisi kepala lebih tinggi (menggunakan '
                    'bantal tambahan atau kasur yang miring) dapat membantu '
                    'mencegah asam lambung naik ke esofagus.',
              ),

              const SizedBox(height: 7),

              // =====================================================
              // TIPS 4
              // =====================================================

              _buildTipItem(
                number: '4',
                title: 'Kelola Stres',
                description:
                    'Lakukan aktivitas relaksasi seperti pernapasan dalam, '
                    'meditasi, atau mendengarkan musik yang menenangkan.',
              ),

              const SizedBox(height: 7),

              // =====================================================
              // TIPS 5
              // =====================================================

              _buildTipItem(
                number: '5',
                title: 'Batasi Penggunaan Gadget Sebelum Tidur',
                description:
                    'Kurangi paparan layar minimal 1 jam sebelum tidur agar '
                    'kualitas tidur lebih baik.',
              ),

              const SizedBox(height: 14),

              // =====================================================
              // BOX INGAT
              // =====================================================

              _buildRememberBox(),

              const SizedBox(height: 15),
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
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Tips Tidur Nyenyak',
                style: TextStyle(
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
  // HERO IMAGE
  // ===============================================================

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/tips_tidur_nyenyak.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ===============================================================
  // TIPS HEADER
  // ===============================================================

  Widget _buildTipsHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE1CE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lightbulb_outline_rounded,
            size: 17,
            color: Color(0xFFB65339),
          ),
        ),

        const SizedBox(width: 8),

        const Expanded(
          child: Text(
            'Tips Tidur Nyenyak untuk Penderita GERD',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF493028),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // TIP ITEM
  // ===============================================================

  Widget _buildTipItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOMOR
        Container(
          width: 17,
          height: 17,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(
            color: Color(0xFFFFE1CE),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8E422F),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF493028),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF332823),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // REMEMBER BOX
  // ===============================================================

  Widget _buildRememberBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        10,
        13,
        10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingat!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF493028),
            ),
          ),

          SizedBox(height: 3),

          Text(
            'Tidur yang cukup bukan hanya membuat tubuh lebih segar '
            'tetapi juga membantu mengurangi keluhan GERD dan menjaga '
            'kualitas hidup sehari-hari.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF332823),
            ),
          ),
        ],
      ),
    );
  }
}