import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'profile_screen.dart';
import 'apa_itu_gerd_screen.dart';
import 'waktu_makan_screen.dart';
import 'pertolongan_saat_kambuh_screen.dart';
import 'mitos_fakta_screen.dart';
import 'gejala_tanda_bahaya_screen.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);
  final Color borderColor = const Color(0xFFFF806D);

  int _selectedIndex = 3;

  // ================================================================
  // NAVIGATION
  // ================================================================

  void _onNavigationTap(int index) {
    if (index == 3) {
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

    // PROFIL
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

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // HEADER
            // ========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'Edukasi GERD',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 42),
                ],
              ),
            ),

            // ========================================================
            // EDUCATION LIST
            // ========================================================

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  90,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // 1. APA ITU GERD
                    // ==================================================

                    _buildEducationCard(
                      image: 'assets/images/edukasi_apa_itu_gerd.png',
                      title: 'Apa Itu GERD?',
                      description:
                          'Kenali pengertian GERD, penyebab, dan\n'
                          'bagaimana prosesnya bisa terjadi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApaItuGerdScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // 2. GEJALA & TANDA BAHAYA
                    // ==================================================

                    _buildEducationCard(
                      image:
                          'assets/images/edukasi_gejala_red_flags.png',
                      title: 'Gejala & Tanda Bahaya (Red Flags)',
                      description:
                          'Kenali ciri khas gejala GERD dan tanda bahaya\n'
                          'kapan kamu harus segera ke dokter',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const GejalaTandaBahayaScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // 3. PERTOLONGAN PERTAMA
                    // ==================================================

                    _buildEducationCard(
                      image:
                          'assets/images/edukasi_pertolongan_pertama.png',
                      title: 'Pertolongan Pertama Saat Kambuh',
                      description:
                          'Langkah praktis dan cepat untuk meredakan\n'
                          'rasa tidak nyaman saat asam lambung naik',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PertolonganSaatKambuhScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // 4. MITOS VS FAKTA
                    // ==================================================

                    _buildEducationCard(
                      image: 'assets/images/edukasi_mitos_fakta.png',
                      title: 'Mitos vs. Fakta GERD',
                      description:
                          'Sering dengar anggapan seputar asam\n'
                          'lambung? Cek mana yang mitos dan fakta\n'
                          'medisnya',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MitosFaktaScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // 5. WAKTU MAKAN
                    // ==================================================

                    _buildEducationCard(
                      image: 'assets/images/edukasi_waktu_makan.png',
                      title:
                          'Waktu Makan yang Tepat untuk Penderita GERD',
                      description:
                          'Panduan mengatur waktu makan untuk penderita GERD.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WaktuMakanScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==============================================================
      // BOTTOM NAVIGATION
      // ==============================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ================================================================
  // EDUCATION CARD
  // ================================================================

  Widget _buildEducationCard({
    required String image,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 130,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.only(
                left: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9D9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ======================================================
            // TEXT
            // ======================================================

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      color: Color(0xFF39302C),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // ARROW
            // ======================================================

            const Padding(
              padding: EdgeInsets.only(
                left: 5,
                right: 14,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}