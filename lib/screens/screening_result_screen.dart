import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

// ===============================================================
// ASSET MASKOT HASIL SKRINING
// Berisiko      -> maskot cemas (tampilan MERAH)
// Tidak berisiko -> maskot senyum (tampilan HIJAU)
// Kalau punya asset khusus sesuai Figma, ganti path di bawah.
// ===============================================================
const String kResultMascotRisk =
    'assets/images/maskot_berisiko.png';

const String kResultMascotSafe =
    'assets/images/maskot_happy.png';

// ===============================================================
// TEMA WARNA HASIL
// MERAH -> berisiko GERD
// HIJAU -> tidak berisiko GERD
// ===============================================================
class ResultTheme {
  final Color accent;
  final Color accentSoft;

  const ResultTheme({
    required this.accent,
    required this.accentSoft,
  });

  static const ResultTheme risk = ResultTheme(
    accent: Color(0xFFE93636),
    accentSoft: Color(0xFFFFE1DE),
  );

  static const ResultTheme safe = ResultTheme(
    accent: Color(0xFF18865A),
    accentSoft: Color(0xFFDCF2E4),
  );
}

class ScreeningResultScreen extends StatefulWidget {
  final String? date;
  final String? status;
  final String? complaint;
  final String? age;
  final String? gender;
  final String? symptom;
  final String? image;
  final bool? isRisk;

  final double? probability;
  final String? prediction;

  final Map<String, bool?>? step2Answers;
  final Map<String, String?>? step3Answers;

  final bool saveToHistory;

  const ScreeningResultScreen({
    super.key,
    this.date,
    this.status,
    this.complaint,
    this.age,
    this.gender,
    this.symptom,
    this.image,
    this.isRisk,
    this.probability,
    this.prediction,
    this.step2Answers,
    this.step3Answers,
    this.saveToHistory = true,
  });

  @override
  State<ScreeningResultScreen> createState() =>
      _ScreeningResultScreenState();
}

