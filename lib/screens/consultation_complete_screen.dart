import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ConsultationCompleteScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String selectedTime;

  const ConsultationCompleteScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.selectedTime,
  });

  @override
  State<ConsultationCompleteScreen> createState() =>
      _ConsultationCompleteScreenState();
}

class _ConsultationCompleteScreenState
    extends State<ConsultationCompleteScreen> {
  int _selectedIndex = 4;

  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color primaryColor = Color(0xFFB13F1B);
  static const Color buttonColor = Color(0xFFAF4F35);
  static const Color darkColor = Color(0xFF241713);

  static const Color cardColor = Color(0xFFFFFCFA);
  static const Color headerCardColor = Color(0xFFFFDCC6);
  static const Color iconBackground = Color(0xFFFFE3D0);
  static const Color dividerColor = Color(0xFFF1D8CD);

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ScreeningScreen(),
          ),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorScreen(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EdukasiScreen(),
          ),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
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
            20,
            8,
            20,
            24,
          ),

          child: Column(
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 18),

              // =====================================================
              // LOGO SELESAI
              // =====================================================

              _buildSuccessLogo(),

              const SizedBox(height: 17),

              // =====================================================
              // JUDUL
              // =====================================================

              const Text(
                'Konsultasi Telah Selesai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 7),

              // =====================================================
              // DESKRIPSI
              // =====================================================

              const Text(
                'Terima kasih, konsultasi anda dengan dokter\n'
                'sudah selesai. Semoga keluhan anda segera membaik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: Color(0xFF3D3430),
                ),
              ),

              const SizedBox(height: 22),

              // =====================================================
              // DETAIL
              // =====================================================

              _buildConsultationDetail(),

              const SizedBox(height: 32),

              // =====================================================
              // BUTTON
              // =====================================================

              _buildBackHomeButton(),
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
      width: double.infinity,
      height: 42,
      child: Center(
        child: Text(
          'Konsultasi Selesai',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: darkColor,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // LOGO SELESAI
  // ===============================================================

  Widget _buildSuccessLogo() {
    return SizedBox(
      width: 290,
      height: 230,
      child: Image.asset(
        'assets/images/consultation_success.png',

        fit: BoxFit.contain,

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 90,
              color: primaryColor,
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // DETAIL KONSULTASI
  // ===============================================================

  Widget _buildConsultationDetail() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE87551),
          width: 0.8,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          // =========================================================
          // HEADER CARD
          // =========================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),

            decoration: const BoxDecoration(
              color: headerCardColor,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),

            child: const Text(
              'Detail Konsultasi',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),

          // =========================================================
          // CONTENT
          // =========================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            child: Column(
              children: [
                // DOKTER
                _buildDetailRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Dokter',
                  value: widget.doctorName,
                  subtitle: widget.specialty,
                  showDivider: true,
                ),

                // JENIS LAYANAN
                _buildDetailRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Jenis Layanan',
                  value: 'Chat Konsultasi',
                  showDivider: true,
                ),

                // WAKTU
                _buildDetailRow(
                  icon: Icons.access_time_rounded,
                  title: 'Waktu',
                  value: '${widget.selectedTime} WIB',
                  showDivider: true,
                ),

                // STATUS
                _buildStatusRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DETAIL ROW
  // ===============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required bool showDivider,
  }) {
    return Container(
      height: 68,

      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: dividerColor,
                  width: 0.8,
                ),
              )
            : null,
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =========================================================
          // ICON
          // =========================================================

          Container(
            width: 38,
            height: 38,

            decoration: const BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              size: 19,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 14),

          // =========================================================
          // LABEL
          // =========================================================

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C5148),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // =========================================================
          // VALUE KANAN
          // =========================================================

          SizedBox(
            width: 155,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  value,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  textAlign: TextAlign.right,

                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30221E),
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),

                  Text(
                    subtitle,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF77716E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATUS ROW
  // ===============================================================

  Widget _buildStatusRow() {
    return SizedBox(
      height: 68,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =========================================================
          // ICON
          // =========================================================

          Container(
            width: 38,
            height: 38,

            decoration: const BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 14),

          // =========================================================
          // LABEL
          // =========================================================

          const Expanded(
            child: Text(
              'Status',

              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C5148),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // =========================================================
          // STATUS KANAN
          // =========================================================

          SizedBox(
            width: 155,

            child: Align(
              alignment: Alignment.centerRight,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFDDF1D9),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  'Selesai',

                  textAlign: TextAlign.right,

                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF188447),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BUTTON
  // ===============================================================

  Widget _buildBackHomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

        child: const Text(
          'Kembali ke Beranda',

          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}