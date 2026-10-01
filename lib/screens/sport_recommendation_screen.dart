import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/stomachy_card.dart';

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
  final Color mainBrown = const Color(0xFFB9543A);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================================================
              // HEADER
              // ===================================================

              _buildHeader(),

              const SizedBox(height: 18),

              // ===================================================
              // HERO CARD
              // ===================================================

              _buildHeroCard(),

              const SizedBox(height: 24),

              // ===================================================
              // OLAHRAGA 1
              // ===================================================

              _buildSportCard(
                imagePath: 'assets/images/yoga.png',
                title: 'Yoga',
                category: 'Relaksasi',
                description:
                    'Melatih pernapasan dalam, meningkatkan '
                    'relaksasi tubuh dan membantu menurunkan stres.',
              ),

              const SizedBox(height: 17),

              // ===================================================
              // OLAHRAGA 2
              // ===================================================

              _buildSportCard(
                imagePath: 'assets/images/jalan_kaki.png',
                title: 'Jalan Santai',
                category: 'Rendah Intensitas',
                description:
                    'Membantu melancarkan pencernaan tanpa '
                    'meningkatkan tekanan intraabdomen dan membuat '
                    'tubuh lebih rileks.',
              ),

              const SizedBox(height: 17),

              // ===================================================
              // OLAHRAGA 3
              // ===================================================

              _buildSportCard(
                imagePath: 'assets/images/berenang.png',
                title: 'Berenang',
                category: 'Rendah Intensitas',
                description:
                    'Dilakukan dengan tempo ringan dan durasi yang '
                    'secukupnya. Beri jeda setelah makan untuk '
                    'mengurangi risiko refluks asam lambung.',
              ),

              const SizedBox(height: 17),

              // ===================================================
              // OLAHRAGA 4
              // ===================================================

              _buildSportCard(
                imagePath: 'assets/images/peregangan.png',
                title: 'Stretching',
                category: 'Fleksibilitas',
                description:
                    'Membantu melemaskan otot-otot tubuh, '
                    'meningkatkan fleksibilitas, dan membuat '
                    'tubuh lebih rileks.',
              ),

              const SizedBox(height: 34),

              // ===================================================
              // TIPS TAMBAHAN
              // ===================================================

              _buildTipsCard(),

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
          // BACK BUTTON
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

          // TITLE
          Expanded(
            child: Center(
              child: Text(
                'Rekomendasi Olahraga',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // HEADER BALANCER
          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HERO CARD
  // ===============================================================

  Widget _buildHeroCard() {
    return StomachyCard(
      color: const Color(0xFFFFE3D6),
      radius: 14,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      child: SizedBox(
        height: 119,
        child: Row(
          children: [
            // =====================================================
            // GAMBAR
            // =====================================================

            SizedBox(
              width: 125,
              height: 115,
              child: Image.asset(
                'assets/images/maskot_olahraga.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 55,
                      color: Color(0xFFB9543A),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 3),

            // =====================================================
            // TEXT
            // =====================================================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 5,
                  top: 5,
                  bottom: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Olahraga Sehat Untuk',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB9543A),
                      ),
                    ),

                    const Text(
                      'Penderita GERD',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB9543A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Olahraga dengan teknik yang tepat '
                      'membantu mengendalikan gejala GERD.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // SPORT CARD
  // ===============================================================

  Widget _buildSportCard({
    required String imagePath,
    required String title,
    required String category,
    required String description,
  }) {
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 13,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =======================================================
          // SPORT IMAGE
          // =======================================================

          Container(
            width: 82,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE8D8),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_run_rounded,
                    size: 40,
                    color: Color(0xFFB9543A),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 11),

          // =======================================================
          // SPORT INFORMATION
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITLE
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB9543A),
                  ),
                ),

                const SizedBox(height: 3),

                // CATEGORY
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEBD2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                // DESCRIPTION
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
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
  // TIPS CARD
  // ===============================================================

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =====================================================
          // ICON
          // =====================================================

          SizedBox(
            width: 38,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 30,
              color: mainBrown,
            ),
          ),

          const SizedBox(width: 10),

          // =====================================================
          // TEXT
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tips Tambahan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Jangan berolahraga langsung setelah makan '
                  '(tunggu minimal 2 jam), mulai dengan durasi '
                  'ringan, dan hentikan jika gejala GERD muncul.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
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