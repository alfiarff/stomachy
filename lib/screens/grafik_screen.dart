import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class GrafikScreen extends StatefulWidget {
  const GrafikScreen({super.key});

  @override
  State<GrafikScreen> createState() => _GrafikScreenState();
}

// =====================================================================
// MODEL DATA RIWAYAT SKRINING
// =====================================================================

class ScreeningHistory {
  final DateTime date;
  final bool atRisk;
  final List<String> complaints;

  const ScreeningHistory({
    required this.date,
    required this.atRisk,
    required this.complaints,
  });
}

// =====================================================================
// DATA RIWAYAT
// =====================================================================
//
// NANTI DATA INI BISA DIGANTI DENGAN DATA HASIL SKRINING ASLI.
// Untuk sementara dibuat sesuai contoh riwayat yang kamu kirim.
// =====================================================================

final List<ScreeningHistory> screeningHistory = [
  ScreeningHistory(
    date: DateTime(2026, 7, 10, 10, 15),
    atRisk: true,
    complaints: [
      'Asam naik',
      'Nyeri dada',
      'Perut terasa penuh',
    ],
  ),

  ScreeningHistory(
    date: DateTime(2026, 7, 26, 19, 30),
    atRisk: false,
    complaints: [
      'Mual',
    ],
  ),

  ScreeningHistory(
    date: DateTime(2026, 8, 12, 10, 24),
    atRisk: true,
    complaints: [
      'Panas di dada',
      'Asam naik',
      'Perut terasa penuh',
    ],
  ),
];

// =====================================================================
// SCREEN
// =====================================================================

