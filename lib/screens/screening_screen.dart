import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'doctor_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart'; 
import 'screening_question_screen.dart'; 

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  int _selectedIndex = 1;

  final Color backgroundColor = const Color(0xFFFFF5ED);
  final Color brown = const Color(0xFFB05039);

  void _onNavigationTap(int index) {
    // Beranda
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // Skrining
    if (index == 1) {
      return;
    }

    // Dokter
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // Edukasi
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // Profil
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    8,
                    15,
                    20,
                  ),
                  child: Column(
                    children: [
                      // =====================================================
                      // HEADER
                      // =====================================================

                      SizedBox(
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
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

                            const Text(
                              'Skrining',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 130),

                      // =====================================================
                      // JUDUL
                      // =====================================================

                      const Text(
                        'Skrining GERD\nDengan AI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 45,
                          height: 1.3,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAC503A),
                        ),
                      ),

                      // JARAK DIKEMBALIKAN SEPERTI SEBELUMNYA
                      const SizedBox(height: 10),

                      const Text(
                        'Jawab beberapa pertanyaan berikut\n'
                        'untuk mengetahui kemungkinan kamu mengalami GERD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Color(0xFF332823),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =====================================================
                      // GAMBAR MASCOT DOKTER
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/images/maskot_dokter.png',
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // =====================================================
                      // KEUNGGULAN: MUDAH - CEPAT - RAHASIA
                      // =====================================================

                      Container(
                        width: double.infinity,
                        height: 82,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFCF9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFDDC8),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildBenefitItem(
                                icon: Icons.verified_rounded,
                                title: 'Mudah',
                              ),
                            ),
                            Expanded(
                              child: _buildBenefitItem(
                                icon: Icons.access_time_filled_rounded,
                                title: 'Cepat',
                              ),
                            ),
                            Expanded(
                              child: _buildBenefitItem(
                                icon: Icons.lock_rounded,
                                title: 'Rahasia',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 46),

                      // =====================================================
                      // BUTTON MULAI
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScreeningQuestionScreen(),
                                ),
                              );
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Mulai Sekarang',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // =====================================================
      // BOTTOM NAVIGATION
      // =====================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ================================================================
  // BENEFIT ITEM
  // ================================================================

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 25,
          color: const Color(0xFFB05039),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}