import 'package:flutter/material.dart';
import 'screening_loading_screen.dart';
import '../widgets/bottom_navigation.dart';

class ScreeningConfirmationScreen extends StatelessWidget {
  final String age;
  final String gender;

  final Map<String, bool?> step2Answers;
  final Map<String, String?> step3Answers;

  const ScreeningConfirmationScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.step2Answers,
    required this.step3Answers,
  });

  final Color backgroundColor = const Color(0xFFFFF5ED);
  final Color brown = const Color(0xFFB05039);

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
                    _buildHeader(context),

                    const SizedBox(height: 22),

                    _buildProgress(),

                    const SizedBox(height: 28),

                    const Text(
                      'Periksa kembali jawabanmu',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Pastikan semua informasi sudah sesuai',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5C514C),
                      ),
                    ),

                    const SizedBox(height: 9),

                    _buildDataDiri(),

                    const SizedBox(height: 14),

                    _buildKondisi(),

                    const SizedBox(height: 14),

                    _buildGejala(),

                    const SizedBox(height: 82),

                    Center(
                      child: SizedBox(
                        width: 230,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScreeningLoadingScreen(
                                  age: age,
                                  gender: gender,
                                  step2Answers: step2Answers,
                                  step3Answers: step3Answers,
                                ),
                              ),
                            );
                          },
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
                          child: const Text(
                            'Analisis Data Saya',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 1,
        onItemSelected: (index) {},
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 45,
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
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Langkah 4 dari 4',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Color(0xFFB83E20),
                  shape: BoxShape.circle,
                ),
              ),

              if (i < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: const Color(0xFFB83E20),
                  ),
                ),
            ],
          ],
        ),
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
        color: const Color(0xFFFFFCF9),
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

  String _yesNoText(bool? value) {
    if (value == true) {
      return 'Ya';
    }

    if (value == false) {
      return 'Tidak';
    }

    return '-';
  }
}