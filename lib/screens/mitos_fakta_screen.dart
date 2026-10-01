import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class MitosFaktaScreen extends StatefulWidget {
  const MitosFaktaScreen({super.key});

  @override
  State<MitosFaktaScreen> createState() =>
      _MitosFaktaScreenState();
}

// =====================================================================
// MODEL MITOS & FAKTA
// =====================================================================

class _MitosFaktaItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String mitos;
  final String fakta;

  const _MitosFaktaItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.mitos,
    required this.fakta,
  });
}

class _MitosFaktaScreenState
    extends State<MitosFaktaScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);

  final Set<String> _expandedSections = {};

  // ===============================================================
  // DATA SEMUA MITOS & FAKTA
  // ===============================================================

  static const List<_MitosFaktaItem> _items = [
    _MitosFaktaItem(
      icon: Icons.error_outline_rounded,
      iconColor: Color(0xFFE8804C),
      iconBackground: Color(0xFFFFE9DC),
      title: 'GERD Hanya karena Makanan Pedas?',
      mitos:
          'GERD hanya terjadi setelah makan makanan pedas.',
      fakta:
          'GERD bisa dipicu oleh berbagai jenis makanan, '
          'termasuk makanan berlemak, asam, kopi, cokelat, '
          'atau bahkan makanan yang tidak pedas.',
    ),

    _MitosFaktaItem(
      icon: Icons.sentiment_dissatisfied_outlined,
      iconColor: Color(0xFF7B6BD0),
      iconBackground: Color(0xFFEDE9FB),
      title: 'Pemicunya Sama untuk Semua Orang?',
      mitos:
          'Semua orang dengan GERD harus menghindari makanan '
          'yang sama.',
      fakta:
          'Pemicu GERD dapat berbeda pada setiap orang. '
          'Penanganan nonfarmakologis dapat dilakukan dengan '
          'modifikasi gaya hidup sesuai kondisi masing-masing.',
    ),

    _MitosFaktaItem(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF5A9FE0),
      iconBackground: Color(0xFFE3EEFC),
      title: 'GERD Hanya Menyebabkan Maag?',
      mitos:
          'GERD hanya menyebabkan sakit maag atau rasa terbakar '
          'di dada.',
      fakta:
          'Olahraga ringan justru aman dan bermanfaat untuk '
          'pencernaan, selama tidak dilakukan setelah makan '
          'dan tidak terlalu berat.',
    ),

    _MitosFaktaItem(
      icon: Icons.opacity_outlined,
      iconColor: Color(0xFF4AA978),
      iconBackground: Color(0xFFDFF2E7),
      title: 'Susu Meredakan Asam Lambung?',
      mitos:
          'Susu bisa langsung meredakan asam lambung.',
      fakta:
          'Susu memang bisa menenangkan sementara, tetapi '
          'pada sebagian orang justru dapat meningkatkan '
          'produksi asam lambung.',
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
                'Yuk, Kenali Mitos dan Fakta tentang GERD!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Banyak informasi yang beredar, tapi tidak semuanya '
                'benar. Pencet setiap card untuk melihat '
                'penjelasannya!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 16),

              for (int i = 0;
                  i < _items.length;
                  i++) ...[
                _buildMitosFaktaCard(_items[i]),

                if (i != _items.length - 1)
                  const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),

              _buildRememberBox(),

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
          'assets/images/mitos_fakta.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                '🧐',
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
  // CARD MITOS & FAKTA (EXPANDABLE)
  // ===============================================================

  Widget _buildMitosFaktaCard(
    _MitosFaktaItem item,
  ) {
    final bool isExpanded =
        _expandedSections.contains(item.title);

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
                      .remove(item.title);
                } else {
                  _expandedSections
                      .add(item.title);
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
                      color: item.iconBackground,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 19,
                      color: item.iconColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171310),
                      ),
                    ),
                  ),

                  const Text(
                    '2 poin',
                    style: TextStyle(
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
                  // MITOS
                  _buildLabelRow(
                    label: '✕ Mitos',
                    labelColor:
                        const Color(0xFFB83D27),
                    text: item.mitos,
                  ),

                  const SizedBox(height: 8),

                  // FAKTA
                  _buildLabelRow(
                    label: '✓ Fakta',
                    labelColor:
                        const Color(0xFF168B65),
                    text: item.fakta,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BARIS LABEL (MITOS / FAKTA)
  // ===============================================================

  Widget _buildLabelRow({
    required String label,
    required Color labelColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 44,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: labelColor,
            ),
          ),

          const SizedBox(height: 2),

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
            'Tidak semua informasi yang beredar benar. Selalu '
            'periksa sumbernya dan konsultasikan ke dokter atau '
            'apoteker sebelum mengikuti saran kesehatan.',
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