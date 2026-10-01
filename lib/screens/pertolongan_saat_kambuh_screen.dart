import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class PertolonganSaatKambuhScreen extends StatefulWidget {
  const PertolonganSaatKambuhScreen({super.key});

  @override
  State<PertolonganSaatKambuhScreen> createState() =>
      _PertolonganSaatKambuhScreenState();
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

class _PertolonganSaatKambuhScreenState
    extends State<PertolonganSaatKambuhScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);

  final Set<String> _expandedSections = {
    'Ubah Posisi Tubuh',
  };

  // ===============================================================
  // DATA SEMUA SEKSI
  // ===============================================================

  static const List<_InfoSection> _sections = [
    _InfoSection(
      icon: Icons.info_outline_rounded,
      iconColor: Color(0xFFE8804C),
      iconBackground: Color(0xFFFFE9DC),
      title: 'Ubah Posisi Tubuh',
      points: [
        'Duduk tegak atau bersandar dengan posisi setengah duduk. '
            'Hindari berbaring langsung, karena bisa memperparah '
            'naiknya asam lambung.',
      ],
    ),

    _InfoSection(
      icon: Icons.water_drop_outlined,
      iconColor: Color(0xFF7B6BD0),
      iconBackground: Color(0xFFEDE9FB),
      title: 'Minum Air Putih Hangat',
      points: [
        'Air hangat dapat membantu menenangkan lambung dan '
            'mengurangi rasa terbakar di dada. Minumlah perlahan, '
            'jangan sekaligus banyak.',
      ],
    ),

    _InfoSection(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF5A9FE0),
      iconBackground: Color(0xFFE3EEFC),
      title: 'Hindari Pemicu Sederhana',
      points: [
        'Jangan konsumsi makanan/minuman yang dapat memperparah '
            'gejala, seperti makanan pedas, berlemak, asam, kopi, '
            'soda, dan alkohol.',
      ],
    ),

    _InfoSection(
      icon: Icons.medication_outlined,
      iconColor: Color(0xFF4AA978),
      iconBackground: Color(0xFFDFF2E7),
      title: 'Jika Perlu, Konsumsi Obat Antasida',
      points: [
        'Obat antasida dapat membantu menetralkan asam lambung. '
            'Namun, gunakan sesuai anjuran dokter atau apoteker.',
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

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

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
            105,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 8),

              _buildHeroImage(),

              const SizedBox(height: 14),

              const Text(
                'Pertolongan Pertama saat Kambuh',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 6),

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
                      text: 'Tenang, ini ',
                    ),
                    TextSpan(
                      text: 'langkah sederhana',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' yang bisa membantu meredakan '
                          'gejala dengan cepat, sebelum kamu '
                          'mendapatkan penanganan lebih lanjut.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              for (int i = 0;
                  i < _sections.length;
                  i++) ...[
                _buildInfoCard(_sections[i]),

                if (i != _sections.length - 1)
                  const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),

              _buildRememberBox(
                header: 'Segera ke Dokter!',
                text:
                    'Segera periksakan diri jika nyeri dada semakin '
                    'berat atau tidak hilang setelah beberapa jam, '
                    'sering kambuh meski sudah melakukan langkah di '
                    'atas, atau muncul gejala lain seperti muntah, '
                    'sulit menelan, dan penurunan berat badan.',
              ),

              const SizedBox(height: 4),
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
          'assets/images/pertolongan_saat_kambuh.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                '🆘',
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

  Widget _buildRememberBox({
    String header = 'Ingat!',
    required String text,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171310),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            text,
            style: const TextStyle(
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