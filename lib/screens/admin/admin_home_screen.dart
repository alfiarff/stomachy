import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/admin_bottom_navigation.dart';
import '../../services/admin_content_service.dart';

import 'admin_article_screen.dart';
import 'admin_content_screen.dart';
import 'admin_profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB05039);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  String _adminName = 'Admin';
  String? _adminPhotoBase64;
  String? _adminPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String name = user.displayName ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final firestoreName = data['name'];
          final photoBase64 = data['photoBase64'];
          final photoURL = data['photoURL'];
          if (photoBase64 is String && photoBase64.isNotEmpty) {
            _adminPhotoBase64 = photoBase64;
          }
          if (photoURL is String && photoURL.isNotEmpty) {
            _adminPhotoUrl = photoURL;
          }
          if (firestoreName is String && firestoreName.trim().isNotEmpty) {
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
        _adminName = user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : 'Admin';
      });
    }
  }

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        // Beranda
        return;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminArticleScreen()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminContentScreen()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
        );
        break;
    }
  }

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
              _buildHeader(),
              const SizedBox(height: 14),
              _buildGreeting(),
              const SizedBox(height: 16),
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
              _buildAccountManagementCard(),
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
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB05039).withOpacity(0.25),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildAdminAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAvatar() {
    if (_adminPhotoBase64 != null && _adminPhotoBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_adminPhotoBase64!),
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAdminAvatar(),
        );
      } catch (_) {
        return _defaultAdminAvatar();
      }
    }

    if (_adminPhotoUrl != null && _adminPhotoUrl!.isNotEmpty) {
      return Image.network(
        _adminPhotoUrl!,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAdminAvatar(),
      );
    }

    return _defaultAdminAvatar();
  }

  Widget _defaultAdminAvatar() {
    return const Icon(
      Icons.account_circle_rounded,
      size: 37,
      color: Color(0xFFB05039),
    );
  }

  // ===============================================================
  // GREETING CARD
  // ===============================================================

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          Text(
            '$_adminName! 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _formatTodayDate(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
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
  // ARTIKEL CARD (BACA SEKALI PAKAI get())
  // ===============================================================

  Widget _buildArticleCard() {
    return FutureBuilder<AdminArticle?>(
      future: _getPublishedArticle(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildHomeArticleLoading();
        }

        if (snapshot.hasError) {
          return _buildHomeArticleError();
        }

        final article = snapshot.data;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminArticleScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
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
                const SizedBox(height: 9),
                if (article != null)
                  Row(
                    children: [
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            article.imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: headingDark,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              article.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
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
                        color: Color(0xFFB05039),
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
                if (article != null) ...[
                  const SizedBox(height: 9),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Color(0xFFB05039),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Berganti otomatis dalam 3 hari - '
                            'siapkan artikel berikutnya!',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9,
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
      },
    );
  }

  // ===============================================================
  // AMBIL 1 ARTIKEL TAYANG (PAKE get, BUKAN STREAM)
  // ===============================================================

  Future<AdminArticle?> _getPublishedArticle() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('articles')
          .where('isPublished', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return AdminArticle.fromFirestore(snapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================================================
  // LOADING STATE
  // ===============================================================

  Widget _buildHomeArticleLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFFA9583C)),
        ),
      ),
    );
  }

  // ===============================================================
  // ERROR STATE
  // ===============================================================

  Widget _buildHomeArticleError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 30),
          SizedBox(height: 8),
          Text(
            'Gagal memuat artikel',
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

  // ===============================================================
  // KELOLA KONTEN
  // ===============================================================

  Widget _buildContentManagement() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.book,
              title: 'Edukasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminContentScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.egg_fried,
              title: 'Rekomendasi\nMakanan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminContentScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContentCard(
              icon: BootstrapIcons.activity,
              title: 'Rekomendasi\nOlahraga',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminContentScreen(),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 26),
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
                color: Color(0xFFFFE1C8),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 27, color: accentBrown)),
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

  // ===============================================================
  // ACCOUNT MANAGEMENT CARD
  // ===============================================================

  Widget _buildAccountManagementCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminProfileScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE1C8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_accounts_rounded,
                size: 34,
                color: Color(0xFFB05039),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Manajemen Akun',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF251814),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola data admin, profil,\ndan pengaturan akun',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF6B5147),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFE99560),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
