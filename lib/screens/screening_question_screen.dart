import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';

import 'screening/screening_data_diri.dart';
import 'screening/screening_kondisi.dart';
import 'screening/screening_gejala.dart';

import 'home_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'screening_loading_screen.dart';

class ScreeningQuestionScreen extends StatefulWidget {
  const ScreeningQuestionScreen({super.key});

  @override
  State<ScreeningQuestionScreen> createState() =>
      _ScreeningQuestionScreenState();
}

class _ScreeningQuestionScreenState
    extends State<ScreeningQuestionScreen> {

  // ============================================================
  // WARNA
  // ============================================================

  final Color backgroundColor = const Color(0xFFFFF5ED);
  final Color brown = const Color(0xFFB05039);
  final Color orangeLine = const Color(0xFFE07A61);
  final Color cardColor = const Color(0xFFFFFCF9);

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  int _selectedIndex = 1;

  // ============================================================
  // TAHAP SKRINING
  // ============================================================

  int currentStep = 1;

  // ============================================================
  // DATA LANGKAH 1
  // ============================================================

  String age = '';
  String? gender;

  // ============================================================
  // DATA LANGKAH 2
  // ============================================================

  final Map<String, bool?> step2Answers = {
    'Perut terasa penuh': null,
    'Waktu tidur': null,
    'Penggunaan obat': null,
    'Panas di dada': null,
    'Asam lambung naik': null,
    'Nyeri dada atau ulu hati': null,
  };

  // ============================================================
  // DATA LANGKAH 3
  // ============================================================

  final Map<String, String?> step3Answers = {
    'Panas di dada': null,
    'Asam lambung naik': null,
    'Nyeri dada atau ulu hati': null,
  };

  // ============================================================
  // ASSET GAMBAR
  // ============================================================

  final Map<String, String> symptomImages = {
    'Perut terasa penuh': 'assets/images/perut.png',
    'Waktu tidur': 'assets/images/bed.png',
    'Penggunaan obat': 'assets/images/obat.png',
    'Panas di dada': 'assets/images/api.png',
    'Asam lambung naik': 'assets/images/asam.png',
    'Nyeri dada atau ulu hati': 'assets/images/nyeri.png',
  };

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onNavigationTap(int index) {
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
      setState(() {
        _selectedIndex = 1;
      });
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

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
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

  // ============================================================
  // CEK DATA
  // ============================================================

  bool get step1Complete {
    return age.trim().isNotEmpty && gender != null;
  }

  bool get step2Complete {
    return step2Answers.values.every(
      (answer) => answer != null,
    );
  }

  bool get step3Complete {
    return step3Answers.values.every(
      (answer) => answer != null,
    );
  }

  // ============================================================
  // LANJUT KE LANGKAH BERIKUTNYA
  // ============================================================

  void _nextStep() {
    // LANGKAH 1 → LANGKAH 2
    if (currentStep == 1) {
      if (!step1Complete) {
        _showMessage(
          'Silakan isi usia dan pilih jenis kelamin terlebih dahulu.',
        );
        return;
      }

      setState(() {
        currentStep = 2;
      });

      return;
    }

    // LANGKAH 2 → LANGKAH 3
    if (currentStep == 2) {
      if (!step2Complete) {
        _showMessage(
          'Silakan jawab semua pertanyaan terlebih dahulu.',
        );
        return;
      }

      setState(() {
        currentStep = 3;
      });

      return;
    }

    // LANGKAH 3 → LANGKAH 4
    if (currentStep == 3) {
      if (!step3Complete) {
        _showMessage(
          'Silakan pilih frekuensi untuk semua keluhan.',
        );
        return;
      }

      setState(() {
        currentStep = 4;
      });

      return;
    }
  }

  // ============================================================
  // KEMBALI
  // ============================================================

  void _previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // ANALISIS DATA
  // ============================================================

  void _startAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreeningLoadingScreen(
          age: age,
          gender: gender!,
          step2Answers: Map<String, bool?>.from(
            step2Answers,
          ),
          step3Answers: Map<String, String?>.from(
            step3Answers,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Fredoka',
          ),
        ),
        backgroundColor: brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                padding: const EdgeInsets.fromLTRB(
                  15,
                  8,
                  15,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildProgress(),

                    const SizedBox(height: 18),

                    // ==================================================
                    // STEP 1
                    // ==================================================

                    if (currentStep == 1)
                      ScreeningDataDiri(
                        age: age,
                        gender: gender,
                        brown: brown,
                        cardColor: cardColor,
                        onAgeChanged: (value) {
                          setState(() {
                            age = value;
                          });
                        },
                        onGenderChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),

                    // ==================================================
                    // STEP 2
                    // ==================================================

                    if (currentStep == 2)
                      ScreeningKondisi(
                        answers: step2Answers,
                        brown: brown,
                        cardColor: cardColor,
                        symptomImages: symptomImages,
                        onAnswer: (entry) {
                          setState(() {
                            step2Answers[entry.key] = entry.value;
                          });
                        },
                      ),

                    // ==================================================
                    // STEP 3
                    // ==================================================

                    if (currentStep == 3)
                      ScreeningGejala(
                        answers: step3Answers,
                        brown: brown,
                        cardColor: cardColor,
                        symptomImages: symptomImages,
                        onAnswer: (entry) {
                          setState(() {
                            step3Answers[entry.key] = entry.value;
                          });
                        },
                      ),

                    // ==================================================
                    // STEP 4
                    // ==================================================

                    if (currentStep == 4)
                      _buildStep4(),

                    const SizedBox(height: 30),

                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _previousStep,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 24,
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
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah $currentStep dari 4',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            for (int i = 1; i <= 4; i++) ...[
              _buildProgressCircle(i),

              if (i < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i <= currentStep
                        ? brown
                        : orangeLine,
                  ),
                ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        _buildStepTitle(),
      ],
    );
  }

  Widget _buildProgressCircle(int number) {
    bool active;

    if (currentStep == 1) {
      active = number == 1;
    } else if (currentStep == 2) {
      active = number <= 2;
    } else if (currentStep == 3) {
      active = number <= 3;
    } else {
      active = number <= 4;
    }

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: active ? brown : orangeLine,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // JUDUL LANGKAH
  // ============================================================

  Widget _buildStepTitle() {
    String title;
    String subtitle;

    if (currentStep == 1) {
      title = 'Kenali dirimu lebih dulu';
      subtitle = 'Masukkan informasi dasar berikut.';
    } else if (currentStep == 2) {
      title = 'Ceritakan Kondisi dan Kebiasaanmu';
      subtitle =
          'Pilihlah jawaban yang sesuai dengan kondisimu';
    } else if (currentStep == 3) {
      title = 'Seberapa sering kamu mengalami keluhan';
      subtitle =
          'Pilihlah jawaban yang sesuai dengan kondisimu';
    } else {
      title = 'Periksa kembali jawabanmu';
      subtitle =
          'Pastikan semua informasi sudah sesuai';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF5C514C),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LANGKAH 4
  // ============================================================

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataDiri(),

        const SizedBox(height: 14),

        _buildKondisi(),

        const SizedBox(height: 14),

        _buildGejala(),
      ],
    );
  }

  // ============================================================
  // DATA DIRI
  // ============================================================

  Widget _buildDataDiri() {
    return _buildSummaryCard(
      title: 'Data Diri',
      children: [
        _buildSummaryRow(
          'Usia',
          '$age Tahun',
        ),
        _buildSummaryRow(
          'Jenis kelamin',
          gender,
        ),
      ],
    );
  }

  // ============================================================
  // KONDISI
  // ============================================================

  Widget _buildKondisi() {
    return _buildSummaryCard(
      title: 'Kondisi dan Kebiasaan',
      children: [
        _buildSummaryRow(
          'Perut terasa penuh',
          _yesNoText(
            step2Answers['Perut terasa penuh'],
          ),
        ),
        _buildSummaryRow(
          'Tidur cukup',
          _yesNoText(
            step2Answers['Waktu tidur'],
          ),
        ),
        _buildSummaryRow(
          'Menggunakan obat',
          _yesNoText(
            step2Answers['Penggunaan obat'],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GEJALA
  // ============================================================

  Widget _buildGejala() {
    return _buildSummaryCard(
      title: 'Gejala dan Frekuensi',
      children: [
        _buildSummaryRow(
          'Panas di dada',
          step3Answers['Panas di dada'] ?? '-',
        ),
        _buildSummaryRow(
          'Asam lambung naik',
          step3Answers['Asam lambung naik'] ?? '-',
        ),
        _buildSummaryRow(
          'Nyeri dada / ulu hati',
          step3Answers['Nyeri dada atau ulu hati'] ?? '-',
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        9,
        12,
        10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF775C),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB05039),
            ),
          ),

          const SizedBox(height: 6),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _buildSummaryRow(
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(
            width: 110,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // YES / NO TEXT
  // ============================================================

  String _yesNoText(bool? value) {
    if (value == true) {
      return 'Ya';
    }

    if (value == false) {
      return 'Tidak';
    }

    return '-';
  }

  // ============================================================
  // BUTTON LANJUTKAN
  // ============================================================

  Widget _buildContinueButton() {
    return Center(
      child: SizedBox(
        width: 230,
        height: 40,
        child: ElevatedButton(
          onPressed: currentStep == 4
              ? _startAnalysis
              : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: brown,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor:
                Colors.black.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            currentStep == 4
                ? 'Analisis Data Saya'
                : 'Lanjutkan',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}