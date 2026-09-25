import 'package:flutter/material.dart';

import 'login_screen.dart';

class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  // ===============================================================
  // WARNA
  // ===============================================================

  static const Color backgroundColor =
      Color(0xFFFFF4EC);

  static const Color brown =
      Color(0xFFB05039);

  static const Color darkText =
      Color(0xFF493C37);

  // ===============================================================
  // KEMBALI KE LOGIN
  // ===============================================================

  void _backToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.085,
          ),

          child: Column(
            children: [
              // =====================================================
              // BACK BUTTON
              // =====================================================

              SizedBox(
                height: 70,

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: GestureDetector(
                    onTap: () {
                      _backToLogin(context);
                    },

                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // KONTEN
              // =====================================================

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // =================================================
                      // ICON EMAIL
                      // =================================================

                      Container(
                        width: 100,
                        height: 100,

                        decoration:
                            const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFE0D4),
                        ),

                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 55,
                          color: brown,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =================================================
                      // TITLE
                      // =================================================

                      Text(
                        'Cek Email Kamu',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize:
                              size.width * 0.060,
                          fontWeight:
                              FontWeight.bold,
                          color: brown,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =================================================
                      // DESCRIPTION
                      // =================================================

                      Text(
                        'Kami telah mengirimkan link '
                        'untuk mengatur ulang kata sandi '
                        'ke email:',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize:
                              size.width * 0.035,
                          height: 1.4,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =================================================
                      // EMAIL
                      // =================================================

                      Text(
                        email,

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize:
                              size.width * 0.037,
                          fontWeight:
                              FontWeight.w800,
                          color: brown,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // =================================================
                      // INSTRUCTION
                      // =================================================

                      Text(
                        'Silakan buka email tersebut dan '
                        'klik link reset password untuk '
                        'membuat kata sandi baru.',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize:
                              size.width * 0.034,
                          height: 1.4,
                          color:
                              const Color(
                            0xFF5E5753,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =================================================
                      // INFO
                      // =================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color:
                              const Color(
                            0xFFFFE9DC,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: brown,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Jika email belum terlihat, '
                                'coba periksa folder Spam atau '
                                'Promosi.',

                                style:
                                    const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  height: 1.4,
                                  color: darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =====================================================
              // KEMBALI
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {
                    _backToLogin(context);
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    foregroundColor: Colors.white,
                    elevation: 3,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: size.height * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }
}