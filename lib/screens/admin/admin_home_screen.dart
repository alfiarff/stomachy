import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/admin_bottom_navigation.dart';

// ===============================================================
// BERANDA ADMIN
//
// Struktur folder admin:
// lib/screens/admin/  -> semua halaman untuk role admin
//
// Beranda admin berisi:
// 1. Greeting + tanggal hari ini
// 2. Artikel minggu ini (yang sedang tayang) + status
// 3. Kelola konten (Edukasi, Makanan, Olahraga)
// 4. Statistik minggu ini
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

  // ===============================================================
  // WARNA STOMACHY
  // ===============================================================

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
  // PLACEHOLDER (HALAMAN ADMIN BELUM DIBUAT)
  //
  // TODO: ganti pemanggilan snackbar ini dengan
  // Navigator.push ke halaman admin asli saat sudah dibuat:
  // - AdminArticleScreen
  // - AdminContentScreen
  // - AdminProfileScreen
  // ===============================================================

  void _showComingSoon(String pageName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Halaman $pageName sedang dalam pengembangan.',
          ),
        ),
      );
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
      _showComingSoon('Artikel Admin');
      return;
    }

    // KONTEN
    if (index == 2) {
      _showComingSoon('Kelola Konten');
      return;
    }

    // PROFIL
    if (index == 3) {
      _showComingSoon('Profil Admin');
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

              const SizedBox(height: 22),

              // ================================================
              // ARTIKEL MINGGU INI
              // ================================================

              _buildSectionHeader(
                title: 'Artikel Minggu Ini',
                actionLabel: 'Kelola',
                onAction: () {
                  _showComingSoon('Kelola Artikel');
                },
              ),

              const SizedBox(height: 12),

              _buildArticleCard(),

              const SizedBox(height: 24),

              // ================================================
              // KELOLA KONTEN
              // ================================================

              _buildSectionHeader(
                title: 'Kelola Konten',
                actionLabel: 'Kelola Semua',
                onAction: () {
                  _showComingSoon('Kelola Konten');
                },
              ),

              const SizedBox(height: 12),

              _buildContentManagement(),

              const SizedBox(height: 24),

              // ================================================
              // STATISTIK MINGGU INI
              // ================================================

              const Text(
                'Statistik Minggu Ini',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: headingDark,
                ),
              ),

              const SizedBox(height: 12),

              _buildStatistics(),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      // ===========================================================
      // BOTTOM NAVIGATION ADMIN
      // ===========================================================

      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER (LOGO + PROFIL — tanpa lonceng sesuai desain)
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
          // PROFILE BUTTON
          // =========================================================

          GestureDetector(
            onTap: () {
              _showComingSoon('Profil Admin');
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
  // GREETING (TANPA CARD — LANGSUNG TEKS SESUAI DESAIN)
  // ===============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $_adminName! 👋',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _formatTodayDate(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: bodyText,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // FORMAT TANGGAL HARI INI -> "Senin, 12 Agustus 2026"
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
  // HEADER SECTION (JUDUL KIRI + AKSI KANAN)
  // ===============================================================

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: headingDark,
            ),
          ),
        ),

        // =======================================================
        // AKSI (KELOLA / KELOLA SEMUA)
        // =======================================================

        GestureDetector(
          onTap: onAction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB9543A),
                ),
              ),

              const SizedBox(width: 3),

              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Color(0xFFB9543A),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // ARTIKEL CARD (ARTIKEL YANG SEDANG TAYANG)
  //
  // - Chip status "Tayang Sekarang"
  // - Gambar + judul + deskripsi
  // - Strip pengingat pergantian artikel
  // ===============================================================

  Widget _buildArticleCard() {
    return InkWell(
      onTap: () {
        _showComingSoon('Detail Artikel');
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
            // ================================================
            // CHIP STATUS TAYANG
            // ================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F3E8),
                borderRadius: BorderRadius.circular(20),
              ),
                child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    // TITIK HIJAU
                    Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Color(0xFF2E9E5B),
                        shape: BoxShape.circle,
                    ),
                    ),

                    const SizedBox(width: 6),

                    const Text(
                    'Tayang Sekarang',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D4F),
                    ),
                    ),
                ],
                ),
            ),

            const SizedBox(height: 12),

            // ================================================
            // GAMBAR + TEKS ARTIKEL
            // ================================================

            Row(
              children: [
                SizedBox(
                  width: 95,
                  height: 95,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/artikel_tidur.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tips Tidur Nyenyak untuk Penderita GERD',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: headingDark,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Tidur cukup bantu lambung menjadi lebih sehat.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
            ),

            const SizedBox(height: 12),

            // ================================================
            // STRIP PENGINGAT PERGANTIAN ARTIKEL
            // ================================================

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
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: Color(0xFFB9543A),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Berganti otomatis dalam 3 hari - siapkan artikel berikutnya!',
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
        ),
      ),
    );
  }

  // ===============================================================
  // KELOLA KONTEN (3 CARD: EDUKASI, MAKANAN, OLAHRAGA)
  // ===============================================================

  Widget _buildContentManagement() {
    return Row(
      children: [
        Expanded(
          child: _buildContentCard(
            imagePath: 'assets/images/edukasi.png',
            title: 'Edukasi\nGERD',
            count: '5 Materi',
            onTap: () {
              _showComingSoon('Kelola Edukasi');
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildContentCard(
            imagePath: 'assets/images/buah.png',
            title: 'Rekom.\nMakanan',
            count: '3 item',
            onTap: () {
              _showComingSoon('Kelola Makanan');
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildContentCard(
            imagePath: 'assets/images/yoga.png',
            title: 'Rekom.\nOlahraga',
            count: '4 item',
            onTap: () {
              _showComingSoon('Kelola Olahraga');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard({
    required String imagePath,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 22,
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
          children: [
            // ================================================
            // GAMBAR (MASKOT KONTEN)
            // ================================================

            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1C8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.grid_view_rounded,
                    size: 26,
                    color: Color(0xFFB9543A),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ================================================
            // JUDUL
            // ================================================

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: headingDark,
              ),
            ),

            const SizedBox(height: 4),

            // ================================================
            // JUMLAH ITEM
            // ================================================

            Text(
              count,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // STATISTIK MINGGU INI
  //
  // TODO: nilai saat ini masih statis. Nanti bisa dihubungkan
  // ke Firestore (jumlah users, jumlah screening_history,
  // jumlah konsultasi) memakai StreamBuilder seperti pola
  // kartu skrining di beranda user.
  // ===============================================================

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            value: '1,2 rb',
            label: 'Pengguna',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatisticCard(
            value: '86',
            label: 'Skrining',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatisticCard(
            value: '52',
            label: 'Konsultasi',
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String value,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 22,
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
        children: [
          // ================================================
          // ANGKA
          // ================================================

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: headingDark,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ================================================
          // LABEL
          // ================================================

          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: bodyText,
            ),
          ),
        ],
      ),
    );
  }
}