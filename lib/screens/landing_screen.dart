import 'package:flutter/material.dart';

/// Halaman Landing Page 1 untuk aplikasi STOMACHY
/// Berdasarkan referensi desain Figma (Mobile Portrait).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // Indikator halaman aktif (halaman 1 = index 0)
  final int _currentPage = 0;

  // ===========================================================================
  // PALET WARNA RESMI STOMACHY
  // ===========================================================================
  static const Color _bgMain = Color(0xFFFFF5ED); // Cream sangat muda
  static const Color _primaryBrown = Color(0xFFB05039); // Cokelat utama STOMACHY
  static const Color _accentPink = Color(0xFFD85C83); // Pink/mauve judul
  static const Color _cardBg = Color(0xFFFFFCF9); // Cream/putih card
  static const Color _textMuted = Color(0xFF8F7A74); // Abu-abu kecokelatan deskripsi
  static const Color _statTitleColor = Color(0xFF8B3A26); // Cokelat tua angka statistik
  static const Color _statSubtitleColor = Color(0xFFA59089); // Cokelat muda label statistik
  static const Color _circleTopRight = Color(0xFFF9E8DC); // Dekorasi cream lingkaran kanan atas
  static const Color _circleBottomLeft = Color(0xFFFCE1E4); // Dekorasi pink pastel kiri bawah
  static const Color _indicatorInactive = Color(0xFFE2D6D0); // Titik indikator non-aktif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: Stack(
        children: [
          // ===================================================================
          // 1. DEKORASI BACKGROUND (SHAPES LINGKARAN BESAR)
          // ===================================================================
          // Lingkaran dekorasi kanan atas (cream sedikit lebih hangat)
          Positioned(
            top: -90,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _circleTopRight,
              ),
            ),
          ),

          // Lingkaran dekorasi kiri bawah (pink pastel muda)
          Positioned(
            bottom: -70,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _circleBottomLeft,
              ),
            ),
          ),

          // ===================================================================
          // 2. KONTEN UTAMA
          // ===================================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // --- LOGO STOMACHY ---
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Image.asset(
                              'assets/images/logo_beranda_stomachy.png',
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // --- BADGE KAPSUL / PILL ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: _buildBadge(),
                          ),

                          const SizedBox(height: 14),

                          // --- JUDUL UTAMA (DUA BARIS) ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: _buildHeadline(),
                          ),

                          const SizedBox(height: 14),

                          // --- PARAGRAF DESKRIPSI ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: _buildDescription(),
                          ),

                          // --- MASCOT UTAMA DI TENGAH ---
                          const Spacer(),
                          Center(
                            child: _buildMascotSection(),
                          ),
                          const Spacer(),

                          // --- 3 KARTU STATISTIK ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildStatisticsSection(),
                          ),

                          const SizedBox(height: 22),

                          // --- PAGE INDICATOR (3 TITIK DI BAWAH) ---
                          _buildPageIndicator(),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: BADGE "Skrining Risiko GERD dengan AI"
  // ===========================================================================
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: _primaryBrown.withValues(alpha: 0.8),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBrown.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Text(
        'Skrining Risiko GERD dengan AI',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _primaryBrown,
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET: JUDUL UTAMA (Sahabat Terbaik / Lambung Sehatmu)
  // ===========================================================================
  Widget _buildHeadline() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sahabat Terbaik',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: _primaryBrown,
            height: 1.12,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          'Lambung Sehatmu',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: _accentPink,
            height: 1.12,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET: PARAGRAF DESKRIPSI
  // ===========================================================================
  Widget _buildDescription() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          height: 1.42,
          color: _textMuted,
        ),
        children: [
          TextSpan(
            text:
                'STOMACHY bantu kamu memantau risiko GERD melalui\ncek skrining oleh AI, edukasi mingguan, dan konsultasi\ndokter ',
          ),
          TextSpan(
            text: 'semuanya dalam satu aplikasi.',
            style: TextStyle(
              color: _primaryBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: MASCOT UTAMA & BAYANGAN (GROUND SHADOW)
  // ===========================================================================
  Widget _buildMascotSection() {
    return SizedBox(
      width: 280,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Efek bayangan tanah (ground shadow) tepat di bawah kaki maskot
          Positioned(
            bottom: 14,
            child: Container(
              width: 175,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(175, 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC7B1A6).withValues(alpha: 0.40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Gambar maskot STOMACHY
          Image.asset(
            'assets/images/mascot_happy.png',
            width: 270,
            height: 260,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: TIGA KARTU STATISTIK HORIZONTAL
  // ===========================================================================
  Widget _buildStatisticsSection() {
    return Row(
      children: [
        // Kartu 1: 10rb+ Pengguna
        Expanded(
          child: _buildStatCard(
            topWidget: const Text(
              '10rb+',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _statTitleColor,
              ),
            ),
            label: 'Pengguna',
          ),
        ),

        const SizedBox(width: 10),

        // Kartu 2: 4.9 ★ Penilaian
        Expanded(
          child: _buildStatCard(
            topWidget: const Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '4.9',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _statTitleColor,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.star_rounded,
                  size: 19,
                  color: _statTitleColor,
                ),
              ],
            ),
            label: 'Penilaian',
          ),
        ),

        const SizedBox(width: 10),

        // Kartu 3: Ikon Medis & Teks Medis
        Expanded(
          child: _buildStatCard(
            // Catatan: Jika ingin menggunakan asset gambar sendiri untuk ikon medis,
            // Anda dapat mengganti _buildStethoscopeIcon() dengan Image.asset('assets/images/...', height: 22)
            topWidget: _buildStethoscopeIcon(),
            label: 'Medis',
          ),
        ),
      ],
    );
  }

  // Helper untuk membuat card statistik tunggal
  Widget _buildStatCard({
    required Widget topWidget,
    required String label,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryBrown.withValues(alpha: 0.85),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBrown.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          topWidget,
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statSubtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: IKON STETOSKOP MEDIS (Kustom Garis Sesuai Screenshot)
  // ===========================================================================
  Widget _buildStethoscopeIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _StethoscopePainter(color: _statTitleColor),
      ),
    );
  }

  // ===========================================================================
  // WIDGET: PAGE INDICATOR (3 TITIK DI TENGAH BAWAH)
  // ===========================================================================
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4.5),
          width: isActive ? 8.5 : 7.0,
          height: isActive ? 8.5 : 7.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? _primaryBrown : _indicatorInactive,
          ),
        );
      }),
    );
  }
}

