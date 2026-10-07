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
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
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
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 16),

              // =====================================================
              // CARD TIPS
              // =====================================================

              _buildTipCard(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFE8804C),
                iconBackground: const Color(0xFFFFE9DC),
                title: 'Atur Pola Tidur',
                description:
                    'Usahakan tidur dan bangun pada jam yang sama setiap '
                    'hari agar ritme tubuh lebih stabil.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                icon: Icons.no_food_rounded,
                iconColor: const Color(0xFF7B6BD0),
                iconBackground: const Color(0xFFEDE9FB),
                title: 'Hindari Makan Sebelum Tidur',
                description:
                    'Berikan jeda minimal 2–3 jam setelah makan sebelum '
                    'berbaring untuk mengurangi risiko refluks asam lambung.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                icon: Icons.bed_rounded,
                iconColor: const Color(0xFF5A9FE0),
                iconBackground: const Color(0xFFE3EEFC),
                title: 'Gunakan Posisi Tidur yang Tepat',
                description:
                    'Tidur dengan posisi kepala lebih tinggi (menggunakan '
                    'bantal tambahan atau kasur yang miring) dapat membantu '
                    'mencegah asam lambung naik ke esofagus.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                icon: Icons.self_improvement_rounded,
                iconColor: const Color(0xFF4AA978),
                iconBackground: const Color(0xFFDFF2E7),
                title: 'Kelola Stres',
                description:
                    'Lakukan aktivitas relaksasi seperti pernapasan dalam, '
                    'meditasi, atau mendengarkan musik yang menenangkan.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFFE8804C),
                iconBackground: const Color(0xFFFFE9DC),
                title: 'Batasi Penggunaan Gadget Sebelum Tidur',
                description:
                    'Kurangi paparan layar minimal 1 jam sebelum tidur agar '
                    'kualitas tidur lebih baik.',
              ),

              const SizedBox(height: 16),

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
                'Artikel',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
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
  // CARD TIPS
  //
  // Mengikuti gaya card pada ApaItuGerdScreen:
  // - background putih
  // - radius 16
  // - shadow lembut
  // - tanpa border
  // - icon dengan background warna lembut
  // - judul Nunito 12 w800
  // - deskripsi Nunito 11
  // ===============================================================

  Widget _buildTipCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        13,
        14,
        13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================================================
          // ICON
          // =========================================================

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          // =========================================================
          // TEKS
          // =========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF30221E),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF30221E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF493028),
            ),
          ),

          SizedBox(height: 3),

          Text(
            'Tidur yang cukup bukan hanya membuat tubuh lebih segar '
            'tetapi juga membantu mengurangi keluhan GERD dan menjaga '
            'kualitas hidup sehari-hari.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Color(0xFF332823),
            ),
          ),
        ],
      ),
    );
  }
}