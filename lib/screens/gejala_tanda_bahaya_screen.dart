import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class GejalaTandaBahayaScreen extends StatefulWidget {
  const GejalaTandaBahayaScreen({super.key});

  @override
  State<GejalaTandaBahayaScreen> createState() =>
      _GejalaTandaBahayaScreenState();
}

class _GejalaTandaBahayaScreenState
    extends State<GejalaTandaBahayaScreen> {
  // ===============================================================
  // INDEX BOTTOM NAVIGATION
  // ===============================================================

  int _selectedIndex = 3;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);

  final Color cardColor = const Color(0xFFFFFCF9);

  final Color primaryRed = const Color(0xFFB9543A);

  final Color darkText = const Color(0xFF30221E);

  final Color secondaryText = const Color(0xFF493C37);

  final Color peachColor = const Color(0xFFFFE4D1);

  final Color lightPeach = const Color(0xFFFFE9D9);

  final Color borderColor = const Color(0xFFFF806A);

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // =============================================================
    // BERANDA
    // =============================================================

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // =============================================================
    // SKRINING
    // =============================================================

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // =============================================================
    // DOKTER
    // =============================================================

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // =============================================================
    // EDUKASI
    // =============================================================

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // =============================================================
    // PROFIL
    // =============================================================

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
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 20),

              // =====================================================
              // GAMBAR UTAMA
              // =====================================================

              _buildHeroImage(),

              const SizedBox(height: 17),

              // =====================================================
              // JUDUL
              // =====================================================

              const Text(
                'Lebih lanjut tentang GERD',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 5),

              // =====================================================
              // DESKRIPSI
              // =====================================================

              const Text(
                'Kenali gejala GERD dan tanda bahaya yang perlu '
                'diperhatikan agar kamu dapat mengetahui kapan '
                'keluhan masih dapat ditangani dan kapan perlu '
                'mendapatkan pemeriksaan dokter.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF30221E),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 13),

              // =====================================================
              // GEJALA UMUM
              // =====================================================

              _buildInfoSection(
                icon: Icons.sentiment_satisfied_alt_outlined,
                iconColor: const Color(0xFFB9543A),
                title: 'Gejala Umum',
                child: _buildChecklist(
                  items: [
                    'Rasa terbakar di dada (heartburn)',
                    'Rasa asam di mulut',
                    'Mual atau begah',
                    'Batuk kronis atau suara serak',
                    'Nyeri saat menelan',
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =====================================================
              // GEJALA YANG PERLU DIWASPADAI
              // =====================================================

              _buildInfoSection(
                icon: Icons.sentiment_dissatisfied_outlined,
                iconColor: const Color(0xFFB9543A),
                title: 'Gejala yang Perlu Diwaspadai',
                child: _buildChecklist(
                  items: [
                    'Nyeri dada yang berat atau menetap',
                    'Sulit atau nyeri saat menelan',
                    'Makanan terasa tersangkut saat ditelan',
                    'Muntah berulang',
                    'Berat badan turun tanpa sebab yang jelas',
                    'Muntah darah atau BAB berwarna hitam',
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =====================================================
              // JANGAN ABAIKAN GEJALA
              // =====================================================

              _buildInfoSection(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFB9543A),
                title: 'Jangan Abaikan Gejala',
                description:
                    'Gejala yang sering muncul dapat menjadi tanda '
                    'bahwa kamu perlu mendapatkan pemeriksaan. Catat '
                    'frekuensi dan kondisi saat gejala muncul agar '
                    'lebih mudah menjelaskannya kepada dokter.',
              ),

              const SizedBox(height: 10),

              // =====================================================
              // DATA PREVALENSI
              // =====================================================

              _buildInfoSection(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: const Color(0xFFB9543A),
                title: 'Data Prevalensi di Indonesia',
                description:
                    'GERD adalah kondisi umum di seluruh dunia, dan '
                    'di Indonesia, diperkirakan sekitar 274.496 orang '
                    'menderita dari itu pada tahun 2021. Namun, tidak '
                    'ada statistik nasional, dengan angka kematian '
                    'yang sangat rendah sekitar 0,02–0,20 per 100.000 '
                    'orang.',
              ),

              const SizedBox(height: 12),

              // =====================================================
              // CARD INGAT
              // =====================================================

              _buildReminderCard(),

              const SizedBox(height: 18),
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
          // =========================================================
          // TOMBOL KEMBALI
          // =========================================================

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

          // =========================================================
          // JUDUL
          // =========================================================

          Expanded(
            child: Center(
              child: Text(
                'Gejala & Tanda Bahaya',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // =========================================================
          // PENYEIMBANG
          // =========================================================

          const SizedBox(
            width: 45,
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
          'assets/images/gejala_tanda_bahaya.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ===============================================================
  // INFO SECTION
  // ===============================================================

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? description,
    Widget? child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // ICON
        // =========================================================

        Container(
          width: 31,
          height: 31,

          margin: const EdgeInsets.only(
            top: 1,
          ),

          decoration: BoxDecoration(
            color: peachColor,
            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 9),

        // =========================================================
        // CONTENT
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================================================
              // TITLE
              // ===================================================

              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF30221E),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),

              // ===================================================
              // DESCRIPTION
              // ===================================================

              if (description != null)
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF30221E),
                    height: 1.3,
                  ),
                ),

              // ===================================================
              // CHILD
              // ===================================================

              if (child != null) child,
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CHECKLIST
  // ===============================================================

  Widget _buildChecklist({
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 1),

        ...items.map(
          (item) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 1,
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CHECK ICON
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 1,
                    ),

                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: primaryRed,
                    ),
                  ),

                  const SizedBox(width: 4),

                  // =================================================
                  // TEXT
                  // =================================================

                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF30221E),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ===============================================================
  // REMINDER CARD
  // ===============================================================

  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        11,
        9,
        11,
        10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D2),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================================================
          // JUDUL
          // =========================================================

          const Text(
            'Ingat!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF30221E),
            ),
          ),

          const SizedBox(height: 2),

          // =========================================================
          // ISI
          // =========================================================

          const Text(
            'Mengenali gejala sejak awal dapat membantu kamu '
            'menentukan langkah yang tepat. Jika muncul tanda '
            'bahaya, jangan menunda untuk mencari pertolongan medis.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF30221E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}