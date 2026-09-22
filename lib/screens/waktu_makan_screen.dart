import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class WaktuMakanScreen extends StatefulWidget {
  const WaktuMakanScreen({super.key});

  @override
  State<WaktuMakanScreen> createState() => _WaktuMakanScreenState();
}

class _WaktuMakanScreenState extends State<WaktuMakanScreen> {
  int _selectedIndex = 3;

  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color primaryBrown = Color(0xFF493028);
  static const Color accentBrown = Color(0xFFB65339);
  static const Color lightOrange = Color(0xFFFFE7D8);

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
            18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 14),

              _buildHeroImage(),

              const SizedBox(height: 14),

              // =====================================================
              // JUDUL
              // =====================================================

              const Text(
                'Kapan waktu makan yang ideal?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accentBrown,
                ),
              ),

              const SizedBox(height: 5),

              // =====================================================
              // DESKRIPSI
              // =====================================================

              const Text(
                'Penderita GERD disarankan untuk makan dalam porsi kecil namun '
                'lebih sering, dengan waktu yang teratur.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF332823),
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // JADWAL MAKAN
              // =====================================================

              _buildMealSchedule(
                meal: 'Sarapan',
                time: '06.00 - 08.00',
                description:
                    'Memberi energi untuk memulai aktivitas dan\n'
                    'membantu lambung lebih stabil.',
              ),

              _buildMealSchedule(
                meal: 'Camilan Pagi',
                time: '09.30 - 10.00',
                description:
                    'Menjaga kadar asam lambung tetap seimbang\n'
                    'dan mencegah lambung kosong terlalu lama.',
              ),

              _buildMealSchedule(
                meal: 'Makan siang',
                time: '12.30 - 13.00',
                description:
                    'Porsi sedang dengan makanan yang mudah\n'
                    'dicerna.',
              ),

              _buildMealSchedule(
                meal: 'Camilan Sore',
                time: '15.00 - 17.00',
                description:
                    'Membantu mencegah perut terlalu kosong\n'
                    'menjelang malam.',
              ),

              _buildMealSchedule(
                meal: 'Makan malam',
                time: '12.30 - 13.00',
                description:
                    'Porsi lebih ringan dibanding siang hari, agar tidak\n'
                    'terjadi peningkatan asam lambung saat berbaring.',
              ),

              const SizedBox(height: 12),

              // =====================================================
              // EDUKASI TAMBAHAN
              // =====================================================

              _buildAdditionalEducation(),

              const SizedBox(height: 50),
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
                'Waktu makan yang tepat',
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
          'assets/images/waktu_makan.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ===============================================================
  // JADWAL MAKAN
  // ===============================================================

  Widget _buildMealSchedule({
    required String meal,
    required String time,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // NAMA MAKAN
          // ---------------------------------------------------------

          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentBrown,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentBrown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 0),

          // ---------------------------------------------------------
          // DESKRIPSI
          // ---------------------------------------------------------

          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Color(0xFF332823),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EDUKASI TAMBAHAN
  // ===============================================================

  Widget _buildAdditionalEducation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        10,
        13,
        9,
      ),
      decoration: BoxDecoration(
        color: lightOrange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // ICON
          // ---------------------------------------------------------

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: accentBrown,
            ),
          ),

          const SizedBox(width: 9),

          // ---------------------------------------------------------
          // ISI
          // ---------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edukasi Tambahan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentBrown,
                  ),
                ),

                const SizedBox(height: 4),

                _buildAdditionalItem(
                  'Makan dalam porsi kecil, tetapi sering.',
                ),

                _buildAdditionalItem(
                  'Kunyah makanan dengan perlahan.',
                ),

                _buildAdditionalItem(
                  'Hindari langsung berbaring setelah makan.',
                ),

                _buildAdditionalItem(
                  'Minum air putih yang cukup, tetapi jangan terlalu banyak saat makan.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ITEM EDUKASI
  // ===============================================================

  Widget _buildAdditionalItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 1,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 10,
              color: accentBrown,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                color: accentBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}