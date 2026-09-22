import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ApaItuGerdScreen extends StatefulWidget {
  const ApaItuGerdScreen({super.key});

  @override
  State<ApaItuGerdScreen> createState() => _ApaItuGerdScreenState();
}

class _ApaItuGerdScreenState extends State<ApaItuGerdScreen> {
  int _selectedIndex = 3;

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
            27,
            5,
            27,
            18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 8),

              // =====================================================
              // HERO IMAGE
              // =====================================================

              _buildHeroImage(),

              const SizedBox(height: 16),

              // =====================================================
              // JUDUL
              // =====================================================

              const Text(
                'Apa Itu GERD?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 4),

              // =====================================================
              // DESKRIPSI
              // =====================================================

              const Text(
                'GERD (Gastroesophageal Reflux Disease) adalah kondisi ketika asam '
                'lambung naik ke kerongkongan secara berulang sehingga '
                'menyebabkan berbagai gejala yang mengganggu.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 13),

              // =====================================================
              // PENYEBAB GERD
              // =====================================================

              _buildInfoSection(
                icon: Icons.sentiment_dissatisfied_outlined,
                title: 'Penyebab GERD',
                child: _buildCheckItem(
                  'Terjadi ketika otot cincin di ujung bawah kerongkongan '
                  '(sfingter esofagus bagian bawah) melemah atau relaksasi '
                  'yang tidak tepat, sehingga asam lambung mudah naik kembali '
                  'ke kerongkongan.',
                ),
              ),

              const SizedBox(height: 13),

              // =====================================================
              // GEJALA UMUM
              // =====================================================

              _buildInfoSection(
                icon: Icons.sentiment_satisfied_alt_outlined,
                title: 'Gejala Umum',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckItem('Rasa terbakar di dada (heartburn)'),
                    _buildCheckItem('Rasa asam di mulut'),
                    _buildCheckItem('Mual atau begah'),
                    _buildCheckItem('Batuk kronis atau suara serak'),
                    _buildCheckItem('Nyeri saat menelan'),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              // =====================================================
              // DAMPAK JIKA TIDAK DITANGANI
              // =====================================================

              _buildInfoSection(
                icon: Icons.shield_outlined,
                title: 'Dampak Jika Tidak Ditangani',
                child: const Text(
                  'GERD yang tidak ditangani dapat menyebabkan munculnya '
                  'gejala lanjutan yang mungkin terjadi terkait dengan komplikasi '
                  'GERD atau masalah kesehatan serius lainnya.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.3,
                    color: Color(0xFF30221E),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              // =====================================================
              // KAPAN KE DOKTER
              // =====================================================

              _buildInfoSection(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Kapan Harus ke Dokter?',
                child: const Text(
                  'Segera konsultasikan dengan dokter jika gejala GERD sering '
                  'terjadi (lebih dari 2 kali seminggu) atau semakin parah dan '
                  'mengganggu aktivitas sehari-hari.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF30221E),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // INGAT
              // =====================================================

              _buildRememberBox(),

              const SizedBox(height: 4),
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
      height: 48,
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
                'Apa Itu GERD?',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryBrown,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 42,
          ),
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
          'assets/images/apa_itu_gerd.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ===============================================================
  // INFORMATION SECTION
  // ===============================================================

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ICON
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFFFDEC8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: accentBrown,
          ),
        ),

        const SizedBox(width: 9),

        // CONTENT
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
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 2),

              child,
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CHECK ITEM
  // ===============================================================

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '◉',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFB65339),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF30221E),
              ),
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
        14,
        10,
        14,
        10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D2),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingat!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171310),
            ),
          ),

          SizedBox(height: 2),

          Text(
            'GERD dapat dikendalikan dengan perubahan gaya hidup sehat '
            'dan pengobatan yang tepat.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF30221E),
            ),
          ),
        ],
      ),
    );
  }
}