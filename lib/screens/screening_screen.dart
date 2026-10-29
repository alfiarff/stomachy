
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
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    if (index == 1) {
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EdukasiScreen()),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
            // HEADER
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
                      child: const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 25,
                          color: Colors.black,
                        ),
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

            // KONTEN UTAMA
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(19, 0, 19, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 102),

                    // JUDUL
                    const Text(
                      'Kenali Risiko',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 38,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAC503A),
                      ),
                    ),
                    const Text(
                      'GERD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 37,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAC503A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Jawab beberapa pertanyaan berikut\n'
                      'untuk mengetahui kemungkinan kamu mengalami GERD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF332823),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // CARD 1
                    _buildStepCard(
                      number: '1',
                      title: 'Jawab beberapa pertanyaan',
                      description: 'Isi sesuai kondisi anda',
                    ),

                    const SizedBox(height: 12),

                    // CARD 2
                    _buildStepCard(
                      number: '2',
                      title: 'Proses Cepat',
                      description: 'Proses skrining hanya sekitar 3 menit',
                    ),

                    const SizedBox(height: 12),

                    // CARD 3
                    _buildStepCard(
                      number: '3',
                      title: 'Dapatkan Hasil dan Rekomendasi',
                      description: 'Skor risiko dan rekomendasi',
                    ),

                    const SizedBox(height: 38),

                    // TOMBOL MULAI
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ScreeningQuestionScreen(),
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
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // CARD LANGKAH SKRINING
  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NOMOR
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: brown,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 30),

          // JUDUL DAN DESKRIPSI
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
