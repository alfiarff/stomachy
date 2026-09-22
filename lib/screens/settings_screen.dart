import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===============================================================
  // SELECTED BOTTOM NAVIGATION
  // ===============================================================

  int _selectedIndex = 4;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);

  // ===============================================================
  // STATUS TOGGLE
  // ===============================================================

  bool notificationApp = false;
  bool reminderGerd = false;
  bool reminderConsultation = false;

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
            22,
            12,
            22,
            105,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              _buildHeader(),

              const SizedBox(height: 27),

              // =====================================================
              // BAGIAN AKUN
              // =====================================================

              _buildSectionTitle('Akun'),

              const SizedBox(height: 10),

              _buildAccountCard(),

              const SizedBox(height: 23),

              // =====================================================
              // BAGIAN NOTIFIKASI
              // =====================================================

              _buildSectionTitle('Notifikasi'),

              const SizedBox(height: 10),

              // NOTIFIKASI APLIKASI
              _buildNotificationCard(
                icon: Icons.notifications_none_rounded,
                title: 'Notifikasi Aplikasi',
                description: 'Atur pemberitahuan dari Stomachy',
                value: notificationApp,
                onChanged: (value) {
                  setState(() {
                    notificationApp = value;
                  });
                },
              ),

              const SizedBox(height: 9),

              // PENGINGAT CEK GERD
              _buildNotificationCard(
                icon: Icons.access_time_rounded,
                title: 'Pengingat Cek GERD',
                description: 'Atur pengingat untuk melakukan cek GERD',
                value: reminderGerd,
                onChanged: (value) {
                  setState(() {
                    reminderGerd = value;
                  });
                },
              ),

              const SizedBox(height: 9),

              // PENGINGAT KONSULTASI
              _buildNotificationCard(
                icon: Icons.calendar_month_outlined,
                title: 'Pengingat Konsultasi',
                description: 'Atur pengingat jadwal konsultasi',
                value: reminderConsultation,
                onChanged: (value) {
                  setState(() {
                    reminderConsultation = value;
                  });
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ===========================================================
      // BOTTOM NAVIGATION
      // ===========================================================

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
          // =======================================================
          // TOMBOL KEMBALI
          // =======================================================

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

          // =======================================================
          // JUDUL
          // =======================================================

          Expanded(
            child: Center(
              child: Text(
                'Pengaturan',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // =======================================================
          // PENYEIMBANG
          // =======================================================

          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF30221E),
      ),
    );
  }

  // ===============================================================
  // ACCOUNT CARD
  // ===============================================================

  Widget _buildAccountCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChangePasswordScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFFF806A),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // =====================================================
            // ICON
            // =====================================================

            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8D8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: Color(0xFFB9543A),
              ),
            ),

            const SizedBox(width: 10),

            // =====================================================
            // TEXT
            // =====================================================

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF30221E),
                    ),
                  ),

                  SizedBox(height: 1),

                  Text(
                    'Ganti kata sandi akun anda',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF493C37),
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CHEVRON
            // =====================================================

            const Icon(
              Icons.chevron_right_rounded,
              size: 25,
              color: Color(0xFFB9543A),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // NOTIFICATION CARD
  // ===============================================================

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // =======================================================
          // ICON
          // =======================================================

          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8D8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFB9543A),
            ),
          ),

          const SizedBox(width: 10),

          // =======================================================
          // TEXT
          // =======================================================

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30221E),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF493C37),
                  ),
                ),
              ],
            ),
          ),

          // =======================================================
          // SWITCH ON / OFF
          // =======================================================

          _buildCustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CUSTOM SWITCH
  // ===============================================================

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,

      // ===========================================================
      // WARNA SAAT ON
      // ===========================================================

      activeColor: Colors.white,

      activeTrackColor: const Color(0xFFB9543A),

      // ===========================================================
      // WARNA SAAT OFF / MATI
      // ===========================================================

      inactiveThumbColor: const Color(0xFFB8B0AC),

      inactiveTrackColor: const Color(0xFFE5DDD8),

      // ===========================================================
      // UKURAN / BENTUK
      // ===========================================================

      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
        (states) {
          return null;
        },
      ),
    );
  }
}