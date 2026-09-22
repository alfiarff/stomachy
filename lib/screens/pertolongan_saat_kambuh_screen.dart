import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class PertolonganSaatKambuhScreen extends StatefulWidget {
  const PertolonganSaatKambuhScreen({super.key});

  @override
  State<PertolonganSaatKambuhScreen> createState() =>
      _PertolonganSaatKambuhScreenState();
}

class _PertolonganSaatKambuhScreenState
    extends State<PertolonganSaatKambuhScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color softPeach = const Color(0xFFFFE1CC);

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
            27,
            10,
            27,
            105,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildHeroImage(),

              const SizedBox(height: 10),

              _buildIntroduction(),

              const SizedBox(height: 24),

              _buildInformationItem(
                icon: Icons.info_outline_rounded,
                title: 'Ubah Posisi Tubuh',
                description:
                    'Duduk tegak atau bersandar dengan posisi setengah duduk. '
                    'Hindari berbaring langsung, karena bisa memperparah naiknya '
                    'asam lambung.',
              ),

              const SizedBox(height: 14),

              _buildInformationItem(
                icon: Icons.sentiment_satisfied_alt_outlined,
                title: 'Minum Air Putih Hangat',
                description:
                    'Air hangat dapat membantu menenangkan lambung dan '
                    'mengurangi rasa terbakar di dada. Minumlah perlahan, '
                    'jangan sekaligus banyak.',
              ),

              const SizedBox(height: 14),

              _buildInformationItem(
                icon: Icons.shield_outlined,
                title: 'Hindari Pemicu Sederhana',
                description:
                    'Jangan konsumsi makanan/minuman yang dapat memperparah '
                    'gejala, seperti makanan pedas, berlemak, asam, kopi, soda, '
                    'dan alkohol.',
              ),

              const SizedBox(height: 14),

              _buildInformationItem(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Jika Perlu, Konsumsi Obat Antasida',
                description:
                    'Obat Antasida dapat membantu menetralkan asam lambung. '
                    'Namun, gunakan sesuai anjuran dokter atau apoteker.',
              ),

              const SizedBox(height: 24),

              _buildDoctorWarning(),

              const SizedBox(height: 20),
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
      height: 58,

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },

            child: const SizedBox(
              width: 45,
              height: 45,

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

          Expanded(
            child: Center(
              child: Text(
                'Pertolongan Pertama\nSaat Kambuh',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 21,
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
          'assets/images/pertolongan_saat_kambuh.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ===============================================================
  // INTRODUCTION
  // ===============================================================

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Tenang, Ini yang Bisa dilakukan saat GERD kambuh!',

          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 15,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: Color(0xFF171310),
          ),
        ),

        const SizedBox(height: 2),

        const Text(
          'Langkah sederhana ini bisa membantu meredakan gejala dengan '
          'cepat, sebelum kamu mendapatkan penanganan lebih lanjut',

          textAlign: TextAlign.justify,

          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w400,
            color: Color(0xFF30221E),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // INFORMATION ITEM
  // ===============================================================

  Widget _buildInformationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 32,
          height: 32,

          decoration: BoxDecoration(
            color: softPeach,
            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFB9543A),
          ),
        ),

        const SizedBox(width: 9),

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

              const SizedBox(height: 1),

              Text(
                description,

                textAlign: TextAlign.justify,

                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.25,
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

  // ===============================================================
  // DOCTOR WARNING
  // ===============================================================

  Widget _buildDoctorWarning() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        11,
        9,
        11,
        10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D4),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const Icon(
                Icons.warning_rounded,
                size: 17,
                color: Color(0xFFB9381E),
              ),

              const SizedBox(width: 6),

              const Text(
                'Segera ke Dokter jika:',

                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB9381E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          _buildWarningBullet(
            'Nyeri dada semakin berat atau tidak hilang setelah '
            'beberapa jam.',
          ),

          _buildWarningBullet(
            'Sering kambuh meski sudah melakukan langkah di atas.',
          ),

          _buildWarningBullet(
            'Muncul gejala lain seperti muntah, sulit menelan, atau '
            'penurunan berat badan.',
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // WARNING BULLET
  // ===============================================================

  Widget _buildWarningBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 23,
        bottom: 1,
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            '•  ',

            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF30221E),
            ),
          ),

          Expanded(
            child: Text(
              text,

              textAlign: TextAlign.justify,

              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w400,
                color: Color(0xFF30221E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}