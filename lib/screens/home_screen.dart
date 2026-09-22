import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screening_screen.dart';
import 'doctor_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'artikel_tidur_screen.dart';
import 'grafik_screen.dart';
import 'screening_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color purple = const Color(0xFFB5A4E8);

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ===================================================================
  // LOAD NAMA PENGGUNA
  // ===================================================================

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            90,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================================================
              // LOGO STOMACHY
              // =========================================================

              Center(
                child: Image.asset(
                  'assets/images/logo_beranda_stomachy.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),

              // =========================================================
              // GREETING
              // =========================================================

              _buildGreetingCard(),

              const SizedBox(height: 20),

              // =========================================================
              // SCREENING
              // =========================================================

              _buildScreeningCard(),

              const SizedBox(height: 20),

              // =========================================================
              // RISIKO GERD
              // =========================================================

              _buildRiskCard(),

              const SizedBox(height: 20),

              // =========================================================
              // GRAFIK
              // =========================================================

              _buildFeatureCard(
                image: 'assets/images/grafik.png',
                title: 'Grafik Riwayat Skrining',
                description:
                    'Lihat grafik hasil skrining untuk mengetahui perkembangan kondisi GERD.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrafikScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =========================================================
              // EDUKASI
              // =========================================================

              _buildFeatureCard(
                image: 'assets/images/edukasi.png',
                title: 'Edukasi Singkat',
                description:
                    'Pelajari informasi mengenai GERD dan cara menjaga kesehatan lambung.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EdukasiScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =========================================================
              // ARTIKEL
              // =========================================================

              _buildArticleCard(),

              const SizedBox(height: 14),
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

  // ===================================================================
  // GREETING CARD
  // ===================================================================

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      height: 135,
      decoration: BoxDecoration(
        color: const Color(0xFFFBE4D7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              18,
              135,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_userName! 👋',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4D3028),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Bagaimana Kondisi \nLambungmu\nHari Ini?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4D3028),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: -8,
            bottom: -5,
            child: Image.asset(
              'assets/images/mascot_happy.png',
              width: 155,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // SCREENING CARD
  // ===================================================================

  Widget _buildScreeningCard() {
    return Container(
      width: double.infinity,
      height: 164,
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              19,
              15,
              125,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skrining Risiko\nGERD',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Cek gejala dan kebiasaanmu\ndalam beberapa menit dengan AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreeningScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8068D3),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: const Size(165, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai Cek Sekarang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 7),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 2,
            top: 7,
            child: Image.asset(
              'assets/images/screening.png',
              width: 130,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // RISIKO GERD TERAKHIR
  // ===================================================================

  Widget _buildRiskCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScreeningHistoryScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 145,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Risiko GERD Terakhir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4D3129),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Berisiko GERD',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    color: Color(0xFFE93636),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Keluhan: Panas di dada, asam naik,\nperut terasa penuh.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Color(0xFF392B27),
                  ),
                ),

                const Spacer(),

                Row(
                  children: const [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF9A88E6),
                      size: 17,
                    ),

                    SizedBox(width: 5),

                    Text(
                      '12 Agustus 2026 - 10:24',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              right: -4,
              top: 5,
              child: Image.asset(
                'assets/images/stomachy_worried.png',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
              ),
            ),

            const Positioned(
              right: 0,
              top: -2,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // FEATURE CARD
  // ===================================================================

  Widget _buildFeatureCard({
    required String image,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 96,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Image.asset(
                  image,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF493028),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC7B5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8C3827),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // ARTIKEL MINGGU INI
  // ===================================================================

  Widget _buildArticleCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArtikelTidurScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ==========================================================
            // HEADER ARTIKEL
            // ==========================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ICON
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: Color(0xFFB65A43),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                // JUDUL + DESKRIPSI
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Artikel Minggu Ini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF493028),
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Baca artikel terbaru seputar GERD dan pola hidup sehat.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.15,
                          color: Color(0xFF5D4B45),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // ISI ARTIKEL
            // ==========================================================

            Container(
              width: double.infinity,
              height: 130,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ====================================================
                  // GAMBAR
                  // ====================================================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 105,
                      color: Colors.white,
                      child: Image.asset(
                        'assets/images/artikel_tidur.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ====================================================
                  // TEKS + BUTTON
                  // ====================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // JUDUL ARTIKEL
                        const Text(
                          'Tips Tidur Nyenyak untuk Penderita GERD',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF493028),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // DESKRIPSI
                        const Expanded(
                          child: Text(
                            'Simak tips berikut agar tidurmu lebih berkualitas!',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: Color(0xFF675B57),
                            ),
                          ),
                        ),

                        // =================================================
                        // BUTTON
                        // =================================================

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB65A43),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Artikel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),

                                SizedBox(width: 5),

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}