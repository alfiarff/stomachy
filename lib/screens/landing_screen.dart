import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'login_screen.dart';

// ===============================================================
// ASSET MASKOT
// ===============================================================
// Kalau kamu punya file maskot terpisah (tanpa tulisan logo),
// ganti path di bawah ini, contoh:
// 'assets/images/maskot_stomachy.png'
const String kMascotAsset =
    'assets/images/mascot_happy_bayangan.png';

// ===============================================================
// PALET WARNA LANDING PAGE
// ===============================================================
const Color kLandingBg = Color(0xFFFFF5ED);
const Color kBrownHeading = Color(0xFFB05C41);
const Color kPinkHeading = Color(0xFFE8768E);
const Color kBrownButton = Color(0xFFA9583C);
const Color kTextBody = Color(0xFF8E8078);
const Color kTextDark = Color(0xFF3D2E27);
const Color kCardWhite = Color(0xFFFFFCF9);
const Color kIconCircle = Color(0xFFFBE4DC);
const Color kSalmonContainer = Color(0xFFF7C9BB);
const Color kDotInactive = Color(0xFFDCD2CB);

// ===============================================================
// LANDING SCREEN (3 HALAMAN YANG BISA DIGESER)
// ===============================================================
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() =>
      _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =============================================================
  // PINDAH KE HALAMAN REGISTRASI
  // =============================================================
  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kLandingBg,
      body: Stack(
        children: [
          // =========================================================
          // BUBBLE BACKGROUND ANIMASI
          // =========================================================
          const Positioned.fill(
            child: _BubbleBackground(),
          ),

          // =========================================================
          // LINGKARAN DECORATIVE (SESUAI DESAIN FIGMA)
          // =========================================================
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.25,
            child: _circle(
              size.width * 0.9,
              const Color(0x2EF2D9C2),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.3,
            child: _circle(
              size.width * 0.85,
              const Color(0x36F5C9BA),
            ),
          ),

          // =========================================================
          // KONTEN UTAMA (3 HALAMAN)
          // =========================================================
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _LandingPageOne(
                        active: _currentPage == 0,
                        pageController: _pageController,
                      ),
                      _LandingPageTwo(
                        active: _currentPage == 1,
                        pageController: _pageController,
                      ),
                        _LandingPageThree(
                        active: _currentPage == 2,
                        pageController: _pageController,
                        onStartPressed: _goToLogin,
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // INDIKATOR DOT (BISA DITEKAN)
                // =====================================================
                _buildDots(),

                SizedBox(height: size.height * 0.018),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // LINGKARAN DECORATIVE
  // =============================================================
  Widget _circle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // =============================================================
  // INDIKATOR DOT
  // =============================================================
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;

        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            width: isActive ? 26 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? kBrownHeading
                  : kDotInactive,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }
}

// ===============================================================
// WIDGET ANIMASI MASUK (MUNCUL BERTAHAP / STAGGER)
// ===============================================================
class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.controller,
    required this.order,
    required this.child,
  });

  final AnimationController controller;
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double start =
        (order * 0.12).clamp(0.0, 0.55).toDouble();
    final double end =
        (start + 0.45).clamp(0.0, 1.0).toDouble();

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - animation.value) * 34,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// ===============================================================
// WIDGET ANIMASI MENGAMBANG
// ===============================================================
class _FloatingWidget extends StatefulWidget {
  const _FloatingWidget({
    required this.child,
    this.amplitude = 8,
    this.phase = 0,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final double amplitude;
  final double phase;
  final Duration duration;

  @override
  State<_FloatingWidget> createState() =>
      _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final double dy =
            math.sin((_controller.value + widget.phase) *
                    2 *
                    math.pi) *
                widget.amplitude;

        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
    );
  }
}

// ===============================================================
// WIDGET PARALLAX SAAT HALAMAN DIGESER
// ===============================================================
class _Parallax extends StatelessWidget {
  const _Parallax({
    required this.pageController,
    required this.pageIndex,
    required this.depth,
    required this.child,
  });