class _ScreeningResultScreenState
    extends State<ScreeningResultScreen> {
  int _selectedIndex = 1;

  static const Color backgroundColor =
      Color(0xFFFFF5EF);

  static const Color cardColor =
      Color(0xFFFFE8D7);

  static const Color primaryBrown =
      Color(0xFF493028);

  static const Color bodyText =
      Color(0xFF4A382F);

  // ===============================================================
  // HASIL + TEMA
  // ===============================================================

  bool get isRiskResult {
    if (widget.prediction != null &&
        widget.prediction!.isNotEmpty) {
      return widget.prediction == 'GORD+';
    }

    return widget.isRisk ?? false;
  }

  ResultTheme get resultTheme =>
      isRiskResult ? ResultTheme.risk : ResultTheme.safe;

  String get resultImage => isRiskResult
      ? kResultMascotRisk
      : kResultMascotSafe;

  String get resultStatus =>
      isRiskResult ? 'GORD+' : 'GORD-';

  String get resultDescription {
    if (isRiskResult) {
      return 'Berdasarkan jawaban yang kamu masukkan, terdapat pola '
          'gejala yang sesuai dengan risiko Gastroesophageal '
          'Reflux Disease (GERD).';
    }

    return 'Berdasarkan jawaban yang kamu masukkan, tidak ditemukan '
        'pola gejala yang mengarah pada risiko Gastroesophageal '
        'Reflux Disease (GERD).';
  }

  String get adviceTitle => isRiskResult
      ? 'Saran untuk kamu'
      : 'Saran untuk tetap sehat';

  List<String> get adviceList {
    if (isRiskResult) {
      return const [
        'Perhatikan pola makan dan gaya hidup',
        'Hindari makanan pemicu',
        'Jaga berat badan ideal',
        'Jika keluhan berlanjut, konsultasikan ke dokter',
      ];
    }

    return const [
      'Jaga pola makan teratur',
      'Hindari makanan yang memicu keluhan',
      'Istirahat yang cukup',
      'Tetap perhatikan perubahan gejala',
    ];
  }

  String get probabilityText {
    if (widget.probability == null) {
      return '-';
    }

    final double percentage =
        widget.probability! * 100;

    return '${percentage.toStringAsFixed(2)}%';
  }

  // ===============================================================
  // KELUHAN + JUMLAH GEJALA (UNTUK DISIMPAN KE RIWAYAT)
  // ===============================================================

  String get generatedComplaint {
    final List<String> complaints = [];

    final answers = widget.step2Answers;

    if (answers != null) {
      if (answers['Panas di dada'] == true) {
        complaints.add('Panas di dada');
      }

      if (answers['Asam lambung naik'] == true) {
        complaints.add('asam lambung naik');
      }

      if (answers['Nyeri dada atau ulu hati'] == true) {
        complaints.add('nyeri dada atau ulu hati');
      }

      if (answers['Perut terasa penuh'] == true) {
        complaints.add('perut terasa penuh');
      }
    }

    if (complaints.isEmpty) {
      return 'Tidak ada keluhan';
    }

    return complaints.join(', ');
  }

  String get generatedSymptomCount {
    int count = 0;

    final answers = widget.step2Answers;

    if (answers != null) {
      if (answers['Panas di dada'] == true) count++;
      if (answers['Asam lambung naik'] == true) count++;
      if (answers['Nyeri dada atau ulu hati'] == true) {
        count++;
      }
      if (answers['Perut terasa penuh'] == true) count++;
    }

    return '$count Gejala utama';
  }

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    if (widget.saveToHistory) {
      _saveScreeningResult();
    }
  }

  // ===============================================================
  // SAVE FIREBASE
  // ===============================================================

  Future<void> _saveScreeningResult() async {
    try {
      final FirebaseAuth auth =
          FirebaseAuth.instance;

      final FirebaseFirestore firestore =
          FirebaseFirestore.instance;

      final User? user =
          auth.currentUser;

      if (user == null) {
        debugPrint(
          'SCREENING ERROR: Tidak ada user yang sedang login.',
        );

        return;
      }

      debugPrint(
        'SCREENING: User login = ${user.email}',
      );

      debugPrint(
        'SCREENING: UID = ${user.uid}',
      );

      // ===========================================================
      // STEP 2
      // ===========================================================

      final Map<String, dynamic> step2Data =
          {};

      final Map<String, bool?>? answersStep2 =
          widget.step2Answers;

      if (answersStep2 != null) {
        answersStep2.forEach(
          (key, value) {
            if (value != null) {
              step2Data[key] = value;
            }
          },
        );
      }

      // ===========================================================
      // STEP 3
      // ===========================================================

      final Map<String, dynamic> step3Data =
          {};

      final Map<String, String?>? answersStep3 =
          widget.step3Answers;

      if (answersStep3 != null) {
        answersStep3.forEach(
          (key, value) {
            if (value != null) {
              step3Data[key] = value;
            }
          },
        );
      }

      // ===========================================================
      // DATA SCREENING
      // ===========================================================

      final Map<String, dynamic> screeningData =
          {
        'date':
            widget.date ??
            DateTime.now()
                .toIso8601String(),

        'status':
            resultStatus,

        'complaint':
            generatedComplaint,

        'age':
            widget.age ?? '',

        'gender':
            widget.gender ?? '',

        'symptom':
            generatedSymptomCount,

        'image':
            isRiskResult
                ? 'assets/images/riwayat_berisiko_gerd.png'
                : 'assets/images/riwayat_tidak_berisiko_gerd.png',

        'isRisk':
            isRiskResult,

        'probability':
            widget.probability ?? 0.0,

        'prediction':
            resultStatus,

        'createdAt':
            FieldValue.serverTimestamp(),

        'step2Answers':
            step2Data,

        'step3Answers':
            step3Data,
      };

      debugPrint(
        'SCREENING: Data siap disimpan.',
      );

      // ===========================================================
      // FIRESTORE
      // ===========================================================

      final CollectionReference historyCollection =
          firestore
              .collection('users')
              .doc(user.uid)
              .collection('screening_history');

      final DocumentReference document =
          await historyCollection.add(
        screeningData,
      );

      debugPrint(
        'SCREENING: BERHASIL disimpan.',
      );

      debugPrint(
        'SCREENING: Document ID = ${document.id}',
      );

      debugPrint(
        'SCREENING: Path = users/${user.uid}/screening_history/${document.id}',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'SCREENING FIREBASE ERROR:',
      );

      debugPrint(
        'Code: ${e.code}',
      );

      debugPrint(
        'Message: ${e.message}',
      );

      debugPrint(
        'Details: ${e.toString()}',
      );
    } catch (e) {
      debugPrint(
        'SCREENING ERROR: $e',
      );
    }
  }

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
          builder: (context) =>
              const HomeScreen(),
        ),
      );

      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ScreeningScreen(),
        ),
      );

      return;
    }

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

    if (index == 4) {
      Navigator.pushReplacement(
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
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            26,
            8,
            26,
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _buildHeader(),

              const SizedBox(height: 14),

              _buildResultCard(),

              const SizedBox(height: 18),

              _buildProbability(),

              const SizedBox(height: 24),

              _buildAdviceSection(),

              const SizedBox(height: 26),

              _buildDisclaimer(),

              // =====================================================
              // TOMBOL DOKTER HANYA MUNCUL JIKA BERISIKO
              // (sesuai desain Figma, versi hijau tanpa tombol)
              // =====================================================
              if (isRiskResult) ...[
                const SizedBox(height: 30),

                _buildDoctorButton(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          AppBottomNavigation(
        selectedIndex:
            _selectedIndex,
        onItemSelected:
            _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 50,

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
                alignment:
                    Alignment.centerLeft,

                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Hasil Skrining',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  color: primaryBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // ===============================================================
  // RESULT CARD
  // ===============================================================

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        22,
      ),

      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 150,

            child: Image.asset(
              resultImage,
              fit: BoxFit.contain,

              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return Icon(
                  Icons
                      .medical_services_rounded,
                  size: 100,
                  color: resultTheme.accent,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          _buildResultTitle(),

          const SizedBox(height: 2),

          Text(
            'GERD',
            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 26,
              fontWeight:
                  FontWeight.w700,
              color: resultTheme.accent,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            resultDescription,
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              height: 1.45,
              color: bodyText,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // JUDUL HASIL
  // Kata "tidak" diwarnai HIJAU pada hasil aman
  // ===============================================================

  Widget _buildResultTitle() {
    const baseStyle = TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20,
      fontWeight:
          FontWeight.w600,
      color: primaryBrown,
    );

    if (isRiskResult) {
      return const Text(
        'Kamu berisiko mengalami',
        textAlign:
            TextAlign.center,
        style: baseStyle,
      );
    }

    return Text.rich(
      TextSpan(
        text: 'Kamu ',

        style: baseStyle,

        children: [
          TextSpan(
            text: 'tidak',

            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight:
                  FontWeight.w700,
              color: resultTheme.accent,
            ),
          ),

          const TextSpan(
            text: ' berisiko mengalami',
          ),
        ],
      ),

      textAlign:
          TextAlign.center,
    );
  }

  // ===============================================================
  // PROBABILITY
  // ===============================================================

  Widget _buildProbability() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: resultTheme.accentSoft,
          width: 1.2,
        ),
      ),

      child: Row(
        children: [
          Icon(
            Icons.analytics_rounded,
            color: resultTheme.accent,
            size: 24,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Probabilitas GORD+',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: primaryBrown,
              ),
            ),
          ),

          Text(
            probabilityText,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
              color: resultTheme.accent,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SARAN
  // ===============================================================

  Widget _buildAdviceSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 8),

          child: Text(
            adviceTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
              color: primaryBrown,
            ),
          ),
        ),

        const SizedBox(height: 9),

        for (final advice in adviceList)
          _buildAdviceItem(advice),
      ],
    );
  }

  // ===============================================================
  // ADVICE ITEM
  // ===============================================================

  Widget _buildAdviceItem(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 17,
        bottom: 7,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Container(
            width: 18,
            height: 18,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resultTheme.accent,
            ),

            child: const Icon(
              Icons.check_rounded,
              size: 13,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
                color: bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DISCLAIMER
  // ===============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFF3DCC9),
          width: 1,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,

            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: resultTheme.accent,
                width: 1.2,
              ),
            ),

            child: Center(
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  fontWeight:
                      FontWeight.w700,
                  color: resultTheme.accent,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Hasil skrining ini bukan merupakan diagnosis medis.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DOKTER BUTTON
  // ===============================================================

  Widget _buildDoctorButton() {
    return Center(
      child: SizedBox(
        width: 230,
        height: 42,

        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const DoctorScreen(),
              ),
            );
          },

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFB65339),
            foregroundColor:
                Colors.white,
            elevation: 4,
            shadowColor:
                Colors.black.withValues(
              alpha: 0.25,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                25,
              ),
            ),
          ),

          child: const Text(
            'Konsultasi Dokter',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}