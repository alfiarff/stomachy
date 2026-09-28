import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'doctor/doctorr_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ===============================================================
  // STATE
  // ===============================================================

  bool obscurePassword = true;
  bool isLoading = false;

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // LOGIN FIREBASE
  // ===============================================================

  Future<void> _login() async {
    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    // =============================================================
    // VALIDASI
    // =============================================================

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Email dan kata sandi wajib diisi.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ===========================================================
      // LOGIN FIREBASE AUTHENTICATION
      // ===========================================================

      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Data pengguna tidak ditemukan.',
        );
      }

      // ===========================================================
      // AMBIL DATA USER DARI FIRESTORE
      // ===========================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // ===========================================================
      // CEK DATA USER
      // ===========================================================

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _showMessage(
          'Data akun belum terdaftar di sistem.',
        );

        return;
      }

      final data = userDoc.data();

      // ===========================================================
      // AMBIL ROLE
      // ===========================================================

      final String role =
          data?['role']?.toString().trim().toLowerCase() ?? '';

      // DEBUG
      debugPrint('================================');
      debugPrint('LOGIN BERHASIL');
      debugPrint('UID   : ${user.uid}');
      debugPrint('EMAIL : ${user.email}');
      debugPrint('ROLE  : $role');
      debugPrint('================================');

      if (!mounted) return;

      // ===========================================================
      // ARAHKAN SESUAI ROLE
      // ===========================================================

      await _navigateByRole(role);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Login gagal.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;

        case 'user-not-found':
          message =
              'Akun dengan email tersebut tidak ditemukan.';
          break;

        case 'wrong-password':
          message = 'Kata sandi salah.';
          break;

        case 'invalid-credential':
          message =
              'Email atau kata sandi salah.';
          break;

        case 'user-disabled':
          message =
              'Akun ini telah dinonaktifkan.';
          break;

        case 'too-many-requests':
          message =
              'Terlalu banyak percobaan login. Coba lagi nanti.';
          break;

        case 'network-request-failed':
          message =
              'Tidak ada koneksi internet. Coba lagi.';
          break;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'ERROR LOGIN: $e',
      );

      _showMessage(
        'Terjadi kesalahan. Silakan coba lagi.',
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
  // NAVIGASI BERDASARKAN ROLE
  // ===============================================================

  Future<void> _navigateByRole(String role) async {
    if (!mounted) return;

    // =============================================================
    // ROLE DOKTER
    // =============================================================

    if (role == 'doctor' ||
        role == 'dokter') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorHomeScreen(),
        ),
        (route) => false,
      );

      return;
    }

    // =============================================================
    // ROLE USER
    // =============================================================

    if (role == 'user' ||
        role == 'pengguna' ||
        role.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
        ),
        (route) => false,
      );

      return;
    }

    // =============================================================
    // ROLE TIDAK DIKENAL
    // =============================================================

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    _showMessage(
      'Role akun tidak dikenali. Hubungi administrator.',
    );
  }

  // ===============================================================
  // LOGIN GOOGLE
  // ===============================================================

  Future<void> _loginWithGoogle() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // ===========================================================
      // LOGIN GOOGLE
      // ===========================================================

      final credential =
          await GoogleAuthService.signInWithGoogle();

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Akun Google tidak ditemukan.',
        );
      }

      // ===========================================================
      // AMBIL DATA USER DULU
      // ===========================================================

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final existingDoc =
          await userRef.get();

      // ===========================================================
      // CEK ROLE YANG SUDAH ADA
      // ===========================================================

      String role = '';

      if (existingDoc.exists) {
        final existingData =
            existingDoc.data();

        role = existingData?['role']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';
      }

      // ===========================================================
      // SIMPAN DATA GOOGLE
      //
      // PENTING:
      // role TIDAK DITIMPA.
      // ===========================================================

      await userRef.set(
        {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        },
        SetOptions(
          merge: true,
        ),
      );

      // ===========================================================
      // DEBUG
      // ===========================================================

      debugPrint('================================');
      debugPrint('GOOGLE LOGIN BERHASIL');
      debugPrint('UID   : ${user.uid}');
      debugPrint('EMAIL : ${user.email}');
      debugPrint('ROLE  : $role');
      debugPrint('================================');

      if (!mounted) return;

      // ===========================================================
      // ARAHKAN SESUAI ROLE
      // ===========================================================

      await _navigateByRole(role);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          'Google gagal masuk.';

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

      debugPrint(
        'ERROR GOOGLE LOGIN: $e',
      );

      _showMessage(
        'Google gagal masuk. Silakan coba lagi.',
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
          physics:
              const BouncingScrollPhysics(),

          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  size.width * 0.09,
            ),

            child: Column(
              children: [
                // =================================================
                // JARAK ATAS
                // =================================================

                SizedBox(
                  height:
                      size.height * 0.035,
                ),

                // =================================================
                // LOGO
                // =================================================

                Image.asset(
                  'assets/images/logo_utama_stomachy.png',
                  width:
                      size.width * 0.48,
                  height:
                      size.height * 0.19,
                  fit: BoxFit.contain,
                ),

                // =================================================
                // PESAN
                // =================================================

                Container(
                  width: double.infinity,

                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        size.width * 0.025,
                    vertical:
                        size.height * 0.012,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFFFE6D5),

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color(0x22000000),
                        blurRadius: 3,
                        offset:
                            Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .verified_user_outlined,
                        size:
                            size.width *
                                0.04,
                        color:
                            const Color(
                          0xFFFF7775,
                        ),
                      ),

                      SizedBox(
                        width:
                            size.width *
                                0.02,
                      ),

                      Expanded(
                        child: Text(
                          'Yuk, mulai jaga kesehatan lambungmu bersama STOMACHY!',

                          style:
                              TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize:
                                size.width *
                                    0.021,
                            fontWeight:
                                FontWeight.w500,
                            color:
                                const Color(
                              0xFF493C37,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // JARAK
                // =================================================

                SizedBox(
                  height:
                      size.height * 0.025,
                ),

                // =================================================
                // LOGIN CARD
                // =================================================

                Container(
                  width: double.infinity,

                  padding:
                      EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    size.height * 0.032,
                    size.width * 0.05,
                    size.height * 0.022,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFFFFCF9),

                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color(0x33000000),
                        blurRadius: 5,
                        offset:
                            Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // =========================================
                      // JUDUL
                      // =========================================

                      Text(
                        'Selamat Datang Kembali!',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize:
                              size.width *
                                  0.045,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color(
                            0xFF171310,
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.004,
                      ),

                      // =========================================
                      // SUBTITLE
                      // =========================================

                      Text(
                        'Masuk untuk melanjutkan ke STOMACHY!',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize:
                              size.width *
                                  0.023,
                          color:
                              Colors.grey[600],
                        ),
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.018,
                      ),

                      // =========================================
                      // EMAIL
                      // =========================================

                      _buildTextField(
                        controller:
                            emailController,
                        hintText:
                            'Email',
                        icon:
                            Icons
                                .email_outlined,
                        width:
                            size.width,
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.012,
                      ),

                      // =========================================
                      // PASSWORD
                      // =========================================

                      _buildPasswordField(
                        size,
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.008,
                      ),

                      // =========================================
                      // LUPA PASSWORD
                      // =========================================

                      Align(
                        alignment:
                            Alignment
                                .centerRight,

                        child:
                            GestureDetector(
                          onTap:
                              isLoading
                                  ? null
                                  : () {
                                      Navigator
                                          .push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },

                          child: Text(
                            'Lupa Kata Sandi?',

                            style:
                                TextStyle(
                              fontFamily:
                                  'Nunito',
                              fontSize:
                                  size.width *
                                      0.021,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  const Color(
                                0xFFC5674E,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.018,
                      ),

                      // =========================================
                      // BUTTON MASUK
                      // =========================================

                      SizedBox(
                        width:
                            double.infinity,
                        height:
                            size.height *
                                0.045,

                        child:
                            ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : _login,

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFB7D1B0,
                            ),

                            disabledBackgroundColor:
                                const Color(
                              0xFFD5DFD2,
                            ),

                            foregroundColor:
                                Colors.black,

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),
                          ),

                          child:
                              isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',

                                      style:
                                          TextStyle(
                                        fontFamily:
                                            'Nunito',
                                        fontSize:
                                            size.width *
                                                0.030,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                        ),
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.025,
                      ),

                      // =========================================
                      // DIVIDER
                      // =========================================

                      _buildDividerText(
                        size,
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.018,
                      ),

                      // =========================================
                      // GOOGLE
                      // =========================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          _socialButton(
                            icon: Icons
                                .g_mobiledata,

                            onPressed:
                                isLoading
                                    ? null
                                    : _loginWithGoogle,
                          ),
                        ],
                      ),

                      SizedBox(
                        height:
                            size.height *
                                0.018,
                      ),

                      // =========================================
                      // DAFTAR
                      // =========================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            'Belum punya akun? ',

                            style:
                                TextStyle(
                              fontFamily:
                                  'Nunito',
                              fontSize:
                                  size.width *
                                      0.021,
                              color:
                                  Colors.grey[700],
                            ),
                          ),

                          GestureDetector(
                            onTap:
                                isLoading
                                    ? null
                                    : () {
                                        Navigator
                                            .push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const RegisterScreen(),
                                          ),
                                        );
                                      },

                            child: Text(
                              'Daftar sekarang',

                              style:
                                  TextStyle(
                                fontFamily:
                                    'Nunito',
                                fontSize:
                                    size.width *
                                        0.021,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    const Color(
                                  0xFFC5674E,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =================================================
                // JARAK BAWAH
                // =================================================

                SizedBox(
                  height:
                      size.height * 0.035,
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
  }) {
    return TextField(
      controller: controller,

      keyboardType:
          TextInputType.emailAddress,

      textInputAction:
          TextInputAction.next,

      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize:
            width * 0.022,
      ),

      decoration:
          InputDecoration(
        hintText: hintText,

        hintStyle:
            TextStyle(
          fontFamily: 'Nunito',
          fontSize:
              width * 0.022,
          color:
              Colors.black54,
        ),

        prefixIcon:
            Icon(
          icon,
          size:
              width * 0.04,
          color:
              const Color(
            0xFF765B4A,
          ),
        ),

        contentPadding:
            const EdgeInsets
                .symmetric(
          vertical: 10,
          horizontal: 8,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PASSWORD FIELD
  // ===============================================================

  Widget _buildPasswordField(
    Size size,
  ) {
    return TextField(
      controller:
          passwordController,

      obscureText:
          obscurePassword,

      textInputAction:
          TextInputAction.done,

      onSubmitted: (_) {
        if (!isLoading) {
          _login();
        }
      },

      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize:
            size.width * 0.022,
      ),

      decoration:
          InputDecoration(
        hintText:
            'Kata Sandi',

        hintStyle:
            TextStyle(
          fontFamily: 'Nunito',
          fontSize:
              size.width * 0.022,
          color:
              Colors.black54,
        ),

        prefixIcon:
            Icon(
          Icons.lock_outline,
          size:
              size.width * 0.04,
          color:
              const Color(
            0xFF765B4A,
          ),
        ),

        suffixIcon:
            IconButton(
          icon:
              Icon(
            obscurePassword
                ? Icons
                    .visibility_off_outlined
                : Icons
                    .visibility_outlined,

            size:
                size.width * 0.035,

            color:
                const Color(
              0xFF8B817C,
            ),
          ),

          onPressed: () {
            setState(() {
              obscurePassword =
                  !obscurePassword;
            });
          },
        ),

        contentPadding:
            const EdgeInsets
                .symmetric(
          vertical: 10,
          horizontal: 8,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DIVIDER
  // ===============================================================

  Widget _buildDividerText(
    Size size,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              Container(
            height: 0.5,
            color:
                const Color(
              0xFFD4D0CC,
            ),
          ),
        ),

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 10,
          ),

          child: Text(
            'atau masuk dengan',

            style:
                TextStyle(
              fontFamily:
                  'Nunito',
              fontSize:
                  size.width *
                      0.021,
              color:
                  Colors.grey[600],
            ),
          ),
        ),

        Expanded(
          child:
              Container(
            height: 0.5,
            color:
                const Color(
              0xFFD4D0CC,
            ),
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

      child:
          ElevatedButton(
        onPressed:
            onPressed,

        style:
            ElevatedButton
                .styleFrom(
          backgroundColor:
              const Color(
            0xFFFFF8F4,
          ),

          disabledBackgroundColor:
              const Color(
            0xFFF0EAE6,
          ),

          foregroundColor:
              const Color(
            0xFFB85E47,
          ),

          disabledForegroundColor:
              const Color(
            0xFFB8AAA3,
          ),

          elevation: 1,

          padding:
              EdgeInsets.zero,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
        ),

        child:
            Icon(
          icon,
          size: 25,
        ),
      ),
    );
  }
}