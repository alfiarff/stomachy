import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'landing_screen.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/stomachy_card.dart';

import 'personal_information_screen.dart';
import 'about_stomachy_screen.dart';
import 'history_screen.dart';
import 'food_recommendation_screen.dart';
import 'sport_recommendation_screen.dart';
import 'settings_screen.dart';
import 'grafik_screen.dart';

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
  final Color brown = const Color(0xFFB05039);

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

              _buildProfileMenuList(),

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

        // Foto Google sebagai fallback
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

            // Foto Base64 dari Firestore
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
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 16,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            // =======================================================
            // FOTO PROFIL
            // =======================================================

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

            // =======================================================
            // NAMA DAN EMAIL
            // =======================================================

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
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Colors.black,
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

  // ===============================================================
  // GAMBAR FOTO HEADER
  // ===============================================================

  Widget _buildHeaderPhoto({
    required String? photoBase64,
    required String googlePhotoUrl,
  }) {
    // 1. Foto Base64
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(photoBase64),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 38,
              color: brown,
            );
          },
        );
      } catch (e) {
        return Icon(
          Icons.person,
          size: 38,
          color: brown,
        );
      }
    }

    // 2. Foto Google
    if (googlePhotoUrl.isNotEmpty) {
      return Image.network(
        googlePhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 38,
            color: brown,
          );
        },
      );
    }

    // 3. Default
    return Icon(
      Icons.person,
      size: 38,
      color: brown,
    );
  }

  // ===============================================================
  // MENU PROFILE
  // ===============================================================

  Widget _buildProfileMenuList() {
    return Column(
      children: [
        // ===========================================================
        // INFORMASI PRIBADI
        // ===========================================================

        _buildProfileMenuCard(
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
          },
        ),

        const SizedBox(height: 14),

        // ===========================================================
        // RIWAYAT
        // ===========================================================

        _buildProfileMenuCard(
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

        const SizedBox(height: 14),

        // ===========================================================
        // REKOMENDASI OLAHRAGA
        // ===========================================================

        _buildProfileMenuCard(
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

        const SizedBox(height: 14),

        // ===========================================================
        // REKOMENDASI MAKANAN
        // ===========================================================

        _buildProfileMenuCard(
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

        const SizedBox(height: 14),

        // ===========================================================
        // GRAFIK
        // ===========================================================

        _buildProfileMenuCard(
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

        const SizedBox(height: 14),

        // ===========================================================
        // PENGATURAN
        // ===========================================================

        _buildProfileMenuCard(
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

        const SizedBox(height: 14),

        // ===========================================================
        // TENTANG STOMACHY
        // ===========================================================

        _buildProfileMenuCard(
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
    );
  }

  // ===============================================================
  // PROFILE MENU CARD
  // ===============================================================

  Widget _buildProfileMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return StomachyCard(
      color: const Color(0xFFFFFCF9),
      radius: 16,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            // =======================================================
            // ICON
            // =======================================================

            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: softOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 21,
                color: brown,
              ),
            ),

            const SizedBox(width: 12),

            // =======================================================
            // TITLE + SUBTITLE
            // =======================================================

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            // =======================================================
            // ARROW
            // =======================================================

            const Icon(
              Icons.chevron_right_rounded,
              size: 23,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // LOGOUT BUTTON
  // ===============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 19,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Apakah anda yakin ingin keluar dari sistem?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Colors.black,
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
                            side: BorderSide(
                              color: brown,
                              width: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: brown,
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
                                    const LandingScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
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
                              fontSize: 11,
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