  final PageController pageController;
  final int pageIndex;
  final double depth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      child: child,
      builder: (context, child) {
        double delta = 0;

        if (pageController.hasClients &&
            pageController.position.haveDimensions) {
          delta =
              ((pageController.page ??
                          pageIndex.toDouble()) -
                      pageIndex)
                  .clamp(-1.0, 1.0)
                  .toDouble();
        }

        return Transform.translate(
          offset: Offset(-delta * 55 * depth, 0),
          child: child,
        );
      },
    );
  }
}

// ===============================================================
// BUBBLE BACKGROUND (GELEMBUNG MELAYANG KE ATAS)
// ===============================================================
class _Bubble {
  const _Bubble(
    this.x,
    this.size,
    this.speed,
    this.phase,
    this.color,
  );

  final double x;
  final double size;
  final double speed;
  final double phase;
  final Color color;
}

class _BubbleBackground extends StatefulWidget {
  const _BubbleBackground();

  @override
  State<_BubbleBackground> createState() =>
      _BubbleBackgroundState();
}

class _BubbleBackgroundState
    extends State<_BubbleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  // x = posisi horizontal (0.0 - 1.0 dari lebar layar)
  // size = diameter bubble (pixel)
  // speed = kecepatan naik (semakin kecil semakin lambat)
  // phase = jeda awal agar bubble tidak bergerak seragam
  static const List<_Bubble> _bubbles = [
    _Bubble(0.06, 40, 0.50, 0.00, Color(0x30F5C9BA)),
    _Bubble(0.16, 20, 0.72, 0.35, Color(0x3AF8DCC8)),
    _Bubble(0.30, 58, 0.38, 0.62, Color(0x24F6C9BA)),
    _Bubble(0.47, 26, 0.62, 0.15, Color(0x36F8DCC8)),
    _Bubble(0.63, 44, 0.46, 0.78, Color(0x2AF2D9C2)),
    _Bubble(0.74, 18, 0.78, 0.45, Color(0x40F8DCC8)),
    _Bubble(0.88, 52, 0.40, 0.28, Color(0x24F5C9BA)),
    _Bubble(0.55, 14, 0.90, 0.55, Color(0x4AB7D1B0)),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                for (final bubble in _bubbles)
                  _buildBubble(bubble, width, height),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBubble(
    _Bubble bubble,
    double width,
    double height,
  ) {
    final double progress =
        (_controller.value * bubble.speed + bubble.phase) %
            1.0;

    // Bergerak dari bawah ke atas lalu berulang
    final double top = height -
        (progress * (height + bubble.size * 2)) -
        bubble.size;

    // Goyangan kecil ke kiri-kanan
    final double left = bubble.x * width +
        math.sin(progress * 2 * math.pi) * 12.0;

    // Fade in - fade out supaya muncul / hilang dengan lembut
    final double opacity = math
        .sin(progress * math.pi)
        .clamp(0.0, 1.0)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: bubble.size,
          height: bubble.size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubble.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// HALAMAN 1 : PERKENALAN
// ===============================================================
class _LandingPageOne extends StatefulWidget {
  const _LandingPageOne({
    required this.active,
    required this.pageController,
  });

  final bool active;
  final PageController pageController;

  @override
  State<_LandingPageOne> createState() =>
      _LandingPageOneState();
}

class _LandingPageOneState extends State<_LandingPageOne>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();

    if (widget.active) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(
      covariant _LandingPageOne oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active != oldWidget.active) {
      _animateEntrance(widget.active);
    }
  }

  void _animateEntrance(bool value) {
    if (value) {
      _entrance
        ..duration = const Duration(milliseconds: 700)
        ..forward();
    } else {
      _entrance
        ..duration = const Duration(milliseconds: 250)
        ..reverse();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.012),

          // =====================================================
          // LOGO KECIL DI ATAS
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 0,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 0,
              depth: 0.3,
              child: _buildHeaderLogo(size),
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // =====================================================
          // BADGE
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 1,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 0,
              depth: 0.15,
              child: _buildBadge(size),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // =====================================================
          // JUDUL
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 2,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 0,
              depth: 0.2,
              child: _buildHeading(size),
            ),
          ),

          SizedBox(height: size.height * 0.014),

          // =====================================================
          // PARAGRAF
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 3,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 0,
              depth: 0.25,
              child: _buildParagraph(size),
            ),
          ),

          // =====================================================
          // MASKOT BESAR (MENGAMBANG + PARALLAX)
          // =====================================================
          Expanded(
            child: Center(
              child: _StaggerItem(
                controller: _entrance,
                order: 4,
                child: _Parallax(
                  pageController: widget.pageController,
                  pageIndex: 0,
                  depth: 1.0,
                  child: _FloatingWidget(
                    amplitude: 9,
                    duration: const Duration(seconds: 4),
                    child: Image.asset(
                      kMascotAsset,
                      width: size.width * 0.68,
                      height: size.height * 0.30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // KARTU STATISTIK
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 5,
            child: _buildStatRow(size),
          ),

          SizedBox(height: size.height * 0.018),
        ],
      ),
    );
  }

  // ===========================================================
  // LOGO KECIL
  // ===========================================================
  Widget _buildHeaderLogo(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          kMascotAsset,
          width: size.width * 0.13,
          height: size.width * 0.13,
          fit: BoxFit.contain,
        ),
        SizedBox(width: size.width * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRainbowTitle(size),
            Text(
              'Teman Sehat Lambungmu',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: size.width * 0.026,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6E6259),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRainbowTitle(Size size) {
    const letters = 'STOMACHY';
    const colors = <Color>[
      Color(0xFFF4736B),
      Color(0xFFF59B51),
      Color(0xFFF4C542),
      Color(0xFF8CC152),
      Color(0xFF52BFAE),
      Color(0xFF5A9FE0),
      Color(0xFF7B6BD0),
      Color(0xFF9B6BD0),
    ];

    return Text.rich(
      TextSpan(
        children: List.generate(letters.length, (index) {
          return TextSpan(
            text: letters[index],
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w800,
              color: colors[index],
              letterSpacing: 0.5,
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================
  // BADGE
  // ===========================================================
  Widget _buildBadge(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.045,
        vertical: size.height * 0.008,
      ),
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Skrining Risiko GERD dengan AI',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.028,
          fontWeight: FontWeight.w700,
          color: kBrownHeading,
        ),
      ),
    );
  }

  // ===========================================================
  // JUDUL
  // ===========================================================
  Widget _buildHeading(Size size) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Sahabat Terbaik\n',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.078,
              fontWeight: FontWeight.w800,
              color: kBrownHeading,
              height: 1.2,
            ),
          ),
          TextSpan(
            text: 'Lambung Sehatmu',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.078,
              fontWeight: FontWeight.w800,
              color: kPinkHeading,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // PARAGRAF
  // ===========================================================
  Widget _buildParagraph(Size size) {
    final baseStyle = TextStyle(
      fontFamily: 'Nunito',
      fontSize: size.width * 0.026,
      color: kTextBody,
      height: 1.5,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: const [
          TextSpan(
            text:
                'STOMACHY bantu kamu memantau risiko GERD melalui cek skrining oleh AI, edukasi mingguan, dan konsultasi dokter ',
          ),
          TextSpan(
            text: 'semuanya dalam satu aplikasi.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: kBrownHeading,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // KARTU STATISTIK
  // ===========================================================
  Widget _buildStatRow(Size size) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            size: size,
            phase: 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '10rb+',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w800,
                    color: kBrownHeading,
                  ),
                ),
                SizedBox(height: size.height * 0.002),
                Text(
                  'Pengguna',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: size.width * 0.024,
                    color: kTextBody,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _buildStatCard(
            size: size,
            phase: 1.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                        color: kBrownHeading,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.012,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFF2B04C),
                      size: size.width * 0.045,
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.002),
                Text(
                  'Penilaian',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: size.width * 0.024,
                    color: kTextBody,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _buildStatCard(
            size: size,
            phase: 3.1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medical_services_rounded,
                  color: kBrownHeading,
                  size: size.width * 0.05,
                ),
                SizedBox(height: size.height * 0.002),
                Text(
                  'Medis',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: size.width * 0.024,
                    color: kTextBody,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Size size,
    required double phase,
    required Widget child,
  }) {
    return _FloatingWidget(
      phase: phase,
      amplitude: 3,
      duration: const Duration(seconds: 4),
      child: Container(
        height: size.height * 0.085,
        decoration: BoxDecoration(
          color: kCardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kBrownHeading,
            width: 1.1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ===============================================================
// HALAMAN 2 : FITUR UTAMA
// ===============================================================
class _LandingPageTwo extends StatefulWidget {
  const _LandingPageTwo({
    required this.active,
    required this.pageController,
  });

  final bool active;
  final PageController pageController;

  @override
  State<_LandingPageTwo> createState() =>
      _LandingPageTwoState();
}

class _LandingPageTwoState extends State<_LandingPageTwo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();

    if (widget.active) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(
      covariant _LandingPageTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active != oldWidget.active) {
      _animateEntrance(widget.active);
    }
  }

  void _animateEntrance(bool value) {
    if (value) {
      _entrance
        ..duration = const Duration(milliseconds: 700)
        ..forward();
    } else {
      _entrance
        ..duration = const Duration(milliseconds: 250)
        ..reverse();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        size.width * 0.055,
        size.height * 0.022,
        size.width * 0.055,
        size.height * 0.012,
      ),
      child: Column(
        children: [
          // =====================================================
          // BADGE FITUR UTAMA
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 0,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 1,
              depth: 0.15,
              child: _buildBadge(size),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // =====================================================
          // JUDUL
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 1,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 1,
              depth: 0.2,
              child: _buildHeading(size),
            ),
          ),

          SizedBox(height: size.height * 0.026),

          // =====================================================
          // KARTU FITUR UTAMA
          // =====================================================
          _buildFeatureCard(
            size: size,
            order: 2,
            emoji: '📋',
            title: 'Skrining Risiko GERD',
            description:
                'Jawab pertanyaan singkat, AI akan menghitung skor dan risiko GERDmu.',
          ),

          SizedBox(height: size.height * 0.014),

          _buildFeatureCard(
            size: size,
            order: 3,
            emoji: '📊',
            title: 'Grafik Riwayat Skrining',
            description:
                'Pantau perkembangan skor skriningmu lewat grafik yang mudah dibaca.',
          ),

          SizedBox(height: size.height * 0.014),

          _buildFeatureCard(
            size: size,
            order: 4,
            emoji: '📖',
            title: 'Edukasi GERD',
            description:
                'Artikel dan tips merawat lambung dari sumber terpercaya.',
          ),

          SizedBox(height: size.height * 0.014),

          _buildFeatureCard(
            size: size,
            order: 5,
            emoji: '🩺',
            title: 'Konsultasi dengan Dokter',
            description:
                'Tanya langsung ke dokter jika hasil skrining perlu tindak lanjut.',
          ),

          SizedBox(height: size.height * 0.022),

          // =====================================================
          // KARTU FITUR TAMBAHAN (ANIMASI MENGAMBANG)
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 6,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 1,
              depth: 0.3,
              child: _FloatingWidget(
                amplitude: 4,
                phase: 1.3,
                duration: const Duration(seconds: 5),
                child: _buildExtraCard(size),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.012),
        ],
      ),
    );
  }

  // ===========================================================
  // BADGE FITUR UTAMA
  // ===========================================================
  Widget _buildBadge(Size size) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.009,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE9DFF7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'FITUR UTAMA',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: size.width * 0.026,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF7B5EA7),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // JUDUL
  // ===========================================================
  Widget _buildHeading(Size size) {
    return Text(
      'Semua yang Lambung\nButuhkan',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: size.width * 0.065,
        fontWeight: FontWeight.w800,
        color: kBrownHeading,
        height: 1.25,
      ),
    );
  }

  // ===========================================================
  // KARTU FITUR
  // ===========================================================
  Widget _buildFeatureCard({
    required Size size,
    required int order,
    required String emoji,
    required String title,
    required String description,
  }) {
    return _StaggerItem(
      controller: _entrance,
      order: order,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: kCardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.115,
              height: size.width * 0.115,
              decoration: const BoxDecoration(
                color: kIconCircle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                  ),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.038),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: size.width * 0.031,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  SizedBox(height: size.height * 0.003),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: size.width * 0.023,
                      color: kTextBody,
                      height: 1.4,
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

  // ===========================================================
  // KARTU FITUR TAMBAHAN
  // ===========================================================
  Widget _buildExtraCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        size.width * 0.05,
        size.height * 0.022,
        size.width * 0.05,
        size.height * 0.026,
      ),
      decoration: BoxDecoration(
        color: kSalmonContainer,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29E8A98F),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Fitur Tambahan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB14E33),
            ),
          ),
          SizedBox(height: size.height * 0.016),
          _buildExtraItem(
            size,
            '📰',
            'Artikel baru setiap minggu',
          ),
          SizedBox(height: size.height * 0.012),
          _buildExtraItem(
            size,
            '🏋️',
            'Rekomendasi olahraga',
          ),
          SizedBox(height: size.height * 0.012),
          _buildExtraItem(
            size,
            '🥗',
            'Rekomendasi makanan',
          ),
        ],
      ),
    );
  }

  Widget _buildExtraItem(
    Size size,
    String emoji,
    String label,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.011,
      ),
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: size.width * 0.048,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: size.width * 0.027,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HALAMAN 3 : CALL TO ACTION
// ===============================================================
class _LandingPageThree extends StatefulWidget {
  const _LandingPageThree({
    required this.active,
    required this.pageController,
    required this.onStartPressed,
  });

