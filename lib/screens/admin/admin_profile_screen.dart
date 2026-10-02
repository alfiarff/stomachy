import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../landing_screen.dart';
import '../personal_information_screen.dart';
import '../change_password_screen.dart';

import '../../widgets/admin_bottom_navigation.dart';

import 'admin_home_screen.dart';
import 'admin_article_screen.dart';
import 'admin_content_screen.dart';

// ===============================================================
// PROFIL ADMIN
// ===============================================================

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState
    extends State<AdminProfileScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color softOrange = const Color(0xFFFFE3D1);
  final Color brown = const Color(0xFFB05039);

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
          builder: (context) => const AdminHomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminArticleScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminContentScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                16,
                22,
                110,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildProfileHeader(),

                      const SizedBox(height: 18),

                      _buildProfileMenuList(),

                      const Spacer(),

                      _buildLogoutButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // PROFILE HEADER
  // ===============================================================

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildProfileHeaderContent(
        name: 'Admin',
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

            if (firestorePhoto != null &&
                firestorePhoto.isNotEmpty) {
              photoBase64 = firestorePhoto;
            }
          }
        }

        if (name.isEmpty) {
          name = 'Admin';
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
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
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
                    fontWeight: FontWeight.w800,
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
        _buildProfileMenuCard(
          icon: Icons.person_outline_rounded,
          title: 'Informasi Pribadi',
          subtitle: 'Kelola informasi pribadi anda',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const PersonalInformationScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        _buildProfileMenuCard(
          icon: Icons.lock_outline_rounded,
          title: 'Ubah Kata Sandi',
          subtitle: 'Ganti password akun',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ChangePasswordScreen(),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: softOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: brown,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(
                              color: brown,
                              width: 0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: brown,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 36,
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
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Ya, Keluar',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
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