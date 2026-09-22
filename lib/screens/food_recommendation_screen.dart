import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class FoodRecommendationScreen extends StatefulWidget {
  const FoodRecommendationScreen({super.key});

  @override
  State<FoodRecommendationScreen> createState() =>
      _FoodRecommendationScreenState();
}

class _FoodRecommendationScreenState
    extends State<FoodRecommendationScreen> {
  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  int _selectedIndex = 4;

  // ===============================================================
  // WARNA
  // ===============================================================

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
              // JUDUL REKOMENDASI
              // ===================================================

              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  'Rekomendasi',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB9543A),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              // ===================================================
              // MAKANAN 1
              // ===================================================

              _buildFoodCard(
                imagePath: 'assets/images/karbohidrat.png',
                title: 'Oatmeal, Ubi jalar, Roti Gandum',
                category: 'Karbohidrat',
                description:
                    'Pilihan sumber karbohidrat kompleks dan serat, '
                    'yang dapat membantu proses pencernaan.',
              ),

              const SizedBox(height: 17),

              // ===================================================
              // MAKANAN 2
              // ===================================================

              _buildFoodCard(
                imagePath: 'assets/images/buah.png',
                title: 'Pisang, Melon, Apel, Pir, Pepaya',
                category: 'Buah-Buahan',
                description:
                    'Buah yang tidak terlalu asam dan kaya air, '
                    'nyaman untuk lambung.',
              ),

              const SizedBox(height: 17),

              // ===================================================
              // MAKANAN 3
              // ===================================================

              _buildFoodCard(
                imagePath: 'assets/images/protein.png',
                title: 'Putih telur, Ayam, Ikan',
                category: 'Protein',
                description:
                    'Sumber protein rendah lemak yang sebaiknya '
                    'dimasak dengan cara direbus atau dikukus.',
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
                'Rekomendasi Makanan',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryBrown,
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
    return Container(
      width: double.infinity,
      height: 135,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3D6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // GAMBAR
          SizedBox(
            width: 125,
            height: 115,
            child: Image.asset(
              'assets/images/gerd_food_banner.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 55,
                    color: Color(0xFFB9543A),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 3),

          // TEXT
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
                    'Makanan Sehat Untuk',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB9543A),
                    ),
                  ),

                  const Text(
                    'Penderita GERD',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB9543A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Pilih makanan yang lembut di '
                    'lambung dan bantu mengurangi '
                    'gejala GERD.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
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
    );
  }

  // ===============================================================
  // FOOD CARD
  // ===============================================================

  Widget _buildFoodCard({
    required String imagePath,
    required String title,
    required String category,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 94,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =======================================================
          // FOOD IMAGE
          // =======================================================

          Container(
            width: 82,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F1E8),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.restaurant_rounded,
                    size: 40,
                    color: Color(0xFFB9543A),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 11),

          // =======================================================
          // FOOD INFORMATION
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB9543A),
                  ),
                ),

                const SizedBox(height: 2),

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

                const SizedBox(height: 2),

                // DESCRIPTION
                Text(
                  description,
                  maxLines: 2,
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
          // ICON
          SizedBox(
            width: 38,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 30,
              color: mainBrown,
            ),
          ),

          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tips Tambahan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Konsumsi makanan dalam porsi kecil, kunyah perlahan, '
                  'hindari makan terlalu malam, dan banyak minum air putih.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
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