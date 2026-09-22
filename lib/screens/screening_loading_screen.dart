import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'screening_result_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ScreeningLoadingScreen extends StatefulWidget {
  final String age;
  final String gender;

  final Map<String, bool?> step2Answers;
  final Map<String, String?> step3Answers;

  const ScreeningLoadingScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.step2Answers,
    required this.step3Answers,
  });

  @override
  State<ScreeningLoadingScreen> createState() =>
      _ScreeningLoadingScreenState();
}

class _ScreeningLoadingScreenState
    extends State<ScreeningLoadingScreen> {
  // ===============================================================
  // VARIABLE
  // ===============================================================

  double progress = 0.0;

  Timer? timer;

  // Index bottom navigation
  int _selectedIndex = 1;

  // ===============================================================
  // COLOR
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF5ED);

  final Color brown =
      const Color(0xFFB05039);

  // ===============================================================
  // INIT STATE
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _startAnalysis();
  }

  // ===============================================================
  // START ANALYSIS
  // ===============================================================

  void _startAnalysis() {
    const totalDuration =
        Duration(seconds: 4);

    int elapsed = 0;

    const interval = 100;

    timer = Timer.periodic(
      const Duration(
        milliseconds: interval,
      ),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        elapsed += interval;

        setState(() {
          progress =
              elapsed /
              totalDuration.inMilliseconds;

          // Supaya tidak lebih dari 100%
          if (progress > 1.0) {
            progress = 1.0;
          }
        });

        // =========================================================
        // SELESAI LOADING
        // =========================================================

        if (progress >= 1.0) {
          timer.cancel();

          Future.delayed(
            const Duration(
              milliseconds: 300,
            ),
            () {
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScreeningResultScreen(
                    age: widget.age,
                    gender: widget.gender,
                    step2Answers:
                        widget.step2Answers,
                    step3Answers:
                        widget.step3Answers,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    // =============================================================
    // BERANDA
    // =============================================================

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
        ),
      );

      return;
    }

    // =============================================================
    // SKRINING
    // =============================================================

    if (index == 1) {
      // Karena sedang berada di bagian Skrining,
      // tidak perlu pindah halaman.
      return;
    }

    // =============================================================
    // DOKTER
    // =============================================================

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorScreen(),
        ),
      );

      return;
    }

    // =============================================================
    // EDUKASI
    // =============================================================

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const EdukasiScreen(),
        ),
      );

      return;
    }

    // =============================================================
    // PROFIL
    // =============================================================

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ProfileScreen(),
        ),
      );

      return;
    }
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final int percentage =
        (progress * 100).round();

    return Scaffold(
      backgroundColor: backgroundColor,

      // =============================================================
      // BODY
      // =============================================================

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // =======================================================
            // HEADER
            // =======================================================

            const SizedBox(
              height: 45,
              child: Center(
                child: Text(
                  'Skrining',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // =======================================================
            // CONTENT
            // =======================================================

            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 19,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 550,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 28,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFFFFCF9),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color:
                            const Color(
                          0xFFFF775C,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.12),
                          blurRadius: 4,
                          offset:
                              const Offset(0, 3),
                        ),
                      ],
                    ),

                    // =================================================
                    // CARD CONTENT
                    // =================================================

                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),

                        // =============================================
                        // MASCOT
                        // =============================================

                        Expanded(
                          flex: 4,
                          child: Image.asset(
                            'assets/images/maskot_loading.png',
                            fit: BoxFit.contain,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .psychology_rounded,
                                size: 130,
                                color:
                                    Color(
                                  0xFFB05039,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        // =============================================
                        // TITLE
                        // =============================================

                        const Text(
                          'AI sedang menganalisis\n'
                          'jawabanmu...',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontFamily:
                                'Fredoka',
                            fontSize: 22,
                            height: 1.25,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // =============================================
                        // DESCRIPTION
                        // =============================================

                        const Text(
                          'Mohon tunggu beberapa saat.\n'
                          'Hasil akan segera ditampilkan.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // =============================================
                        // PROGRESS
                        // =============================================

                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                child:
                                    LinearProgressIndicator(
                                  value:
                                      progress,
                                  minHeight:
                                      15,
                                  backgroundColor:
                                      const Color(
                                    0xFFF1E1D8,
                                  ),
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    brown,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 7,
                            ),

                            Text(
                              '$percentage%',
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 35,
                        ),

                        // =============================================
                        // TAHUKAH KAMU
                        // =============================================

                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFFEBDD,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.12,
                                ),
                                blurRadius: 3,
                                offset:
                                    const Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // =======================================
                              // ICON TIPS
                              // =======================================

                              Image.asset(
                                'assets/images/ikon_tips.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit
                                    .contain,
                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Icon(
                                    Icons
                                        .lightbulb,
                                    size: 45,
                                    color:
                                        Colors
                                            .orange,
                                  );
                                },
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              // =======================================
                              // TEXT
                              // =======================================

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Tahukah kamu?',
                                      style:
                                          TextStyle(
                                        fontFamily:
                                            'Nunito',
                                        fontSize:
                                            14,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Menjaga pola hidup sehat dapat membantu\n'
                                      'mengurangi risiko GERD.',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            10,
                                        height:
                                            1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // =============================================================
      // BOTTOM NAVIGATION
      // =============================================================

      bottomNavigationBar:
          AppBottomNavigation(
        selectedIndex: _selectedIndex,

        // INI YANG SEBELUMNYA KOSONG
        onItemSelected:
            _onNavigationTap,
      ),
    );
  }
}