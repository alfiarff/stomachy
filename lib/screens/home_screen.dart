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
                  height: 95,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              // =========================================================
              // GREETING
              // =========================================================

              _buildGreetingCard(),

              const SizedBox(height: 18),

              // =========================================================
              // SCREENING
              // =========================================================

              _buildScreeningCard(),

              const SizedBox(height: 18),

              // =========================================================
              // RISIKO GERD
              // =========================================================

              _buildRiskCard(),

              const SizedBox(height: 18),

              // =========================================================
              // GRAFIK
              // =========================================================

              _buildFeatureCard(
                image: 'assets/images/grafik.png',
                title: 'Grafik Riwayat Skrining',
                description:
                    'Lihat grafik hasil skrining berkala untuk ketahui tingkat keparahan gejala.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrafikScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // =========================================================
              // EDUKASI
              // =========================================================

              _buildFeatureCard(
                image: 'assets/images/edukasi.png',
                title: 'Edukasi Singkat',
                description:
                    'Belajar lebih banyak tentang GERD dan cara mengelolanya.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EdukasiScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

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
      height: 150,
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
              16,
              18,
              130,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_userName! 👋',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4D3028),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Bagaimana Kondisi \nLambungmu\nHari Ini?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4D3028),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: -2,
            bottom: -2,
            child: Image.asset(
              'assets/images/mascot_happy.png',
              width: 150,
              height: 142,
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
  // RISIKO GERD TERAKHIR (DATA REAL DARI FIRESTORE)
  //
  // Mengambil 1 dokumen terbaru dari koleksi screening_history
  // berdasarkan createdAt (terbaru dulu).
  // Tampilan sesuai desain Figma:
  // [Risiko GERD Terakhir]  -> label kecil
  // [Berisiko GERD]         -> status besar (merah/hijau)
  // [kalender 12 Agustus..] -> tanggal
  // ===================================================================

  // ===================================================================
  // RISIKO GERD TERAKHIR
  // ===================================================================

  Widget _buildRiskCard() {
    final user = FirebaseAuth.instance.currentUser;

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
        height: 118,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: user == null
            ? _buildRiskEmptyContent()
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('screening_history')
                    .orderBy(
                      'createdAt',
                      descending: true,
                    )
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFB9543A),
                        ),
                      ),
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  if (documents.isEmpty) {
                    return _buildRiskEmptyContent();
                  }

                  return _buildRiskDataContent(
                    documents.first.data(),
                  );
                },
              ),
      ),
    );
  }

  // ===================================================================
  // KONTEN RISIKO GERD TERBARU
  // ===================================================================

  Widget _buildRiskDataContent(
    Map<String, dynamic> data,
  ) {
    final bool isRisk = data['isRisk'] == true;

    final String status = isRisk
        ? 'Berisiko GERD'
        : 'Tidak Berisiko GERD';

    final Color statusColor = isRisk
        ? const Color(0xFFE93636)
        : const Color(0xFF18865A);

    final String date = _formatHistoryDate(
      data['createdAt'],
    );

    final String mascot = isRisk
        ? 'assets/images/stomachy_worried.png'
        : 'assets/images/mascot_happy.png';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ============================================================
        // TEKS
        // ============================================================

        Positioned(
          left: 10,
          top: 8,
          bottom: 5,
          right: 135,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Risiko GERD Terakhir',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF493028),
                ),
              ),

              const SizedBox(height: 5),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  status,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: statusColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 19,
                    color: Color(0xFF9A88E6),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ============================================================
        // MASCOT
        // ============================================================

        Positioned(
          right: 38,
          top: -2,
          bottom: -2,
          child: SizedBox(
            width: 105,
            height: 105,
            child: Image.asset(
              mascot,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.personal_injury_rounded,
                  size: 55,
                  color: Color(0xFFB9543A),
                );
              },
            ),
          ),
        ),

        // ============================================================
        // CHEVRON
        // ============================================================

        const Positioned(
          right: 1,
          top: 0,
          bottom: 0,
          child: Center(
            child: Icon(
              Icons.chevron_right_rounded,
              size: 31,
              color: Color(0xFF222222),
            ),
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // KONTEN KARTU : BELUM ADA RIWAYAT
  // ===================================================================

  Widget _buildRiskEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum ada riwayat skrining',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4D3028),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Lakukan skrining untuk melihat hasilnya di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // FORMAT TANGGAL RIWAYAT -> "12 Agustus 2026 - 10:24"
  // ===================================================================

  String _formatHistoryDate(dynamic createdAt) {
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      final day = date.day.toString();
      final month = _monthName(date.month);
      final year = date.year.toString();

      final hour =
          date.hour.toString().padLeft(2, '0');
      final minute =
          date.minute.toString().padLeft(2, '0');

      return '$day $month $year - $hour:$minute';
    }

    return '-';
  }

  String _monthName(int month) {
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

    return months[month];
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
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
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
                      height: 1.3,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 34,
              height: 34,
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
        padding: const EdgeInsets.all(14),
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F4),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: Color(0xFFB65A43),
                    size: 24,
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
                          fontFamily: 'Nunito',
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
                          height: 1.2,
                          color: Color(0xFF5D4B45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // ISI ARTIKEL
            // ==========================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF3E5DA),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ====================================================
                  // GAMBAR
                  // ====================================================

                  SizedBox(
                    width: 105,
                    height: 105,
                    child: Image.asset(
                      'assets/images/artikel_tidur.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ====================================================
                  // TEKS + BUTTON
                  // ====================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // JUDUL ARTIKEL
                        const Text(
                          'Tips Tidur Nyenyak untuk Penderita GERD',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF493028),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // DESKRIPSI
                        const Text(
                          'Simak tips berikut agar tidurmu lebih berkualitas!',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            color: Color(0xFF675B57),
                          ),
                        ),

                        const SizedBox(height: 10),

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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Artikel',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),

                                SizedBox(width: 4),

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
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