/// CustomPainter untuk menggambar ikon stetoskop garis persis seperti screenshot Figma
class _StethoscopePainter extends CustomPainter {
  final Color color;

  const _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.55
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // 1. Eartips (Dua titik kecil di bagian telinga atas)
    canvas.drawCircle(Offset(w * 0.28, h * 0.14), 1.1, fillPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.14), 1.1, fillPaint);

    // 2. Binaural Tubes (Lengkungan U bagian atas yang simetris)
    final uPath = Path()
      ..moveTo(w * 0.28, h * 0.14)
      ..quadraticBezierTo(w * 0.28, h * 0.44, w * 0.50, h * 0.52)
      ..quadraticBezierTo(w * 0.72, h * 0.44, w * 0.72, h * 0.14);
    canvas.drawPath(uPath, strokePaint);

    // 3. Flexible Tubing (Selang bawah yang melengkung elegan ke kanan)
    final tubePath = Path()
      ..moveTo(w * 0.50, h * 0.52)
      ..cubicTo(
        w * 0.50,
        h * 0.76,
        w * 0.76,
        h * 0.98,
        w * 0.82,
        h * 0.72,
      )
      ..cubicTo(
        w * 0.85,
        h * 0.54,
        w * 0.92,
        h * 0.54,
        w * 0.93,
        h * 0.58,
      );
    canvas.drawPath(tubePath, strokePaint);

    // 4. Chest piece / Diaphragm (Lingkaran kecil kepala stetoskop)
    canvas.drawCircle(Offset(w * 0.93, h * 0.60), 2.8, strokePaint);
    canvas.drawCircle(Offset(w * 0.93, h * 0.60), 1.2, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      oldDelegate.color != color;
}
