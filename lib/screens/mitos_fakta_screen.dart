import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class MitosFaktaScreen extends StatefulWidget {
  const MitosFaktaScreen({super.key});

  @override
  State<MitosFaktaScreen> createState() => _MitosFaktaScreenState();
}

class _MitosFaktaScreenState extends State<MitosFaktaScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryRed = const Color(0xFFB9543A);
  final Color softOrange = const Color(0xFFFFE1C8);

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
            22,
            12,
            22,
            105,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              // GAMBAR ARTIKEL
              _buildArticleImage(),

              const SizedBox(height: 18),

              // JUDUL ARTIKEL
              const Text(
                'Yuk, Kenali Mitos dan Fakta tentang GERD!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 5),

              // DESKRIPSI ARTIKEL
              const Text(
                'Banyak informasi yang beredar, tapi tidak semuanya benar. '
                'Yuk simak penjelasannya!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 17),

              // MITOS & FAKTA 1
              _buildMitosFaktaItem(
                icon: Icons.error_outline_rounded,
                mitos:
                    'GERD hanya terjadi setelah makan makanan pedas.',
                fakta:
                    'GERD bisa dipicu oleh berbagai jenis makanan, '
                    'termasuk makanan berlemak, asam, kopi, cokelat, '
                    'atau bahkan makanan yang tidak pedas.',
              ),

              const SizedBox(height: 18),

              // MITOS & FAKTA 2
              _buildMitosFaktaItem(
                icon: Icons.sentiment_dissatisfied_outlined,
                mitos:
                    'Semua orang dengan GERD harus menghindari makanan yang sama.',
                fakta:
                    'Pemicu GERD dapat berbeda pada setiap orang. '
                    'Penanganan nonfarmakologis dapat dilakukan dengan '
                    'modifikasi gaya hidup sesuai kondisi masing-masing.',
              ),

              const SizedBox(height: 18),

              // MITOS & FAKTA 3
              _buildMitosFaktaItem(
                icon: Icons.shield_outlined,
                mitos:
                    'GERD hanya menyebabkan sakit maag atau rasa terbakar di dada.',
                fakta:
                    'Olahraga ringan justru aman dan bermanfaat untuk '
                    'pencernaan, selama tidak dilakukan setelah makan '
                    'dan tidak terlalu berat.',
              ),

              const SizedBox(height: 18),

              // MITOS & FAKTA 4
              _buildMitosFaktaItem(
                icon: Icons.opacity_outlined,
                mitos:
                    'Susu bisa langsung meredakan asam lambung.',
                fakta:
                    'Susu memang bisa menenangkan sementara, tetapi '
                    'pada sebagian orang justru dapat meningkatkan '
                    'produksi asam lambung.',
              ),

              const SizedBox(height: 12),
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
      height: 42,
      child: Row(
        children: [
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

          const Expanded(
            child: Center(
              child: Text(
                'Mitos vs Fakta\nGERD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ARTICLE IMAGE
  // ===============================================================

  Widget _buildArticleImage() {
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
          'assets/images/mitos_fakta.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 50,
                color: Color(0xFFB9543A),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // MITOS & FAKTA ITEM
  // ===============================================================

  Widget _buildMitosFaktaItem({
    required IconData icon,
    required String mitos,
    required String fakta,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: softOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: primaryRed,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MITOS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✕ ',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB83D27),
                    ),
                  ),
                  const Text(
                    'Mitos',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB83D27),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 1),

              Text(
                mitos,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 3),

              // FAKTA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✓ ',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF168B65),
                    ),
                  ),
                  const Text(
                    'Fakta',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF168B65),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 1),

              Text(
                fakta,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF30221E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}