class _GrafikScreenState extends State<GrafikScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);

  // ===================================================================
  // NAVIGATION
  // ===================================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // ================================================================
    // BERANDA
    // ================================================================

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // ================================================================
    // SKRINING
    // ================================================================

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // ================================================================
    // DOKTER
    // ================================================================

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // ================================================================
    // EDUKASI
    // ================================================================

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // ================================================================
    // PROFIL
    // ================================================================

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

  // ===================================================================
  // BUILD
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            105,
          ),
          child: Column(
            children: [
              // ======================================================
              // HEADER
              // ======================================================

              _buildHeader(),

              const SizedBox(height: 18),

              // ======================================================
              // GRAFIK PERKEMBANGAN
              // ======================================================

              _buildDevelopmentCard(),

              const SizedBox(height: 12),

              // ======================================================
              // RINGKASAN HASIL SKRINING
              // ======================================================

              _buildSummaryCard(),

              const SizedBox(height: 12),

              // ======================================================
              // KELUHAN YANG SERING DIPILIH
              // ======================================================

              _buildComplaintCard(),

              const SizedBox(height: 12),

              // ======================================================
              // INFORMASI
              // ======================================================

              _buildInformationCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ===============================================================
      // BOTTOM NAVIGATION
      // ===============================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===================================================================
  // HEADER
  // ===================================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          // TOMBOL KEMBALI
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // JUDUL
          const Expanded(
            child: Center(
              child: Text(
                'Grafik',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // PENYEIMBANG
          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // CARD GRAFIK
  // ===================================================================

  Widget _buildDevelopmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // JUDUL
          // ==========================================================

          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D8),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: Color(0xFFB9543A),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Perkembangan Skrining GERD',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB9543A),
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Lihat perubahan hasil skrining kamu dari waktu ke waktu.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: Color(0xFF493C37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // AREA GRAFIK
          // ==========================================================

          Container(
            width: double.infinity,
            height: 145,
            padding: const EdgeInsets.fromLTRB(
              2,
              4,
              2,
              0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBDD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: CustomPaint(
              painter: GERDChartPainter(
                history: screeningHistory,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 8),

          // ==========================================================
          // LEGEND
          // ==========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: const Color(0xFFE96B68),
                text: 'Berisiko GERD',
              ),

              const SizedBox(width: 28),

              _buildLegendItem(
                color: const Color(0xFF61C58A),
                text: 'Tidak Berisiko GERD',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // LEGEND
  // ===================================================================

  Widget _buildLegendItem({
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Color(0xFF6C5A54),
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // SUMMARY CARD
  // ===================================================================

  Widget _buildSummaryCard() {
    final int total = screeningHistory.length;

    final int riskCount = screeningHistory
        .where((item) => item.atRisk)
        .length;

    final int safeCount = screeningHistory
        .where((item) => !item.atRisk)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================

          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D8),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: Color(0xFFB9543A),
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ringkasan Hasil Skrining',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB9543A),
                    ),
                  ),

                  SizedBox(height: 1),

                  Text(
                    'Ringkasan riwayat skrining anda',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF493C37),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // SUMMARY
          // ==========================================================

          Container(
            width: double.infinity,
            height: 103,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6D3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Total Skrining',
                    value: '$total',
                    suffix: 'Kali',
                    valueColor: const Color(0xFFB9543A),
                  ),
                ),

                _buildVerticalDivider(),

                Expanded(
                  child: _buildSummaryItem(
                    title: 'Berisiko GERD',
                    value: '$riskCount',
                    suffix: 'Kali',
                    valueColor: const Color(0xFFE96B68),
                  ),
                ),

                _buildVerticalDivider(),

                Expanded(
                  child: _buildSummaryItem(
                    title: 'Tidak berisiko GERD',
                    value: '$safeCount',
                    suffix: 'Kali',
                    valueColor: const Color(0xFF16805C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // SUMMARY ITEM
  // ===================================================================

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String suffix,
    required Color valueColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB9543A),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),

        Text(
          suffix,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // VERTICAL DIVIDER
  // ===================================================================

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 66,
      color: const Color(0xFFD6B5A2),
    );
  }

  // ===================================================================
  // COMPLAINT CARD
  // ===================================================================

  Widget _buildComplaintCard() {
    final Map<String, int> complaintCount = {};

    for (final history in screeningHistory) {
      for (final complaint in history.complaints) {
        complaintCount[complaint] =
            (complaintCount[complaint] ?? 0) + 1;
      }
    }

    final int totalHistory = screeningHistory.length;

    final List<MapEntry<String, int>> sortedComplaints =
        complaintCount.entries.toList()
          ..sort(
            (a, b) => b.value.compareTo(a.value),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================

          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D8),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: Color(0xFFB9543A),
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Keluhan yang sering dipilih',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB9543A),
                    ),
                  ),

                  SizedBox(height: 1),

                  Text(
                    'Berdasarkan seluruh riwayat skrining anda',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF493C37),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ==========================================================
          // COMPLAINT LIST
          // ==========================================================

          if (sortedComplaints.isEmpty)
            const Padding(
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'Belum ada data keluhan.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            )
          else
            ...sortedComplaints.take(5).map(
              (entry) {
                final double percentage =
                    totalHistory == 0
                        ? 0
                        : entry.value / totalHistory;

                final int percentageValue =
                    (percentage * 100).round();

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _buildComplaintRow(
                    label: entry.key,
                    percentage: percentage,
                    percentageText:
                        '$percentageValue%',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ===================================================================
  // COMPLAINT ROW
  // ===================================================================

  Widget _buildComplaintRow({
    required String label,
    required double percentage,
    required String percentageText,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Color(0xFF493C37),
            ),
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              backgroundColor: const Color(0xFFF1E4DE),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFFB9543A),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 28,
          child: Text(
            percentageText,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Color(0xFF493C37),
            ),
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // INFORMATION CARD
  // ===================================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              size: 17,
              color: Color(0xFFB9543A),
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Text(
              'Grafik membantu melihat perubahan hasil skrining dari waktu ke waktu.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.35,
                color: Color(0xFF493C37),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// CUSTOM PAINTER GRAFIK GERD
// =====================================================================

class GERDChartPainter extends CustomPainter {
  final List<ScreeningHistory> history;

  GERDChartPainter({
    required this.history,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (history.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    // ================================================================
    // AREA GRAFIK
    // ================================================================

    const double leftPadding = 58;
    const double rightPadding = 10;
    const double topPadding = 17;
    const double bottomPadding = 32;

    final double chartWidth =
        size.width - leftPadding - rightPadding;

    final double chartHeight =
        size.height - topPadding - bottomPadding;

    final double chartLeft = leftPadding;
    final double chartRight =
        size.width - rightPadding;

    final double chartTop = topPadding;
    final double chartBottom =
        topPadding + chartHeight;

    // ================================================================
    // PAINT
    // ================================================================

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE8CFC3)
      ..strokeWidth = 0.8;

    final Paint riskLinePaint = Paint()
      ..color = const Color(0xFFE96B68)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final Paint safeLinePaint = Paint()
      ..color = const Color(0xFF61C58A)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // ================================================================
    // BACKGROUND GRID
    // ================================================================

    // Garis horizontal
    canvas.drawLine(
      Offset(chartLeft, chartTop),
      Offset(chartRight, chartTop),
      gridPaint,
    );

    canvas.drawLine(
      Offset(chartLeft, chartBottom),
      Offset(chartRight, chartBottom),
      gridPaint,
    );

    // Garis tengah
    final double middleY =
        chartTop + chartHeight / 2;

    canvas.drawLine(
      Offset(chartLeft, middleY),
      Offset(chartRight, middleY),
      gridPaint,
    );

    // Garis vertikal
    final int count = history.length;

    if (count > 1) {
      for (int i = 0; i < count; i++) {
        final double x =
            chartLeft +
            (chartWidth * i / (count - 1));

        canvas.drawLine(
          Offset(x, chartTop),
          Offset(x, chartBottom),
          gridPaint,
        );
      }
    } else {
      canvas.drawLine(
        Offset(chartLeft, chartTop),
        Offset(chartLeft, chartBottom),
        gridPaint,
      );
    }

    // ================================================================
    // POSISI TITIK
    // ================================================================

    final List<Offset> points = [];

    for (int i = 0; i < history.length; i++) {
      final ScreeningHistory item = history[i];

      double x;

      if (history.length == 1) {
        x = chartLeft + chartWidth / 2;
      } else {
        x = chartLeft +
            (chartWidth * i / (history.length - 1));
      }

      // Berisiko = atas
      // Tidak berisiko = bawah

      final double y = item.atRisk
          ? chartTop + chartHeight * 0.18
          : chartBottom - chartHeight * 0.18;

      points.add(
        Offset(x, y),
      );
    }

    // ================================================================
    // GARIS GRAFIK
    // ================================================================

    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final Offset first = points[i];
        final Offset second = points[i + 1];

        final bool firstRisk =
            history[i].atRisk;

        final bool secondRisk =
            history[i + 1].atRisk;

        final Paint linePaint;

        if (firstRisk && secondRisk) {
          linePaint = riskLinePaint;
        } else if (!firstRisk && !secondRisk) {
          linePaint = safeLinePaint;
        } else {
          // Kalau status berubah,
          // gunakan warna sesuai titik berikutnya.
          linePaint =
              secondRisk ? riskLinePaint : safeLinePaint;
        }

        canvas.drawLine(
          first,
          second,
          linePaint,
        );
      }
    }

    // ================================================================
    // TITIK
    // ================================================================

    for (int i = 0; i < points.length; i++) {
      final bool atRisk =
          history[i].atRisk;

      final Paint pointPaint = Paint()
        ..color = atRisk
            ? const Color(0xFFE96B68)
            : const Color(0xFF61C58A);

      canvas.drawCircle(
        points[i],
        4,
        pointPaint,
      );

      // Lingkaran putih kecil di tengah
      final Paint innerPaint = Paint()
        ..color = Colors.white;

      canvas.drawCircle(
        points[i],
        1.5,
        innerPaint,
      );
    }

    // ================================================================
    // LABEL Y
    // ================================================================

    _drawText(
      canvas,
      'Berisiko',
      Offset(
        5,
        chartTop + chartHeight * 0.10,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        color: Color(0xFFE96B68),
        fontWeight: FontWeight.w700,
      ),
    );

    _drawText(
      canvas,
      'GERD',
      Offset(
        18,
        chartTop + chartHeight * 0.10 + 10,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        color: Color(0xFFE96B68),
        fontWeight: FontWeight.w700,
      ),
    );

    _drawText(
      canvas,
      'Tidak',
      Offset(
        5,
        chartBottom - chartHeight * 0.19,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        color: Color(0xFF61C58A),
        fontWeight: FontWeight.w700,
      ),
    );

    _drawText(
      canvas,
      'berisiko',
      Offset(
        2,
        chartBottom - chartHeight * 0.19 + 10,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        color: Color(0xFF61C58A),
        fontWeight: FontWeight.w700,
      ),
    );

    _drawText(
      canvas,
      'GERD',
      Offset(
        18,
        chartBottom - chartHeight * 0.19 + 20,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        color: Color(0xFF61C58A),
        fontWeight: FontWeight.w700,
      ),
    );

    // ================================================================
    // LABEL X = TANGGAL
    // ================================================================

    for (int i = 0; i < history.length; i++) {
      final double x;

      if (history.length == 1) {
        x = chartLeft + chartWidth / 2;
      } else {
        x = chartLeft +
            (chartWidth * i / (history.length - 1));
      }

      final String dateText =
          '${history[i].date.day} ${_monthName(history[i].date.month)}';

      final String timeText =
          '${history[i].date.hour.toString().padLeft(2, '0')}:'
          '${history[i].date.minute.toString().padLeft(2, '0')}';

      _drawCenteredText(
        canvas,
        dateText,
        Offset(
          x,
          chartBottom + 5,
        ),
        const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 6.5,
          color: Color(0xFF65554F),
        ),
      );

      _drawCenteredText(
        canvas,
        timeText,
        Offset(
          x,
          chartBottom + 14,
        ),
        const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 6,
          color: Color(0xFF8B7B75),
        ),
      );

      // Label status
      _drawCenteredText(
        canvas,
        history[i].atRisk
            ? 'Berisiko'
            : 'Tidak',
        Offset(
          x,
          history[i].atRisk
              ? chartTop + 2
              : chartBottom - 30,
        ),
        TextStyle(
          fontFamily: 'Nunito',
          fontSize: 6,
          fontWeight: FontWeight.w700,
          color: history[i].atRisk
              ? const Color(0xFFE96B68)
              : const Color(0xFF61C58A),
        ),
      );
    }
  }

  // ===================================================================
  // EMPTY STATE
  // ===================================================================

  void _drawEmptyState(
    Canvas canvas,
    Size size,
  ) {
    _drawCenteredText(
      canvas,
      'Belum ada riwayat skrining',
      Offset(
        size.width / 2,
        size.height / 2 - 6,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 11,
        color: Color(0xFF777777),
        fontWeight: FontWeight.w600,
      ),
    );

    _drawCenteredText(
      canvas,
      'Lakukan skrining untuk melihat grafik',
      Offset(
        size.width / 2,
        size.height / 2 + 12,
      ),
      const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 8,
        color: Color(0xFF999999),
      ),
    );
  }

  // ===================================================================
  // DRAW TEXT
  // ===================================================================

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(
      canvas,
      offset,
    );
  }

  // ===================================================================
  // DRAW CENTER TEXT
  // ===================================================================

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    painter.layout();

    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy,
      ),
    );
  }

  // ===================================================================
  // MONTH
  // ===================================================================

  String _monthName(int month) {
    const List<String> months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month];
  }

  @override
  bool shouldRepaint(
    covariant GERDChartPainter oldDelegate,
  ) {
    return oldDelegate.history != history;
  }
}