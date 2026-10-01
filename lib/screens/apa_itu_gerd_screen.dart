import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ApaItuGerdScreen extends StatefulWidget {
  const ApaItuGerdScreen({super.key});

  @override
  State<ApaItuGerdScreen> createState() => _ApaItuGerdScreenState();
}

// =====================================================================
// MODEL SEKSI INFORMASI
// =====================================================================

class _InfoSection {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final List<String> points;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.points,
  });
}

class _ApaItuGerdScreenState
    extends State<ApaItuGerdScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);

  // ===============================================================
  // STATUS CARD MANA YANG SEDANG DIBUKA
  //
  // "Penyebab GERD" dibuka secara default (sesuai desain).
  // Setiap kali card dipencet, kontennya muncul/hilang
  // dengan animasi.
  // ===============================================================

  final Set<String> _expandedSections = {
    'Penyebab GERD',
  };

  // ===============================================================
  // DATA SEMUA SEKSI
  // ===============================================================

  static const List<_InfoSection> _sections = [
    _InfoSection(
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFE8804C),
      iconBackground: Color(0xFFFFE9DC),
      title: 'Penyebab GERD',
      points: [
        'Otot cincin di ujung bawah kerongkongan (sfingter '
            'esofagus bagian bawah) melemah atau relaksasi tidak '
            'tepat, sehingga asam lambung mudah naik kembali.',
        'Makanan pemicu: makanan asam, pedas, dan berkafein.',
        'Kebiasaan buruk seperti langsung tidur setelah makan.',
      ],
    ),

    _InfoSection(
      icon: Icons.health_and_safety_outlined,
      iconColor: Color(0xFF7B6BD0),
      iconBackground: Color(0xFFEDE9FB),
      title: 'Gejala Umum',
      points: [
        'Rasa terbakar di dada (heartburn)',
        'Rasa asam di mulut',
        'Mual atau begah',
        'Batuk kronis atau suara serak',
        'Nyeri saat menelan',
      ],
    ),

    _InfoSection(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF5A9FE0),
      iconBackground: Color(0xFFE3EEFC),
      title: 'Dampak Jika Tidak Ditangani',
      points: [
        'Munculnya gejala lanjutan terkait komplikasi GERD.',
        'Berisiko mengalami masalah kesehatan serius lainnya.',
      ],
    ),

    _InfoSection(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFF4AA978),
      iconBackground: Color(0xFFDFF2E7),
      title: 'Kapan Harus ke Dokter?',
      points: [
        'Gejala GERD terjadi lebih dari 2 kali seminggu.',
        'Gejala semakin parah dan mengganggu aktivitas '
            'sehari-hari.',
      ],
    ),
  ];

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
            27,
            5,
            27,
            18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 8),

              // =====================================================
              // HERO IMAGE
              // =====================================================

              _buildHeroImage(),

              const SizedBox(height: 14),

              // =====================================================
              // JUDUL
              // =====================================================

              const Text(
                'Apa Itu GERD?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 6),

              // =====================================================
              // DESKRIPSI
              // =====================================================

              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF30221E),
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'GERD adalah kondisi ketika ',
                    ),
                    TextSpan(
                      text: 'asam lambung naik ke '
                          'kerongkongan',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' secara berulang, '
                          'menyebabkan iritasi dan rasa '
                          'tidak nyaman.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =====================================================
              // DAFTAR CARD INFORMASI (EXPANDABLE)
              // =====================================================

              for (int i = 0;
                  i < _sections.length;
                  i++) ...[
                _buildInfoCard(_sections[i]),

                if (i != _sections.length - 1)
                  const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),

              // =====================================================
              // INGAT
              // =====================================================

              _buildRememberBox(),

              const SizedBox(height: 4),
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
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Edukasi',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
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

  // ===============================================================
  // HERO IMAGE
  // ===============================================================

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/apa_itu_gerd.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                '🤔',
                style: TextStyle(
                  fontSize: 60,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // CARD INFORMASI (EXPANDABLE)
  //
  // - Dalam keadaan tertutup: ikon + judul + "N poin" + chevron
  // - Dipencet: konten bullet muncul dengan animasi
  // ===============================================================

  Widget _buildInfoCard(_InfoSection section) {
    final bool isExpanded =
        _expandedSections.contains(section.title);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // BARIS JUDUL (SELALU TERLIHAT, BISA DIPENCET)
          // ======================================================

          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections
                      .remove(section.title);
                } else {
                  _expandedSections
                      .add(section.title);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                13,
                12,
                13,
              ),
              child: Row(
                children: [
                  // ICON
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: section.iconBackground,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Icon(
                      section.icon,
                      size: 19,
                      color: section.iconColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // JUDUL
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171310),
                      ),
                    ),
                  ),

                  // JUMLAH POIN
                  Text(
                    '${section.points.length} poin',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A8F89),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // CHEVRON (BERPUTAR SAAT DIBUKA)
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    child: const Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 22,
                      color: Color(0xFF9A8F89),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // KONTEN (MUNCUL/HILANG DENGAN ANIMASI)
          // ======================================================

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(
              width: double.infinity,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                16,
                14,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  for (final point in section.points)
                    _buildBulletItem(point),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BULLET ITEM
  // ===============================================================

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 44,
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF30221E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // REMEMBER BOX
  // ===============================================================

  Widget _buildRememberBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D2),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingat!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171310),
            ),
          ),

          SizedBox(height: 3),

          Text(
            'GERD dapat dikendalikan dengan perubahan gaya hidup sehat '
            'dan pengobatan yang tepat.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              height: 1.4,
              color: Color(0xFF30221E),
            ),
          ),
        ],
      ),
    );
  }
}