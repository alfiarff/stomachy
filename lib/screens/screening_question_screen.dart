import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';

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

    // ============================================================
    // BERANDA
    // ============================================================

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // ============================================================
    // SKRINING
    // ============================================================

    if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
      return;
    }

    // ============================================================
    // DOKTER
    // ============================================================

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // ============================================================
    // EDUKASI
    // ============================================================

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // ============================================================
    // PROFIL
    // ============================================================

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

    // ============================================================
    // LANGKAH 1 → LANGKAH 2
    // ============================================================

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

    // ============================================================
    // LANGKAH 2 → LANGKAH 3
    // ============================================================

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

    // ============================================================
    // LANGKAH 3 → LANGKAH 4
    // ============================================================

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

                    if (currentStep == 1)
                      _buildStep1(),

                    if (currentStep == 2)
                      _buildStep2(),

                    if (currentStep == 3)
                      _buildStep3(),

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
            for (int i = 1; i <= 5; i++) ...[
              _buildProgressCircle(i),

              if (i < 5)
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
            fontSize: 14,
            color: Color(0xFF5C514C),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LANGKAH 1
  // ============================================================

  Widget _buildStep1() {
    return Column(
      children: [
        _buildAgeCard(),

        const SizedBox(height: 20),

        _buildGenderCard(),
      ],
    );
  }

  // ============================================================
  // KARTU USIA
  // ============================================================

  Widget _buildAgeCard() {
    return Container(
      width: double.infinity,
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFF775C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 55,
            child: Icon(
              Icons.person_rounded,
              size: 42,
              color: Color(0xFFB05039),
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            'Usia',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    age = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Isi usia anda',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF99918E),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF8B817D),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFB05039),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          const Text(
            'Tahun',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU JENIS KELAMIN
  // ============================================================

  Widget _buildGenderCard() {
    return Container(
      width: double.infinity,
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFF775C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 55,
            child: Icon(
              Icons.wc_rounded,
              size: 44,
              color: Color(0xFFB05039),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Kelamin',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildGenderButton('Perempuan'),

                    const SizedBox(width: 8),

                    _buildGenderButton('Laki - laki'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String value) {
    bool selected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        width: 98,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE3D9)
              : const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? brown
                : const Color(0xFF9A908B),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: selected
                ? brown
                : const Color(0xFF827A76),
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LANGKAH 2
  // ============================================================

  Widget _buildStep2() {
    return Column(
      children: [
        _buildYesNoCard(
          title: 'Perut terasa penuh',
          question:
              'Apakah kamu sering merasa perut penuh setelah makan?',
        ),

        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Waktu tidur',
          question:
              'Apakah kamu mendapatkan waktu tidur yang cukup?',
        ),

        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Penggunaan obat',
          question:
              'Apakah kamu sedang mengonsumsi obat tertentu saat ini?',
        ),

        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Panas di dada',
          question:
              'Apakah kamu sering merasakan sensasi panas atau terbakar di dada?',
        ),

        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Asam lambung naik',
          question:
              'Apakah kamu pernah merasakan asam atau rasa pahit naik ke tenggorokan?',
        ),

        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Nyeri dada atau ulu hati',
          question:
              'Apakah kamu sering merasakan nyeri atau tidak nyaman di dada atau ulu hati?',
        ),
      ],
    );
  }

  // ============================================================
  // KARTU YA / TIDAK
  // ============================================================

  Widget _buildYesNoCard({
    required String title,
    required String question,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFF775C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            child: Image.asset(
              symptomImages[title]!,
              width: 57,
              height: 57,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFB05039),
                  size: 35,
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.15,
                    color: Color(0xFF766D68),
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    _buildYesNoButton(
                      title: title,
                      value: true,
                      label: 'Ya',
                    ),

                    const SizedBox(width: 18),

                    _buildYesNoButton(
                      title: title,
                      value: false,
                      label: 'Tidak',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoButton({
    required String title,
    required bool value,
    required String label,
  }) {
    bool selected =
        step2Answers[title] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          step2Answers[title] = value;
        });
      },
      child: Container(
        width: 70,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE0D5)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? brown
                : const Color(0xFFFF765B),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LANGKAH 3
  // ============================================================

  Widget _buildStep3() {
    return Column(
      children: [
        _buildFrequencyCard(
          title: 'Panas di dada',
          question:
              'Seberapa sering kamu merasakan sensasi panas atau terbakar di dada?',
        ),

        const SizedBox(height: 15),

        _buildFrequencyCard(
          title: 'Asam lambung naik',
          question:
              'Seberapa sering kamu merasakan asam atau rasa pahit naik ke tenggorokan?',
        ),

        const SizedBox(height: 15),

        _buildFrequencyCard(
          title: 'Nyeri dada atau ulu hati',
          question:
              'Seberapa sering kamu merasakan nyeri atau tidak nyaman di dada atau ulu hati?',
        ),
      ],
    );
  }

  // ============================================================
  // KARTU FREKUENSI
  // ============================================================

  Widget _buildFrequencyCard({
    required String title,
    required String question,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFF775C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.12),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            child: Image.asset(
              symptomImages[title]!,
              width: 57,
              height: 57,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFB05039),
                  size: 35,
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.15,
                    color: Color(0xFF766D68),
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    _buildFrequencyButton(
                      title: title,
                      value: 'Tidak Ada',
                    ),

                    const SizedBox(width: 7),

                    _buildFrequencyButton(
                      title: title,
                      value: 'Mingguan',
                    ),

                    const SizedBox(width: 7),

                    _buildFrequencyButton(
                      title: title,
                      value: 'Bulanan',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton({
    required String title,
    required String value,
  }) {
    bool selected =
        step3Answers[title] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          step3Answers[title] = value;
        });
      },
      child: Container(
        height: 21,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE0D5)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? brown
                : const Color(0xFFFF765B),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
              borderRadius:
                  BorderRadius.circular(25),
            ),
          ),
          child: Text(
            currentStep == 4
                ? 'Analisis Data Saya'
                : 'Lanjutkan',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}