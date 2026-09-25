import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screening_screen.dart';
import 'doctor_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'artikel_tidur_screen.dart';

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

      // Ambil nama dari Firebase Authentication terlebih dahulu
      String name = user.displayName ?? '';

      // Ambil nama dari Firestore jika tersedia
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
    // Skrining
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // Dokter
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // Edukasi
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // Profil
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
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 18),

              // =====================================================
              // GREETING
              // =====================================================

              _buildGreeting(),

              const SizedBox(height: 18),

              // =====================================================
              // SCREENING HERO
              // =====================================================

              _buildScreeningCard(),

              const SizedBox(height: 27),

              // =====================================================
              // QUICK ACTION TITLE
              // =====================================================

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

              // =====================================================
              // QUICK ACTION
              // =====================================================

              _buildQuickActions(),

              const SizedBox(height: 30),

              // =====================================================
              // ARTIKEL
              // =====================================================

              _buildArticleSection(),

              const SizedBox(height: 15),
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
          // =========================================================
          // TEXT
          // =========================================================

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

                // ===================================================
                // BUTTON
                // ===================================================

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

          // =========================================================
          // SCREENING ILLUSTRATION
          // =========================================================

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
        // ===========================================================
        // SKRINING
        // ===========================================================

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

        // ===========================================================
        // KONSULTASI
        // ===========================================================

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

        // ===========================================================
        // EDUKASI
        // ===========================================================

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

  // ===============================================================
  // SINGLE QUICK ACTION
  // ===============================================================

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
        // ===========================================================
        // TITLE
        // ===========================================================

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

        // ===========================================================
        // ARTICLE CARD
        // ===========================================================

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
                // ===================================================
                // ARTICLE IMAGE
                // ===================================================

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

                // ===================================================
                // ARTICLE TEXT
                // ===================================================

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

                      // =================================================
                      // BACA SELENGKAPNYA
                      // =================================================

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