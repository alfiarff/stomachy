import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  // ===============================================================
  // NAVIGATION
  // ===============================================================

  int _selectedIndex = 4;

  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ===============================================================
  // STATE PASSWORD
  // ===============================================================

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _passwordChanged = false;
  bool _isLoading = false;

  // ===============================================================
  // COLOR
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);

  final Color cardColor = const Color(0xFFFFE9DC);

  final Color primaryBrown = const Color(0xFFB3543A);

  final Color textColor = const Color(0xFF171310);

  final Color borderColor = const Color(0xFFFF806A);

  final Color placeholderColor = const Color(0xFF8A7B75);

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

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

              const SizedBox(height: 20),

              // =====================================================
              // SECURITY CARD
              // =====================================================

              _buildSecurityCard(),

              const SizedBox(height: 45),

              // =====================================================
              // SUCCESS MESSAGE
              // =====================================================

              if (_passwordChanged) ...[
                _buildSuccessMessage(),

                const SizedBox(height: 14),
              ],

              // =====================================================
              // CURRENT PASSWORD
              // =====================================================

              _buildPasswordField(
                label: 'Kata Sandi Saat ini',
                hint: 'Masukkan kata sandi anda saat ini',
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                onVisibilityTap: () {
                  setState(() {
                    _obscureCurrentPassword =
                        !_obscureCurrentPassword;
                  });
                },
              ),

              const SizedBox(height: 12),

              // =====================================================
              // NEW PASSWORD
              // =====================================================

              _buildPasswordField(
                label: 'Kata Sandi Baru',
                hint: 'Masukkan kata sandi baru',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                onVisibilityTap: () {
                  setState(() {
                    _obscureNewPassword =
                        !_obscureNewPassword;
                  });
                },
              ),

              const SizedBox(height: 12),

              // =====================================================
              // CONFIRM PASSWORD
              // =====================================================

              _buildPasswordField(
                label: 'Konfirmasi Kata Sandi Baru',
                hint: 'Masukkan ulang kata sandi baru',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onVisibilityTap: () {
                  setState(() {
                    _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 37),

              // =====================================================
              // SAVE BUTTON
              // =====================================================

              _buildSaveButton(),

              const SizedBox(height: 10),

              // =====================================================
              // CANCEL BUTTON
              // =====================================================

              _buildCancelButton(),
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
      height: 42,

      child: Row(
        children: [
          // =========================================================
          // BACK BUTTON
          // =========================================================

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

          // =========================================================
          // TITLE
          // =========================================================

          Expanded(
            child: Center(
              child: Text(
                'Ubah Kata Sandi',

                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // =========================================================
          // BALANCER
          // =========================================================

          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECURITY CARD
  // ===============================================================

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,

      height: 132,

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // =========================================================
          // PASSWORD IMAGE
          // =========================================================

          SizedBox(
            width: 105,
            height: 105,

            child: Image.asset(
              'assets/images/password_lock.png',

              fit: BoxFit.contain,

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.lock_outline_rounded,
                  size: 70,
                  color: Color(0xFFFFA04D),
                );
              },
            ),
          ),

          const SizedBox(width: 6),

          // =========================================================
          // TEXT
          // =========================================================

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Jaga keamanan akunmu',

                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171310),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Gunakan kata sandi yang kuat '
                  'dan jangan bagikan dengan '
                  'siapa pun.',

                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF30221E),
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
  // SUCCESS MESSAGE
  // ===============================================================

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFBFE3B6),

        borderRadius: BorderRadius.circular(10),
      ),

      child: const Text(
        'Kata sandi anda berhasil diubah!',

        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF253B22),
        ),
      ),
    );
  }

  // ===============================================================
  // PASSWORD FIELD
  // ===============================================================

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onVisibilityTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ===========================================================
        // LABEL
        // ===========================================================

        Text(
          label,

          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171310),
          ),
        ),

        const SizedBox(height: 6),

        // ===========================================================
        // INPUT
        // ===========================================================

        Container(
          height: 56,

          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF9),

            borderRadius: BorderRadius.circular(15),

            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),

          child: Row(
            children: [
              // =====================================================
              // LOCK ICON
              // =====================================================

              const SizedBox(width: 18),

              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Color(0xFF171310),
              ),

              const SizedBox(width: 20),

              // =====================================================
              // TEXT FIELD
              // =====================================================

              Expanded(
                child: TextField(
                  controller: controller,

                  obscureText: obscureText,

                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF30221E),
                  ),

                  cursorColor: primaryBrown,

                  decoration: InputDecoration(
                    hintText: hint,

                    hintStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A7B75),
                    ),

                    border: InputBorder.none,

                    isCollapsed: true,
                  ),
                ),
              ),

              // =====================================================
              // VISIBILITY BUTTON
              // =====================================================

              GestureDetector(
                onTap: onVisibilityTap,

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                  ),

                  child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,

                    size: 19,

                    color: const Color(0xFF171310),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SAVE BUTTON
  // ===============================================================

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _changePassword,

      child: Container(
        width: double.infinity,

        height: 50,

        decoration: BoxDecoration(
          color: primaryBrown,

          borderRadius: BorderRadius.circular(28),

          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Simpan Kata Sandi',

                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ===============================================================
  // CANCEL BUTTON
  // ===============================================================

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },

      child: Container(
        width: double.infinity,

        height: 50,

        decoration: BoxDecoration(
          color: const Color(0xFFFFE6D5),

          borderRadius: BorderRadius.circular(28),

          boxShadow: const [
            BoxShadow(
              color: Color(0x35000000),
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: const Center(
          child: Text(
            'Batal',

            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB3543A),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CHANGE PASSWORD
  // ===============================================================

  Future<void> _changePassword() async {
    final currentPassword =
        _currentPasswordController.text.trim();

    final newPassword =
        _newPasswordController.text.trim();

    final confirmPassword =
        _confirmPasswordController.text.trim();

    // =============================================================
    // VALIDASI KOSONG
    // =============================================================

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        'Semua kolom kata sandi wajib diisi.',
      );
      return;
    }

    // =============================================================
    // VALIDASI PASSWORD BARU
    // =============================================================

    if (newPassword.length < 8) {
      _showMessage(
        'Kata sandi baru minimal 8 karakter.',
      );
      return;
    }

    // =============================================================
    // VALIDASI PASSWORD SAMA
    // =============================================================

    if (newPassword != confirmPassword) {
      _showMessage(
        'Konfirmasi kata sandi tidak sama.',
      );
      return;
    }

    // =============================================================
    // CEK USER LOGIN
    // =============================================================

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
      return;
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      _showMessage(
        'Email akun tidak ditemukan.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordChanged = false;
    });

    try {
      // ===========================================================
      // RE-AUTHENTICATION
      // Memastikan kata sandi lama benar
      // ===========================================================

      final credential =
          EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      // ===========================================================
      // UPDATE PASSWORD FIREBASE
      // ===========================================================

      await user.updatePassword(
        newPassword,
      );

      // ===========================================================
      // BERHASIL
      // ===========================================================

      if (!mounted) return;

      setState(() {
        _passwordChanged = true;
      });

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kata sandi berhasil diperbarui di Firebase.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message =
              'Kata sandi saat ini salah.';
          break;

        case 'requires-recent-login':
          message =
              'Sesi login sudah terlalu lama. Silakan login kembali.';
          break;

        case 'weak-password':
          message =
              'Kata sandi baru terlalu lemah.';
          break;

        case 'user-disabled':
          message =
              'Akun ini sedang dinonaktifkan.';
          break;

        case 'network-request-failed':
          message =
              'Tidak dapat terhubung ke internet.';
          break;

        default:
          message =
              'Gagal mengubah kata sandi. Silakan coba lagi.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Nunito',
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}