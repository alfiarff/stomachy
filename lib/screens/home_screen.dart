import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screening_screen.dart';
import 'doctor_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'artikel_tidur_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ===============================================================
  // WARNA STOMACHY
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color accentBrown = const Color(0xFFB9543A);
  final Color purple = const Color(0xFFB5A4E8);

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ===============================================================
  // LOAD NAMA PENGGUNA
  // ===============================================================

  Future<void> _loadUserName() async {
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
        _userName = name.isNotEmpty ? name : 'Pengguna';
      });
    } catch (e) {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        _userName = user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : 'Pengguna';
      });
    }
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
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

              const SizedBox(height: 18),

              _buildScreeningCard(),

              const SizedBox(height: 27),

              const Text(
                'Apa yang ingin kamu lakukan saat ini?',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF493028),
                ),
              ),

              const SizedBox(height: 17),

              _buildQuickActions(),

              const SizedBox(height: 30),

              _buildArticleSection(),

              const SizedBox(height: 15),
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
  // HEADER (LOGO + LONCENG + PROFIL)
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 75,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =========================================================
          // LOGO
          // =========================================================

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
          // TOMBOL LONCENG NOTIFIKASI
          // =========================================================

          const _NotificationBell(),

          const SizedBox(width: 10),

          // =========================================================
          // PROFILE BUTTON
          // =========================================================

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
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
  // GREETING
  // ===============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $_userName! 👋',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF493028),
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Jaga kesehatan lambungmu dengan langkah kecil setiap hari.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            height: 1.3,
            color: Color(0xFF675B57),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SCREENING CARD
  // ===============================================================

  Widget _buildScreeningCard() {
    return Container(
      width: double.infinity,
      height: 163,
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              130,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skrining Risiko\nGERD',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Cek gejala dan kebiasaanmu\ndalam beberapa menit dengan AI',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ScreeningScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8068D3),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai Cek Sekarang',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(width: 6),

                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 2,
            top: 8,
            child: Image.asset(
              'assets/images/screening.png',
              width: 125,
              height: 145,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // QUICK ACTIONS
  // ===============================================================

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAction(
          icon: Icons.search_rounded,
          title: 'Skrining',
          color: const Color(0xFFB5A4E8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScreeningScreen(),
              ),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.medical_services_outlined,
          title: 'Konsultasi',
          color: const Color(0xFFFFC8B7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorScreen(),
              ),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.menu_book_rounded,
          title: 'Edukasi',
          color: const Color(0xFFBFE7D8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EdukasiScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 27,
                color: const Color(0xFF5A392F),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF493028),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ARTICLE SECTION
  // ===============================================================

  Widget _buildArticleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Artikel Minggu Ini',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF493028),
          ),
        ),

        const SizedBox(height: 12),

        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArtikelTidurScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: double.infinity,
            height: 126,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 105,
                  height: 105,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/artikel_tidur.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips Tidur Nyenyak untuk Penderita GERD',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF493028),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Tidur cukup bantu lambung menjadi lebih sehat.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          height: 1.25,
                          color: Color(0xFF675B57),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Baca Selengkapnya',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8068D3),
                            ),
                          ),

                          SizedBox(width: 4),

                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF8068D3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// TOMBOL LONCENG NOTIFIKASI
//
// Class ini berada DI LUAR class _HomeScreenState (top-level).
// - Tidak ada yang belum dibaca -> lonceng outline biasa
// - Ada yang belum dibaca -> lonceng fill + badge merah angka
// - Data dari penyimpanan lokal, di-refresh otomatis
//   setiap kali kembali dari halaman notifikasi
// ===============================================================

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() =>
      _NotificationBellState();
}

class _NotificationBellState
    extends State<_NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
      return;
    }

    final int count =
        await AppNotification.getRecentUnreadCount(
      user.uid,
    );

    if (!mounted) return;

    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = _unreadCount > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const NotificationScreen(),
          ),
        );

        // Kembali dari halaman notifikasi ->
        // hitung ulang badge
        _refreshCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5EF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                hasUnread
                    ? BootstrapIcons.bell_fill
                    : BootstrapIcons.bell,
                size: 24,
                color: const Color(0xFFB9543A),
              ),
            ),
          ),

          if (hasUnread)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                constraints: const BoxConstraints(
                  minWidth: 17,
                  minHeight: 17,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE93636),
                  shape: _unreadCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: _unreadCount > 9
                      ? BorderRadius.circular(9)
                      : null,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 9
                        ? '9+'
                        : '$_unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}