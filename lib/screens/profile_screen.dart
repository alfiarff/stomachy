import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'login_screen.dart';

import '../widgets/bottom_navigation.dart';

import 'personal_information_screen.dart';
import 'about_stomachy_screen.dart';
import 'history_screen.dart';
import 'food_recommendation_screen.dart';
import 'sport_recommendation_screen.dart';
import 'settings_screen.dart';
import 'grafik_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ===============================================================
  // VARIABLE
  // ===============================================================

  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color softOrange = const Color(0xFFFFE3D1);

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
            16,
            22,
            110,
          ),
          child: Column(
            children: [
              // =====================================================
              // PROFILE HEADER
              // =====================================================

              _buildProfileHeader(),

              const SizedBox(height: 18),

              // =====================================================
              // MENU PROFILE
              // =====================================================

              _buildMenuCard(),

              const SizedBox(height: 43),

              // =====================================================
              // TOMBOL KELUAR
              // =====================================================

              _buildLogoutButton(),

              const SizedBox(height: 20),
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
  // BOTTOM NAVIGATION
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
      return;
    }
  }

  // ===============================================================
  // PROFILE HEADER
  // ===============================================================

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildProfileHeaderContent(
        name: 'Pengguna',
        email: '',
        photoBase64: null,
        googlePhotoUrl: '',
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String name = user.displayName ?? '';
        String email = user.email ?? '';

        // Foto Google (fallback kalau belum upload foto sendiri)
        String googlePhotoUrl = user.photoURL ?? '';

        if (googlePhotoUrl.startsWith('data:')) {
          googlePhotoUrl = '';
        }

        String? photoBase64;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (data != null) {
            final firestoreName =
                data['name']?.toString().trim();

            final firestoreEmail =
                data['email']?.toString().trim();

            final firestorePhoto =
                data['photoBase64']?.toString().trim();

            if (firestoreName != null &&
                firestoreName.isNotEmpty) {
              name = firestoreName;
            }

            if (firestoreEmail != null &&
                firestoreEmail.isNotEmpty) {
              email = firestoreEmail;
            }

            // Foto Base64 dari Firestore (prioritas utama)
            if (firestorePhoto != null &&
                firestorePhoto.isNotEmpty) {
              photoBase64 = firestorePhoto;
            }
          }
        }

        if (name.isEmpty) {
          name = 'Pengguna';
        }

        return _buildProfileHeaderContent(
          name: name,
          email: email,
          photoBase64: photoBase64,
          googlePhotoUrl: googlePhotoUrl,
        );
      },
    );
  }

  // ===============================================================
  // PROFILE HEADER CONTENT
  // ===============================================================

  Widget _buildProfileHeaderContent({
    required String name,
    required String email,
    required String? photoBase64,
    required String googlePhotoUrl,
  }) {
    return Container(
      width: double.infinity,
      height: 86,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
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
          // =========================================================
          // FOTO PROFIL
          // =========================================================

          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8E8E8),
            ),
            child: ClipOval(
              child: _buildHeaderPhoto(
                photoBase64: photoBase64,
                googlePhotoUrl: googlePhotoUrl,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // =========================================================
          // NAMA DAN EMAIL
          // =========================================================

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30221E),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF493C37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // GAMBAR FOTO HEADER
  // ===============================================================

  Widget _buildHeaderPhoto({
    required String? photoBase64,
    required String googlePhotoUrl,
  }) {
    // 1. Foto Base64 (upload pengguna)
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(photoBase64),
          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 38,
              color: Color(0xFF777777),
            );
          },
        );
      } catch (e) {
        return const Icon(
          Icons.person,
          size: 38,
          color: Color(0xFF777777),
        );
      }
    }

    // 2. Foto Google
    if (googlePhotoUrl.isNotEmpty) {
      return Image.network(
        googlePhotoUrl,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            size: 38,
            color: Color(0xFF777777),
          );
        },
      );
    }

    // 3. Default
    return const Icon(
      Icons.person,
      size: 38,
      color: Color(0xFF777777),
    );
  }

  // ===============================================================
  // MENU PROFILE
  // ===============================================================

  Widget _buildMenuCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        14,
        8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Informasi Pribadi',
            subtitle: 'Kelola informasi pribadi anda',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PersonalInformationScreen(),
                ),
              );

              // StreamBuilder header otomatis refresh,
              // tidak perlu reload manual.
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.access_time_rounded,
            title: 'Riwayat',
            subtitle: 'Lihat riwayat cek AI dan konsultasi anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.directions_bike_outlined,
            title: 'Rekomendasi Olahraga',
            subtitle: 'Pilihan olahraga untukmu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const RecommendationSportScreen(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.local_drink_outlined,
            title: 'Rekomendasi Makanan',
            subtitle: 'Pilihan makanan untuk lambungmu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FoodRecommendationScreen(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.show_chart_rounded,
            title: 'Grafik',
            subtitle: 'Lihat perkembangan hasil skrining GERD',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GrafikScreen(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Kelola preferensi dan pengaturan aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),

          _buildDivider(),

          _buildProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Stomachy',
            subtitle: 'Informasi versi dan kebijakan aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AboutStomachyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFILE MENU ITEM
  // ===============================================================

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: softOrange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF705044),
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryBrown,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: Color(0xFF776C67),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.chevron_right_rounded,
              size: 25,
              color: Color(0xFF222222),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // DIVIDER
  // ===============================================================

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF3C8B8),
    );
  }

  // ===============================================================
  // LOGOUT BUTTON
  // ===============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEEE5),
          side: const BorderSide(
            color: Color(0xFFFF806A),
            width: 0.9,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color(0xFFB9543A),
            ),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB9543A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // LOGOUT DIALOG
  // ===============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 45,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              28,
              20,
              25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Konfirmasi Logout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB9543A),
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Apakah anda yakin ingin keluar dari sistem?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF493C37),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: Color(0xFFB9543A),
                              width: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFB9543A),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFB9543A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            'Ya, Keluar',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}