import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'screening_history_screen.dart';
import 'consultation_history_screen.dart';
import '../widgets/bottom_navigation.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color borderBrown = const Color(0xFFFF806A);

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
            22,
            12,
            22,
            105,
          ),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 28),

              _buildHistoryMenu(
                icon: Icons.health_and_safety_outlined,
                title: 'Riwayat Skrining',
                subtitle:
                    'Lihat hasil skrining GERD sebelumnya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ScreeningHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              _buildHistoryMenu(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Riwayat Chat',
                subtitle:
                    'Lihat riwayat konsultasi dengan dokter',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ConsultationHistoryScreen(),
                    ),
                  );
                },
              ),
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
      height: 42,
      child: Row(
        children: [
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
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Riwayat',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ===============================================================
  // HISTORY MENU
  // ===============================================================

  Widget _buildHistoryMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderBrown,
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3D1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 29,
                color: const Color(0xFFB65339),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: primaryBrown,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF776C67),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}