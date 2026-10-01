import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class GejalaTandaBahayaScreen extends StatefulWidget {
  const GejalaTandaBahayaScreen({super.key});

  @override
  State<GejalaTandaBahayaScreen> createState() =>
      _GejalaTandaBahayaScreenState();
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

class _GejalaTandaBahayaScreenState
    extends State<GejalaTandaBahayaScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);

  final Set<String> _expandedSections = {
    'Gejala Umum',
  };

  // ===============================================================
  // DATA SEMUA SEKSI
  // ===============================================================

  static const List<_InfoSection> _sections = [
    _InfoSection(
      icon: Icons.sentiment_satisfied_alt_outlined,
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
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFE8804C),
      iconBackground: Color(0xFFFFE9DC),
      title: 'Gejala yang Perlu Diwaspadai',
      points: [
        'Nyeri dada yang berat atau menetap',
        'Sulit atau nyeri saat menelan',
        'Makanan terasa tersangkut saat ditelan',
        'Muntah berulang',
        'Berat badan turun tanpa sebab yang jelas',
        'Muntah darah atau BAB berwarna hitam',
      ],
    ),

    _InfoSection(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF5A9FE0),
      iconBackground: Color(0xFFE3EEFC),
      title: 'Jangan Abaikan Gejala',
      points: [
        'Gejala yang sering muncul dapat menjadi tanda bahwa kamu '
            'perlu mendapatkan pemeriksaan. Catat frekuensi dan kondisi '
            'saat gejala muncul agar lebih mudah menjelaskannya kepada '
            'dokter.',
      ],
    ),

    _InfoSection(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFF4AA978),
      iconBackground: Color(0xFFDFF2E7),
      title: 'Data Prevalensi di Indonesia',
      points: [
        'GERD adalah kondisi umum di seluruh dunia. Di Indonesia, '
            'diperkirakan sekitar 274.496 orang menderita GERD pada '
            'tahun 2021. Namun, tidak ada statistik nasional, dengan '
            'angka kematian yang sangat rendah, sekitar 0,02–0,20 per '
            '100.000 orang.',
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
                'Gejala & Tanda Bahaya (Red Flags)',
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
                      text: 'Kenali gejala GERD dan ',
                    ),
                    TextSpan(
                      text: 'tanda bahaya',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' yang perlu diperhatikan agar kamu '
                          'dapat mengetahui kapan keluhan masih dapat '
                          'ditangani dan kapan perlu mendapatkan '
                          'pemeriksaan dokter.',
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
                text:
                    'Mengenali gejala sejak awal dapat membantu kamu '
                    'menentukan langkah yang tepat. Jika muncul tanda '
                    'bahaya, jangan menunda untuk mencari pertolongan '
                    'medis.',
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
          'assets/images/gejala_tanda_bahaya.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                '⚠️',
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
          const Text(
            'Ingat!',
            style: TextStyle(
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