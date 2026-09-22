import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'consultation_chat_screen.dart';
import '../widgets/bottom_navigation.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  State<ConsultationHistoryScreen> createState() =>
      _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState
    extends State<ConsultationHistoryScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color borderBrown = const Color(0xFFFF806A);

  // ===============================================================
  // DATA RIWAYAT CHAT
  // ===============================================================

  final List<ConsultationHistoryData> histories = [
    ConsultationHistoryData(
      doctorName: 'dr. Amanda Putri',
      specialty: 'Dokter Umum',
      date: '12 Agustus 2026',
      time: '10.00',
      doctorImage:
          'assets/images/dokter_amanda.jpeg',
    ),
    ConsultationHistoryData(
      doctorName: 'dr. Jefri Nichol',
      specialty: 'Dokter Umum',
      date: '5 Agustus 2026',
      time: '14.00',
      doctorImage:
          'assets/images/dokter_jefri.jpeg',
    ),
  ];

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            105,
          ),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              ...histories.map(
                (history) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 17,
                  ),
                  child: _buildConsultationCard(
                    history,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Riwayat Chat',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ===============================================================
  // CONSULTATION CARD
  // ===============================================================

  Widget _buildConsultationCard(
    ConsultationHistoryData history,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationChatScreen(
              doctorName: history.doctorName,
              specialty: history.specialty,
              doctorImage: history.doctorImage,
              selectedTime: history.time,
              rating: '4.9',
              reviews: '128',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderBrown,
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // FOTO DOKTER
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDE5DF),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                history.doctorImage,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: Color(0xFFB65339),
                  );
                },
              ),
            ),

            const SizedBox(width: 13),

            // DATA DOKTER
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    history.doctorName,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: primaryBrown,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    history.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${history.date} • ${history.time} WIB',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF77716E),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF3DD),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF188447),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// MODEL RIWAYAT KONSULTASI
// ===============================================================

class ConsultationHistoryData {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String doctorImage;

  ConsultationHistoryData({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.doctorImage,
  });
}