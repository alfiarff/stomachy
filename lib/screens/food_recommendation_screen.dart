import 'package:flutter/material.dart';

import '../services/admin_content_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/stomachy_card.dart';
import '../widgets/stomachy_cover_image.dart';

import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'screening_screen.dart';
import 'user_content_detail_screen.dart';

// ===============================================================
// REKOMENDASI MAKANAN (USER) — DINAMIS DARI FIRESTORE
//
// - List konten type 'makanan' yang ditambahkan lewat admin
// - Ketuk card -> UserContentDetailScreen (mekanisme sama edukasi)
// - Hero card & tips tambahan tetap statis
// ===============================================================

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
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    // SKRINING
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreeningScreen()),
      );
      return;
    }

    // DOKTER
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorScreen()),
      );
      return;
    }

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EdukasiScreen()),
      );
      return;
    }

    // PROFIL
    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 105),
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
              // DAFTAR MAKANAN (DARI FIRESTORE)
              // ===================================================
              _buildFoodList(),

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
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // HEADER BALANCER
          const SizedBox(width: 45),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                'assets/images/maskot_makan.png',
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

            // =====================================================
            // TEXT
            // =====================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Makanan Sehat Untuk',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB9543A),
                      ),
                    ),

                    const Text(
                      'Penderita GERD',
                      style: TextStyle(
                        fontFamily: 'Nunito',
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
  // DAFTAR MAKANAN (STREAM FIRESTORE)
  // ===============================================================

  Widget _buildFoodList() {
    return StreamBuilder<List<AdminContentItem>>(
      stream: AdminContentService.getContentsStream('makanan'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyCard();
        }

        return Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _buildFoodCard(items[i]),
              if (i != items.length - 1) const SizedBox(height: 17),
            ],
          ],
        );
      },
    );
  }

  // ===============================================================
  // FOOD CARD (DINAMIS)
  // ===============================================================

  Widget _buildFoodCard(AdminContentItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserContentDetailScreen(item: item),
          ),
        );
      },
      child: StomachyCard(
        color: const Color(0xFFFFFCF9),
        radius: 13,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                child: StomachyCoverImage(
                  imageSrc: item.imageAsset,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant_rounded,
                  fallbackIconSize: 40,
                  fallbackColor: const Color(0xFFB9543A),
                  fallbackBackgroundColor: const Color(0xFFF1F1E8),
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
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB9543A),
                    ),
                  ),

                  // CATEGORY
                  if (item.category.isNotEmpty) ...[
                    const SizedBox(height: 3),
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
                        item.category,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 3),

                  // DESCRIPTION
                  Text(
                    _getDescription(item),
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
      ),
    );
  }

  // ===============================================================
  // DESKRIPSI CARD (SUMMARY DULU, FALLBACK CONTENT)
  // ===============================================================

  String _getDescription(AdminContentItem item) {
    final summary = item.summary.trim();
    if (summary.isNotEmpty) {
      return summary;
    }
    return item.content.trim().replaceAll('\n', ' ');
  }

  // ===============================================================
  // STATE LOADING / ERROR / KOSONG
  // ===============================================================

  Widget _buildLoadingCard() {
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 13,
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFFA9583C)),
          SizedBox(height: 12),
          Text(
            'Memuat rekomendasi...',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Color(0xFF493C37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 13,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat rekomendasi',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF493C37),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF776C67),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 13,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: const Column(
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 45,
            color: Color(0xFFB9543A),
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada rekomendasi makanan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF493C37),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Konten akan segera ditambahkan, cek lagi nanti ya!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF776C67),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  'Konsumsi makanan dalam porsi kecil, kunyah perlahan, '
                  'hindari makan terlalu malam, dan banyak minum air putih.',
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