  final bool active;
  final PageController pageController;
  final VoidCallback onStartPressed;

  @override
  State<_LandingPageThree> createState() =>
      _LandingPageThreeState();
}

class _LandingPageThreeState
    extends State<_LandingPageThree>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();

    if (widget.active) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(
      covariant _LandingPageThree oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active != oldWidget.active) {
      _animateEntrance(widget.active);
    }
  }

  void _animateEntrance(bool value) {
    if (value) {
      _entrance
        ..duration = const Duration(milliseconds: 700)
        ..forward();
    } else {
      _entrance
        ..duration = const Duration(milliseconds: 250)
        ..reverse();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.075,
      ),
      child: Column(
        children: [
          // =====================================================
          // MASKOT BESAR (MENGAMBANG + PARALLAX)
          // =====================================================
          Expanded(
            flex: 5,
            child: Center(
              child: _StaggerItem(
                controller: _entrance,
                order: 0,
                child: _Parallax(
                  pageController: widget.pageController,
                  pageIndex: 2,
                  depth: 1.0,
                  child: _FloatingWidget(
                    amplitude: 10,
                    duration: const Duration(seconds: 4),
                    child: Image.asset(
                      kMascotAsset,
                      width: size.width * 0.72,
                      height: size.height * 0.33,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // JUDUL
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 1,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 2,
              depth: 0.2,
              child: Text(
                'Ayo Coba STOMACHY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: size.width * 0.075,
                  fontWeight: FontWeight.w800,
                  color: kBrownHeading,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.016),

          // =====================================================
          // PARAGRAF
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 2,
            child: _Parallax(
              pageController: widget.pageController,
              pageIndex: 2,
              depth: 0.3,
              child: Text(
                'Mulai perjalanan lambung sehatmu hari ini.\nSkrining pertamamu cuma 2 menit.\nCepat, mudah dan menyenangkan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: size.width * 0.027,
                  color: kTextBody,
                  height: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // =====================================================
          // TOMBOL MULAI SEKARANG
          // =====================================================
          _StaggerItem(
            controller: _entrance,
            order: 3,
            child: _PrimaryButton(
              label: 'Mulai Sekarang',
              onTap: widget.onStartPressed,
            ),
          ),

          SizedBox(height: size.height * 0.028),
        ],
      ),
    );
  }
}

// ===============================================================
// TOMBOL UTAMA (DENGAN ANIMASI TEKAN)
// ===============================================================
class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() =>
      _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: size.height * 0.056,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kBrownButton,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40A9583C),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.042,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}