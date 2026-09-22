import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import '../services/google_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // REGISTER EMAIL + PASSWORD
  // ===============================================================

  Future<void> _register() async {
    if (isLoading) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(
        'Nama, email, dan kata sandi wajib diisi.',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Kata sandi minimal 6 karakter.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('User gagal dibuat.');
      }

      await user.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Pendaftaran gagal.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email tersebut sudah terdaftar.';
          break;

        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;

        case 'weak-password':
          message = 'Kata sandi terlalu lemah.';
          break;

        case 'operation-not-allowed':
          message =
              'Pendaftaran Email/Password belum diaktifkan di Firebase.';
          break;

        case 'network-request-failed':
          message =
              'Tidak ada koneksi internet. Coba lagi.';
          break;
      }

      _showMessage(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        'Data gagal disimpan ke Firebase: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // REGISTER / LOGIN GOOGLE
  // ===============================================================

  Future<void> _registerWithGoogle() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
          await GoogleAuthService.signInWithGoogle();

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Akun Google gagal dibuat.',
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Google gagal masuk.';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'Email Google ini sudah terdaftar dengan metode login lain.';
          break;

        case 'network-request-failed':
          message =
              'Tidak ada koneksi internet. Coba lagi.';
          break;

        case 'user-disabled':
          message =
              'Akun ini telah dinonaktifkan.';
          break;

        case 'invalid-credential':
          message =
              'Kredensial Google tidak valid. Silakan coba lagi.';
          break;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Google gagal masuk: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // PESAN
  // ===============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.09,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.035,
                ),

                // =====================================================
                // LOGO
                // =====================================================

                Image.asset(
                  'assets/images/logo_utama_stomachy.png',
                  width: size.width * 0.48,
                  height: size.height * 0.19,
                  fit: BoxFit.contain,
                ),

                // =====================================================
                // PESAN
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.025,
                    vertical: size.height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6D5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: size.width * 0.04,
                        color: const Color(0xFFFF7775),
                      ),
                      SizedBox(
                        width: size.width * 0.02,
                      ),
                      Expanded(
                        child: Text(
                          'Yuk, mulai jaga kesehatan lambungmu bersama STOMACHY!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: size.width * 0.021,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF493C37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.025,
                ),

                // =====================================================
                // REGISTER CARD
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    size.height * 0.032,
                    size.width * 0.05,
                    size.height * 0.022,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 5,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // =================================================
                      // JUDUL
                      // =================================================

                      Text(
                        'Selamat Datang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: size.width * 0.048,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF171310),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.004,
                      ),

                      Text(
                        'Buat akun baru untuk memulai STOMACHY!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: size.width * 0.023,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // NAMA
                      // =================================================

                      _buildTextField(
                        controller: nameController,
                        hintText: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        width: size.width,
                        keyboardType: TextInputType.name,
                      ),

                      SizedBox(
                        height: size.height * 0.012,
                      ),

                      // =================================================
                      // EMAIL
                      // =================================================

                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        icon: Icons.email_outlined,
                        width: size.width,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(
                        height: size.height * 0.012,
                      ),

                      // =================================================
                      // PASSWORD
                      // =================================================

                      _buildPasswordField(size),

                      SizedBox(
                        height: size.height * 0.020,
                      ),

                      // =================================================
                      // BUTTON DAFTAR
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.045,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFB7D1B0),
                            disabledBackgroundColor:
                                const Color(0xFFD5DFD2),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize:
                                        size.width * 0.030,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.025,
                      ),

                      // =================================================
                      // DIVIDER
                      // =================================================

                      _buildDividerText(size),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // GOOGLE
                      // =================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            icon: Icons.g_mobiledata,
                            onPressed: isLoading
                                ? null
                                : _registerWithGoogle,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // SUDAH PUNYA AKUN
                      // =================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: size.width * 0.021,
                              color: Colors.grey[700],
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              'Masuk sekarang',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize:
                                    size.width * 0.021,
                                fontWeight: FontWeight.w700,
                                color:
                                    const Color(0xFFC5674E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.035,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TEXT FIELD
  // ===============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double width,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: width * 0.022,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: width * 0.022,
          color: Colors.black54,
        ),
        prefixIcon: Icon(
          icon,
          size: width * 0.04,
          color: const Color(0xFF765B4A),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PASSWORD FIELD
  // ===============================================================

  Widget _buildPasswordField(Size size) {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!isLoading) {
          _register();
        }
      },
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: size.width * 0.022,
      ),
      decoration: InputDecoration(
        hintText: 'Kata Sandi',
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.022,
          color: Colors.black54,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          size: size.width * 0.04,
          color: const Color(0xFF765B4A),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: size.width * 0.035,
            color: const Color(0xFF8B817C),
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DIVIDER
  // ===============================================================

  Widget _buildDividerText(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            color: const Color(0xFFD4D0CC),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'atau daftar dengan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.021,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            color: const Color(0xFFD4D0CC),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SOCIAL BUTTON
  // ===============================================================

  Widget _socialButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 42,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF8F4),
          disabledBackgroundColor:
              const Color(0xFFF0EAE6),
          foregroundColor: const Color(0xFFB85E47),
          disabledForegroundColor:
              const Color(0xFFB8AAA3),
          elevation: 1,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Icon(
          icon,
          size: 25,
        ),
      ),
    );
  }
}