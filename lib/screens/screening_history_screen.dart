import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'screening_result_screen.dart';
import '../widgets/bottom_navigation.dart';

class ScreeningHistoryScreen extends StatefulWidget {
  const ScreeningHistoryScreen({super.key});

  @override
  State<ScreeningHistoryScreen> createState() =>
      _ScreeningHistoryScreenState();
}

class _ScreeningHistoryScreenState extends State<ScreeningHistoryScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreeningScreen()),
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 105),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (user == null)
                _buildEmptyHistory('Silakan login terlebih dahulu.')
              else
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('screening_history')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(
                          color: Color(0xFFB9543A),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildEmptyHistory(
                        'Belum ada riwayat skrining.',
                      );
                    }

                    final documents = snapshot.data?.docs ?? [];

                    if (documents.isEmpty) {
                      return _buildEmptyHistory(
                        'Belum ada riwayat skrining.',
                      );
                    }

                    return Column(
                      children: [
                        for (int i = 0; i < documents.length; i++) ...[
                          _buildHistoryCardFromFirestore(documents[i]),
                          if (i != documents.length - 1)
                            const SizedBox(height: 17),
                        ],
                      ],
                    );
                  },
                ),
              const SizedBox(height: 28),
              _buildPrivacyCard(),
              const SizedBox(height: 27),
              _buildConsultationButton(),
              const SizedBox(height: 20),
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

  Widget _buildEmptyHistory(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history_rounded,
            size: 45,
            color: Color(0xFFB9543A),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Color(0xFF493C37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCardFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final String date = _formatDate(
      data['createdAt'],
      data['date'],
    );

    final bool isRisk = data['isRisk'] == true;

    final String status =
        isRisk ? 'Berisiko GERD' : 'Tidak Berisiko GERD';

    final String age =
        data['age']?.toString().isNotEmpty == true
            ? data['age'].toString()
            : '-';

    final String gender =
        data['gender']?.toString().isNotEmpty == true
            ? data['gender'].toString()
            : '-';

    final String symptom =
        data['symptom']?.toString().isNotEmpty == true
            ? data['symptom'].toString()
            : '0 Gejala utama';

    final String complaint =
        data['complaint']?.toString().isNotEmpty == true
            ? data['complaint'].toString()
            : '';

    final double probability =
        data['probability'] is num
            ? (data['probability'] as num).toDouble()
            : 0.0;

    final String? prediction =
        data['prediction']?.toString().isNotEmpty == true
            ? data['prediction'].toString()
            : null;

    final String image = isRisk
        ? 'assets/images/riwayat_berisiko_gerd.png'
        : 'assets/images/riwayat_tidak_berisiko_gerd.png';

    return _buildHistoryCard(
      date: date,
      status: status,
      complaint: complaint,
      age: age,
      gender: gender,
      symptom: symptom,
      image: image,
      isRisk: isRisk,
      probability: probability,
      prediction: prediction,
      step2Answers: _convertStep2Answers(data['step2Answers']),
      step3Answers: _convertStep3Answers(data['step3Answers']),
    );
  }

  String _formatDate(dynamic createdAt, dynamic oldDate) {
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      final day = date.day.toString().padLeft(2, '0');
      final month = _monthName(date.month);
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day $month $year - $hour:$minute';
    }

    if (oldDate != null && oldDate.toString().isNotEmpty) {
      return oldDate.toString();
    }

    return '-';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month];
  }

  Map<String, bool?> _convertStep2Answers(dynamic value) {
    final result = <String, bool?>{};

    if (value is Map) {
      value.forEach((key, answer) {
        if (answer is bool) {
          result[key.toString()] = answer;
        }
      });
    }

    return result;
  }

  Map<String, String?> _convertStep3Answers(dynamic value) {
    final result = <String, String?>{};

    if (value is Map) {
      value.forEach((key, answer) {
        if (answer != null) {
          result[key.toString()] = answer.toString();
        }
      });
    }

    return result;
  }

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
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Riwayat Skrining',
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

  Widget _buildHistoryCard({
    required String date,
    required String status,
    required String complaint,
    required String age,
    required String gender,
    required String symptom,
    required String image,
    required bool isRisk,
    required double probability,
    required String? prediction,
    required Map<String, bool?> step2Answers,
    required Map<String, String?> step3Answers,
  }) {
    final Color cardColor = isRisk
        ? const Color(0xFFFFFCF9)
        : const Color(0xFFF4FBF4);

    final Color statusColor = isRisk
        ? const Color(0xFFE93636)
        : const Color(0xFF18865A);

    final Color chipColor = isRisk
        ? const Color(0xFFFFF0E9)
        : const Color(0xFFCDEFD9);

    final Color chipBorder = isRisk
        ? const Color(0xFFE66A4F)
        : const Color(0xFF4AA978);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreeningResultScreen(
              date: date,
              status: status,
              complaint: complaint,
              age: age,
              gender: gender,
              symptom: symptom,
              image: image,
              isRisk: isRisk,
              probability: probability,
              prediction: prediction,
              step2Answers: step2Answers,
              step3Answers: step3Answers,
              saveToHistory: false,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 3,
              top: 0,
              child: SizedBox(
                width: 125,
                height: 98,
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFFB9543A),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 128,
              right: 35,
              top: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF77716E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 15,
              top: 43,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Color(0xFF171310),
              ),
            ),
            Positioned(
              left: 14,
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.person_rounded,
                      text: age,
                      backgroundColor: chipColor,
                      borderColor: chipBorder,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoChip(
                      icon: gender == 'Perempuan'
                          ? Icons.female_rounded
                          : Icons.male_rounded,
                      text: gender,
                      backgroundColor: chipColor,
                      borderColor: chipBorder,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 13,
            color: borderColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(12),
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
          const Icon(
            Icons.lock_rounded,
            size: 18,
            color: Color(0xFFB9543A),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Riwayatmu bersifat rahasia dan hanya dapat dilihat olehmu.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF493C37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB9543A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Konsultasi ke Dokter',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
