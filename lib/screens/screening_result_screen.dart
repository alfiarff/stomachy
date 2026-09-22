import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

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

  static const Color accentBrown =
      Color(0xFFB65339);

  // ===============================================================
  // HASIL
  // ===============================================================

  bool get isRiskResult {
    if (widget.prediction != null) {
      return widget.prediction == 'GORD+';
    }

    return widget.isRisk ?? false;
  }

  String get resultTitle {
    if (isRiskResult) {
      return 'Kamu berisiko mengalami';
    }

    return 'Kamu tidak menunjukkan';
  }

  String get resultSubtitle {
    if (isRiskResult) {
      return 'GERD';
    }

    return 'risiko GERD';
  }

  String get resultDescription {
    if (isRiskResult) {
      return 'Berdasarkan jawaban yang kamu masukkan, terdapat\n'
          'pola gejala yang sesuai dengan risiko '
          'Gastroesophageal\n'
          'Reflux Disease (GERD).';
    }

    return 'Berdasarkan jawaban yang kamu masukkan, '
        'model tidak\n'
        'menunjukkan pola yang sesuai dengan risiko '
        'Gastroesophageal\n'
        'Reflux Disease (GERD).';
  }

  String get resultImage {
    if (widget.image != null &&
        widget.image!.isNotEmpty) {
      return widget.image!;
    }

    if (isRiskResult) {
      return 'assets/images/maskot_berisiko.png';
    }

    return 'assets/images/maskot_berisiko.png';
  }

  String get resultStatus {
    if (widget.prediction != null) {
      return widget.prediction!;
    }

    return isRiskResult
        ? 'GORD+'
        : 'GORD-';
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
            widget.status ??
            resultStatus,

        'complaint':
            widget.complaint ??
            resultSubtitle,

        'age':
            widget.age ?? '',

        'gender':
            widget.gender ?? '',

        'symptom':
            widget.symptom ??
            resultSubtitle,

        'image':
            widget.image ??
            resultImage,

        'isRisk':
            widget.isRisk ??
            isRiskResult,

        'probability':
            widget.probability ?? 0.0,

        'prediction':
            widget.prediction ??
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

              const SizedBox(height: 12),

              _buildResultCard(),

              const SizedBox(height: 25),

              _buildProbability(),

              const SizedBox(height: 25),

              _buildAdviceSection(),

              const SizedBox(height: 31),

              _buildDisclaimer(),

              const SizedBox(height: 35),

              _buildDoctorButton(),

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
      constraints:
          const BoxConstraints(
        minHeight: 328,
      ),

      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          const SizedBox(height: 20),

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
                return const Icon(
                  Icons
                      .medical_services_rounded,
                  size: 100,
                  color: accentBrown,
                );
              },
            ),
          ),

          const SizedBox(height: 3),

          Text(
            resultTitle,
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight:
                  FontWeight.w600,
              color: primaryBrown,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            resultSubtitle,
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 25,
              fontWeight:
                  FontWeight.w500,
              color: accentBrown,
            ),
          ),

          const SizedBox(height: 2),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            child: Text(
              resultDescription,
              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 10,
                height: 1.35,
                color:
                    Color(0xFF332823),
              ),
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
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
          color:
              const Color(0xFFFFD7B8),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.analytics_rounded,
            color: accentBrown,
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
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
              color: accentBrown,
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
        const Padding(
          padding:
              EdgeInsets.only(left: 8),

          child: Text(
            'Saran untuk kamu',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
              color: primaryBrown,
            ),
          ),
        ),

        const SizedBox(height: 9),

        _buildAdviceItem(
          'Perhatikan pola makan dan gaya hidup',
        ),

        _buildAdviceItem(
          'Hindari makanan pemicu',
        ),

        _buildAdviceItem(
          'Jaga berat badan ideal',
        ),

        _buildAdviceItem(
          'Jika keluhan berlanjut, konsultasikan ke dokter',
        ),
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
        bottom: 6,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Container(
            width: 15,
            height: 15,

            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: accentBrown,
            ),

            child: const Icon(
              Icons.check,
              size: 10,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
                color:
                    Color(0xFF332823),
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
      height: 37,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFFFD7B8),
          width: 1,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,

            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentBrown,
                width: 1,
              ),
            ),

            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                  color: accentBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Hasil skrining ini bukan merupakan diagnosis medis.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF332823),
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
        width: 228,
        height: 39,

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
                accentBrown,
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
                22,
              ),
            ),
          ),

          child: const Text(
            'Konsultasi Dokter',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}