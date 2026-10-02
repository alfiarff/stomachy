import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/admin_bottom_navigation.dart';
import '../../services/admin_content_service.dart';

import 'admin_article_screen.dart';
import 'admin_content_screen.dart';
import 'admin_profile_screen.dart';

// ===============================================================
// BERANDA ADMIN
// ===============================================================

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState
    extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB9543A);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  // ===============================================================
  // LOAD NAMA ADMIN
  // ===============================================================

  Future<void> _loadAdminName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      String name = user.displayName ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final firestoreName = data['name'];

          if (firestoreName is String &&
              firestoreName.trim().isNotEmpty) {
            name = firestoreName.trim();
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _adminName = name.isNotEmpty ? name : 'Admin';
      });
    } catch (e) {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        _adminName =
            user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Admin';
      });
    }
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // ARTIKEL
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AdminArticleScreen(),
        ),
      );
      return;
    }

    // KELOLA KONTEN
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AdminContentScreen(),
        ),
      );
      return;
    }

    // PROFIL
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AdminProfileScreen(),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
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
            15,
            10,
            15,
            95,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildGreeting(),

              const SizedBox(height: 26),

              _buildArticleCard(),

              const SizedBox(height: 25),

              const Text(
                'Kelola Konten',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: headingDark,
                ),
              ),

              const SizedBox(height: 12),

              _buildContentManagement(),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNavigation(
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
      height: 75,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,

              child: Image.asset(
                'assets/images/logo_beranda_baru.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // =========================================================
          // PROFILE BUTTON -> PROFIL ADMIN
          // =========================================================

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AdminProfileScreen(),
                ),
              );
            },

            child: Container(
              width: 38,
              height: 38,

              decoration: const BoxDecoration(
                color: Color(0xFFFFF5EF),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.account_circle_rounded,
                size: 37,
                color: Color(0xFFB9543A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // GREETING CARD
  // ===============================================================

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFE6CB),
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Halo,',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.15,
            ),
          ),

          Text(
            '$_adminName! 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _formatTodayDate(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF5A392F),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FORMAT TANGGAL HARI INI
  // ===============================================================

  String _formatTodayDate() {
    final now = DateTime.now();

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final String dayName = days[now.weekday - 1];
    final String monthName = months[now.month];

    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  // ===============================================================
  // ARTIKEL CARD (DATA DARI ADMIN CONTENT SERVICE)
  // ===============================================================

  Widget _buildArticleCard() {
    final article =
        AdminContentService.publishedArticle;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const AdminArticleScreen(),
          ),
        );
      },

      borderRadius: BorderRadius.circular(17),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(12),

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

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =====================================================
            // CHIP STATUS
            // =====================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),

              decoration: BoxDecoration(
                color: article != null
                    ? const Color(0xFFE5F3E8)
                    : const Color(0xFFFFF0D7),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    width: 7,
                    height: 7,

                    decoration: BoxDecoration(
                      color: article != null
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFFEBA21D),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    article != null
                        ? 'Tayang Sekarang'
                        : 'Belum Ada Artikel Tayang',

                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: article != null
                          ? const Color(0xFF2E7D4F)
                          : const Color(0xFF9C6F1A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // =====================================================
            // GAMBAR + TEKS (atau pesan kosong)
            // =====================================================

            if (article != null)
              Row(
                children: [
                  SizedBox(
                    width: 95,
                    height: 95,

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(13),

                      child: Image.asset(
                        article.imageAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: headingDark,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 40,
                    color: Color(0xFFB9543A),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Belum ada artikel yang tayang. '
                      'Tambahkan artikel di menu Artikel.',

                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        height: 1.3,
                        color: bodyText,
                      ),
                    ),
                  ),
                ],
              ),

            // =====================================================
            // STRIP PENGINGAT (HANYA JIKA ADA ARTIKEL)
            // =====================================================

            if (article != null) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9D9),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: Color(0xFFB9543A),
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Berganti otomatis dalam 3 hari - '
                        'siapkan artikel berikutnya!',

                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A392F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // KELOLA KONTEN
  //
  // Dipakai IntrinsicHeight supaya ketiga card TETAP sama
  // tinggi (mengikuti card tertinggi), tanpa perlu
  // CrossAxisAlignment.stretch yang crash di dalam
  // SingleChildScrollView.
  // ===============================================================

  Widget _buildContentManagement() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =========================================================
          // EDUKASI
          // =========================================================

          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.book,
              title: 'Edukasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminContentScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // =========================================================
          // MAKANAN
          // =========================================================

          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.egg_fried,
              title: 'Rekomendasi\nMakanan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminContentScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // =========================================================
          // OLAHRAGA
          // =========================================================

          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.activity,
              title: 'Rekomendasi\nOlahraga',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminContentScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CONTENT CARD
  //
  // Dimensi disamakan dengan QuickActionCard di beranda user:
  // padding vertical 26, lingkaran ikon 54px, ikon 27,
  // font judul 13.
  // ===============================================================

  Widget _buildContentCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 30,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 54,
              height: 54,

              decoration: const BoxDecoration(
                color: Color(0xFFFFE1D2),
                shape: BoxShape.circle,
              ),

              child: Center(
                child: Icon(
                  icon,
                  size: 27,
                  color: accentBrown,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: headingDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}