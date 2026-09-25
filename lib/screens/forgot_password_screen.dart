import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'check_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController emailController =
      TextEditingController();

  // ===============================================================
  // STATE
  // ===============================================================

  bool _isLoading = false;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF4EC);

  final Color brown =
      const Color(0xFFB05039);

  final Color borderColor =
      const Color(0xFFFF7775);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ===============================================================
  // KIRIM LINK RESET PASSWORD
  // ===============================================================

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();

    // =============================================================
    // CEK KOSONG
    // =============================================================

    if (email.isEmpty) {
      _showMessage(
        'Silakan masukkan email terlebih dahulu.',
      );
      return;
    }

    // =============================================================
    // CEK FORMAT EMAIL
    // =============================================================

    if (!email.contains('@') ||
        !email.contains('.')) {
      _showMessage(
        'Silakan masukkan email yang valid.',
      );
      return;
    }

    // =============================================================
    // LOADING
    // =============================================================

    setState(() {
      _isLoading = true;
    });

    try {
      // ===========================================================
      // FIREBASE AUTHENTICATION
      // ===========================================================

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) {
        return;
      }

      // ===========================================================
      // PINDAH KE HALAMAN CEK EMAIL
      // ===========================================================

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckEmailScreen(
            email: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;

        case 'user-not-found':
          message =
              'Email tersebut belum terdaftar.';
          break;

        case 'too-many-requests':
          message =
              'Terlalu banyak permintaan. '
              'Silakan coba lagi nanti.';
          break;

        default:
          message =
              'Gagal mengirim link reset password. '
              'Silakan coba lagi.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) {
        return;
      }

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
  // SNACKBAR
  // ===============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: brown,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.085,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ===================================================
                // BACK BUTTON
                // ===================================================

                SizedBox(
                  height: 70,

                  child: Align(
                    alignment: Alignment.centerLeft,

                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 25,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // ===================================================
                // JUDUL
                // ===================================================

                Text(
                  'Lupa Kata Sandi?',

                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: size.width * 0.060,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                const SizedBox(height: 3),

                // ===================================================
                // SUB JUDUL
                // ===================================================

                Text(
                  'Masukkan email yang\n'
                  'terdaftar pada akun anda.',

                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: size.width * 0.035,
                    height: 1.35,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: size.height * 0.025,
                ),

                // ===================================================
                // EMAIL
                // ===================================================

                _buildInputField(size),

                SizedBox(
                  height: size.height * 0.040,
                ),

                // ===================================================
                // BUTTON
                // ===================================================

                SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _sendResetLink,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          brown.withOpacity(0.6),
                      elevation: 3,
                      shadowColor:
                          Colors.black.withOpacity(0.25),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Kirim Link Reset',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize:
                                  size.width * 0.035,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                SizedBox(
                  height: size.height * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // INPUT EMAIL
  // ===============================================================

  Widget _buildInputField(Size size) {
    return Container(
      width: double.infinity,
      height: 50,

      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: borderColor,
          width: 1,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: TextField(
        controller: emailController,

        keyboardType:
            TextInputType.emailAddress,

        textInputAction:
            TextInputAction.done,

        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.030,
          color: Colors.black,
        ),

        onSubmitted: (_) {
          if (!_isLoading) {
            _sendResetLink();
          }
        },

        decoration: InputDecoration(
          hintText: 'Email',

          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: size.width * 0.027,
            color: const Color(0xFF99918E),
          ),

          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            size: size.width * 0.060,
            color: brown,
          ),

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}