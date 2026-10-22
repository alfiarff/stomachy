import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_navigation.dart';

import 'admin_home_screen.dart';
import 'admin_article_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_manage_edukasi_screen.dart';
import 'admin_manage_makanan_screen.dart';
import 'admin_manage_olahraga_screen.dart';

// ===============================================================
// KELOLA KONTEN (ADMIN) - HALAMAN MENU
//
// Halaman "Konten" berisi 3 card:
// Edukasi, Rekomendasi Makanan, Rekomendasi Olahraga.
// Setiap card membuka halaman CRUD-nya masing-masing.
// ===============================================================

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  // =============================================================
  // NAVIGATION
  // =============================================================

  void _onNavigationTap(int index) {
    if (index == 2) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminArticleScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
      );
      return;
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('Kelola Konten'),

              const SizedBox(height: 8),

              _buildMenuCard(
                icon: Icons.school_rounded,
                title: 'Edukasi',
                subtitle: 'Materi edukasi kesehatan lambung',
                screen: const AdminManageEdukasiScreen(),
              ),

              const SizedBox(height: 14),

              _buildMenuCard(
                icon: Icons.restaurant_rounded,
                title: 'Rekomendasi Makanan',
                subtitle: 'Saran makanan aman untuk penderita GERD',
                screen: const AdminManageMakananScreen(),
              ),

              const SizedBox(height: 14),

              _buildMenuCard(
                icon: Icons.directions_run_rounded,
                title: 'Rekomendasi Olahraga',
                subtitle: 'Gerakan olahraga yang aman dilakukan',
                screen: const AdminManageOlahragaScreen(),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: 2,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader(String title) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 42,
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
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // =============================================================
  // MENU CARD
  // =============================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7D8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 26,
                color: const Color(0xFFB9543A),
              ),
            ),

            const SizedBox(width: 14),

            // TEKS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: headingDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: bodyText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // CHEVRON
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Color(0xFFB9543A),
            ),
          ],
        ),
      ),
    );
  }
}