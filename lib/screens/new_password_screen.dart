import 'package:flutter/material.dart';

import 'password_success_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    super.key,
  });

  @override
  State<NewPasswordScreen> createState() =>
      _NewPasswordScreenState();
}

class _NewPasswordScreenState
    extends State<NewPasswordScreen> {
  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ===============================================================
  // PASSWORD VISIBILITY
  // ===============================================================

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF4EC);

  final Color brown =
      const Color(0xFFB05039);

  final Color borderColor =
      const Color(0xFFD99A86);

  final Color darkText =
      const Color(0xFF493C37);

  // ===============================================================
  // VALIDASI PASSWORD
  // ===============================================================

  bool get hasMinLength {
    return newPasswordController.text.length >= 8;
  }

  bool get hasUppercase {
    return RegExp(
      r'[A-Z]',
    ).hasMatch(
      newPasswordController.text,
    );
  }

  bool get hasLowercase {
    return RegExp(
      r'[a-z]',
    ).hasMatch(
      newPasswordController.text,
    );
  }

  bool get hasNumber {
    return RegExp(
      r'[0-9]',
    ).hasMatch(
      newPasswordController.text,
    );
  }

  bool get passwordIsValid {
    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber;
  }

  bool get passwordMatches {
    return newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text ==
            confirmPasswordController.text;
  }

  // ===============================================================
  // SEMUA VALID
  // ===============================================================

  bool get canSave {
    return passwordIsValid &&
        passwordMatches;
  }

  // ===============================================================
  // SIMPAN PASSWORD
  // ===============================================================

  void _savePassword() {
    if (!passwordIsValid) {
      _showMessage(
        'Password belum memenuhi semua ketentuan.',
      );
      return;
    }

    if (!passwordMatches) {
      _showMessage(
        'Konfirmasi kata sandi tidak sama.',
      );
      return;
    }

    // =============================================================
    // PINDAH KE HALAMAN BERHASIL
    // =============================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PasswordSuccessScreen(),
      ),
    );
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
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ===============================================================
  // PASSWORD FIELD
  // ===============================================================

  Widget _buildPasswordField({
    required Size size,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onVisibilityPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius:
            BorderRadius.circular(15),
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
        controller: controller,
        obscureText: obscureText,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.034,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: hintText,

          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: size.width * 0.032,
            color: const Color(0xFF99918E),
          ),

          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            size: size.width * 0.060,
            color: const Color(0xFFB56A56),
          ),

          suffixIcon: IconButton(
            onPressed: onVisibilityPressed,
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: size.width * 0.055,
              color:
                  const Color(0xFF9A7167),
            ),
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // VALIDATION ITEM
  // ===============================================================

  Widget _buildValidationItem({
    required String text,
    required bool valid,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF25D366),
            ),
            child: Icon(
              valid
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: darkText,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  size.width * 0.085,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ===================================================
                // BACK BUTTON
                // ===================================================

                SizedBox(
                  height: 75,

                  child: Align(
                    alignment:
                        Alignment.centerLeft,

                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 27,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // ===================================================
                // JUDUL
                // ===================================================

                Text(
                  'Buat Kata Sandi Baru',

                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize:
                        size.width * 0.060,
                    fontWeight:
                        FontWeight.bold,
                    color: brown,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                // ===================================================
                // SUBJUDUL
                // ===================================================

                Text(
                  'Masukkan kata sandi baru yang kuat dan\n'
                  'mudah anda ingat.',

                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize:
                        size.width * 0.035,
                    height: 1.35,
                    color:
                        const Color(
                      0xFF5E5753,
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      size.height * 0.035,
                ),

                // ===================================================
                // PASSWORD BARU
                // ===================================================

                _buildPasswordField(
                  size: size,
                  controller:
                      newPasswordController,
                  hintText:
                      'Kata sandi baru',
                  obscureText:
                      obscureNewPassword,
                  onVisibilityPressed:
                      () {
                    setState(() {
                      obscureNewPassword =
                          !obscureNewPassword;
                    });
                  },
                ),

                const SizedBox(
                  height: 25,
                ),

                // ===================================================
                // VALIDASI PASSWORD
                // ===================================================

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.fromLTRB(
                    17,
                    14,
                    17,
                    10,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFEBDD,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color(0x22000000),
                        blurRadius: 4,
                        offset:
                            Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      _buildValidationItem(
                        text:
                            'Minimal 8 karakter',
                        valid:
                            hasMinLength,
                      ),

                      _buildValidationItem(
                        text:
                            'Mengandung huruf besar',
                        valid:
                            hasUppercase,
                      ),

                      _buildValidationItem(
                        text:
                            'Mengandung huruf kecil',
                        valid:
                            hasLowercase,
                      ),

                      _buildValidationItem(
                        text:
                            'Mengandung angka',
                        valid:
                            hasNumber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ===================================================
                // KONFIRMASI PASSWORD
                // ===================================================

                _buildPasswordField(
                  size: size,
                  controller:
                      confirmPasswordController,
                  hintText:
                      'Kata sandi baru',
                  obscureText:
                      obscureConfirmPassword,
                  onVisibilityPressed:
                      () {
                    setState(() {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                ),

                const SizedBox(
                  height: 50,
                ),

                // ===================================================
                // BUTTON SIMPAN
                // ===================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                        canSave
                            ? _savePassword
                            : null,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          brown,

                      disabledBackgroundColor:
                          const Color(
                        0xFFD9B5A8,
                      ),

                      foregroundColor:
                          Colors.white,

                      disabledForegroundColor:
                          Colors.white,

                      elevation: 3,

                      shadowColor:
                          Colors.black
                              .withOpacity(
                        0.25,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),

                    child: Text(
                      'Simpan',

                      style: TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize:
                            size.width *
                                0.040,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      size.height * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}