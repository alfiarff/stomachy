import 'package:flutter/material.dart';

import 'login_screen.dart';

class PasswordSuccessScreen
    extends StatelessWidget {
  const PasswordSuccessScreen({
    super.key,
  });

  // ===============================================================
  // KEMBALI KE LOGIN
  // ===============================================================

  void _backToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4EC),

      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal:
                size.width * 0.085,
          ),

          child: Column(
            children: [

              // ===================================================
              // KONTEN UTAMA
              // ===================================================

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      // =========================================
                      // GAMBAR / MASKOT BERHASIL
                      // =========================================

                      SizedBox(
                        width:
                            size.width * 0.65,
                        height:
                            size.width * 0.65,

                        child: Image.asset(
                          'assets/images/password_success.png',

                          fit: BoxFit.contain,

                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              decoration:
                                  const BoxDecoration(
                                shape:
                                    BoxShape.circle,
                                color:
                                    Color(
                                  0xFFFFDCD0,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 150,
                                color:
                                    Color(
                                  0xFFB05039,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      // =========================================
                      // BERHASIL
                      // =========================================

                      Text(
                        'Berhasil!',

                        style: TextStyle(
                          fontFamily:
                              'Fredoka',
                          fontSize:
                              size.width *
                                  0.065,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              const Color(
                            0xFFB05039,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      // =========================================
                      // DESKRIPSI
                      // =========================================

                      Text(
                        'Kata sandi anda telah berhasil\n'
                        'diperbarui.',

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize:
                              size.width *
                                  0.037,
                          height: 1.35,
                          color:
                              const Color(
                            0xFF5E5753,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===================================================
              // BUTTON KEMBALI KE LOGIN
              // ===================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    _backToLogin(
                      context,
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFB05039,
                    ),

                    foregroundColor:
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
                    'Kembali ke Login',

                    style: TextStyle(
                      fontFamily:
                          'Nunito',
                      fontSize:
                          size.width * 0.040,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height:
                    size.height * 0.055,
              ),
            ],
          ),
        ),
      ),
    );
  }
}