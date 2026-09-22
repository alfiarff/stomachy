import 'dart:async';

import 'package:flutter/material.dart';

import '../services/stomachy_model_service.dart';

import 'home_screen.dart';
import 'screening_result_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class ScreeningLoadingScreen extends StatefulWidget {
  final String age;
  final String gender;

  final Map<String, bool?> step2Answers;
  final Map<String, String?> step3Answers;

  const ScreeningLoadingScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.step2Answers,
    required this.step3Answers,
  });

  @override
  State<ScreeningLoadingScreen> createState() =>
      _ScreeningLoadingScreenState();
}

class _ScreeningLoadingScreenState
    extends State<ScreeningLoadingScreen> {
  // ===============================================================
  // VARIABLE
  // ===============================================================

  double progress = 0.0;

  Timer? timer;

  bool modelFinished = false;
  bool navigationStarted = false;

  double? probability;
  String? prediction;

  String? analysisError;

  final StomachyModelService model =
      StomachyModelService();

  int _selectedIndex = 1;

  // ===============================================================
  // COLOR
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF5ED);

  final Color brown =
      const Color(0xFFB05039);

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _startAnalysis();
  }

  // ===============================================================
  // START ANALYSIS
  // ===============================================================

  Future<void> _startAnalysis() async {
    _startProgress();

    try {
      final double ageValue =
          double.parse(widget.age.trim());

      // -----------------------------------------------------------
      // LOAD MODEL
      // -----------------------------------------------------------

      await model.loadModel();

      // -----------------------------------------------------------
      // MAPPING GENDER
      // -----------------------------------------------------------

      final String modelGender =
          _mapGender(widget.gender);

      // -----------------------------------------------------------
      // MAPPING HEARTBURN
      // -----------------------------------------------------------

      final String heartBurn =
          _mapSymptom(
        step2Value:
            widget.step2Answers['Panas di dada'],
        frequency:
            widget.step3Answers['Panas di dada'],
      );

      final String hbFrequency =
          _mapFrequency(
        step2Value:
            widget.step2Answers['Panas di dada'],
        frequency:
            widget.step3Answers['Panas di dada'],
      );

      // -----------------------------------------------------------
      // MAPPING REFLUX
      // -----------------------------------------------------------

      final String reflux =
          _mapSymptom(
        step2Value:
            widget.step2Answers['Asam lambung naik'],
        frequency:
            widget.step3Answers['Asam lambung naik'],
      );

      final String refluxFrequency =
          _mapFrequency(
        step2Value:
            widget.step2Answers['Asam lambung naik'],
        frequency:
            widget.step3Answers['Asam lambung naik'],
      );

      // -----------------------------------------------------------
      // MAPPING CHEST PAIN
      // -----------------------------------------------------------

      final String chestPain =
          _mapSymptom(
        step2Value:
            widget.step2Answers[
                'Nyeri dada atau ulu hati'],
        frequency:
            widget.step3Answers[
                'Nyeri dada atau ulu hati'],
      );

      final String cpFrequency =
          _mapFrequency(
        step2Value:
            widget.step2Answers[
                'Nyeri dada atau ulu hati'],
        frequency:
            widget.step3Answers[
                'Nyeri dada atau ulu hati'],
      );

      // -----------------------------------------------------------
      // ABDOMINAL FULLNESS
      // -----------------------------------------------------------

      final bool? fullnessAnswer =
          widget.step2Answers[
              'Perut terasa penuh'];

      final String abdFullness =
          fullnessAnswer == true
              ? 'All the time'
              : 'No';

      // -----------------------------------------------------------
      // MEDICATION
      // -----------------------------------------------------------

      final bool? medicationAnswer =
          widget.step2Answers[
              'Penggunaan obat'];

      final String medication =
          medicationAnswer == true
              ? 'yes'
              : 'No';

      // -----------------------------------------------------------
      // ENOUGH SLEEP
      // -----------------------------------------------------------

      final bool? sleepAnswer =
          widget.step2Answers[
              'Waktu tidur'];

      final String enoughSleep =
          sleepAnswer == true
              ? 'yes'
              : 'no';

      // -----------------------------------------------------------
      // DEBUG INPUT
      // -----------------------------------------------------------

      debugPrint(
        '==============================',
      );

      debugPrint(
        'STOMACHY MODEL INPUT',
      );

      debugPrint(
        'Age: $ageValue',
      );

      debugPrint(
        'Gender: $modelGender',
      );

      debugPrint(
        'HeartBurn: $heartBurn',
      );

      debugPrint(
        'HB Frequency: $hbFrequency',
      );

      debugPrint(
        'Reflux: $reflux',
      );

      debugPrint(
        'Reflux Frequency: $refluxFrequency',
      );

      debugPrint(
        'Chest Pain: $chestPain',
      );

      debugPrint(
        'CP Frequency: $cpFrequency',
      );

      debugPrint(
        'Abd Fullness: $abdFullness',
      );

      debugPrint(
        'Medication: $medication',
      );

      debugPrint(
        'Enough Sleep: $enoughSleep',
      );

      // -----------------------------------------------------------
      // RUN MODEL
      // -----------------------------------------------------------

      final double result =
          model.predict(
        age: ageValue,
        gender: modelGender,
        heartBurn: heartBurn,
        hbFrequency: hbFrequency,
        reflux: reflux,
        refluxFrequency: refluxFrequency,
        chestPain: chestPain,
        cpFrequency: cpFrequency,
        abdFullness: abdFullness,
        medication: medication,
        enoughSleep: enoughSleep,
      );

      final String resultClass =
          model.classify(result);

      probability = result;
      prediction = resultClass;

      modelFinished = true;

      debugPrint(
        '==============================',
      );

      debugPrint(
        'STOMACHY MODEL RESULT',
      );

      debugPrint(
        'Probability GORD+: $result',
      );

      debugPrint(
        'Prediction: $resultClass',
      );

      debugPrint(
        '==============================',
      );

      _tryFinish();
    } catch (e) {
      debugPrint(
        'STOMACHY MODEL ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        analysisError =
            'Terjadi kesalahan saat menganalisis data.';
      });
    }
  }

  // ===============================================================
  // PROGRESS
  // ===============================================================

  void _startProgress() {
    const int totalMilliseconds = 4000;
    const int intervalMilliseconds = 100;

    int elapsed = 0;

    timer = Timer.periodic(
      const Duration(
        milliseconds: intervalMilliseconds,
      ),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        elapsed += intervalMilliseconds;

        setState(() {
          progress =
              elapsed / totalMilliseconds;

          if (progress > 1.0) {
            progress = 1.0;
          }
        });

        if (progress >= 1.0) {
          timer.cancel();

          _tryFinish();
        }
      },
    );
  }

  // ===============================================================
  // FINISH
  // ===============================================================

  void _tryFinish() {
    if (!mounted) return;

    if (navigationStarted) return;

    if (!modelFinished) return;

    if (progress < 1.0) return;

    if (probability == null ||
        prediction == null) {
      return;
    }

    navigationStarted = true;

    Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScreeningResultScreen(
              age: widget.age,
              gender: widget.gender,
              step2Answers:
                  widget.step2Answers,
              step3Answers:
                  widget.step3Answers,

              probability:
                  probability,

              prediction:
                  prediction,

              isRisk:
                  prediction == 'GORD+',

              saveToHistory: true,
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // MAPPING GENDER
  // ===============================================================

  String _mapGender(String value) {
    if (value == 'Perempuan') {
      return 'Female';
    }

    return 'Male';
  }

  // ===============================================================
  // MAPPING FREQUENCY
  // ===============================================================

  String _mapFrequency({
    required bool? step2Value,
    required String? frequency,
  }) {
    if (step2Value == false) {
      return 'No symptoms';
    }

    switch (frequency) {
      case 'Mingguan':
        return 'Weekly';

      case 'Bulanan':
        return 'Monthly';

      case 'Tidak Ada':
      default:
        return 'No symptoms';
    }
  }

  // ===============================================================
  // MAPPING SYMPTOM
  // ===============================================================

  String _mapSymptom({
    required bool? step2Value,
    required String? frequency,
  }) {
    if (step2Value == false) {
      return 'No';
    }

    switch (frequency) {
      case 'Mingguan':
        return 'Once a week';

      case 'Bulanan':
        return 'Once a month';

      case 'Tidak Ada':
      default:
        return 'No';
    }
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
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
      Navigator.push(
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
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    timer?.cancel();

    model.dispose();

    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final int percentage =
        (progress * 100).round();

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            const SizedBox(
              height: 45,
              child: Center(
                child: Text(
                  'Skrining',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 19,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 550,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 28,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFFFFCF9),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color:
                            const Color(0xFFFF775C),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.12),
                          blurRadius: 4,
                          offset:
                              const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),

                        Expanded(
                          flex: 4,
                          child: Image.asset(
                            'assets/images/maskot_loading.png',
                            fit: BoxFit.contain,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .psychology_rounded,
                                size: 130,
                                color:
                                    Color(0xFFB05039),
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'AI sedang menganalisis\n'
                          'jawabanmu...',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontFamily:
                                'Fredoka',
                            fontSize: 22,
                            height: 1.25,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        const Text(
                          'Mohon tunggu beberapa saat.\n'
                          'Hasil akan segera ditampilkan.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                child:
                                    LinearProgressIndicator(
                                  value:
                                      progress,
                                  minHeight:
                                      15,
                                  backgroundColor:
                                      const Color(
                                    0xFFF1E1D8,
                                  ),
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    brown,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 7,
                            ),

                            Text(
                              '$percentage%',
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 35,
                        ),

                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFFEBDD,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.12,
                                ),
                                blurRadius: 3,
                                offset:
                                    const Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/ikon_tips.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit
                                    .contain,
                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Icon(
                                    Icons
                                        .lightbulb,
                                    size: 45,
                                    color:
                                        Colors
                                            .orange,
                                  );
                                },
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Tahukah kamu?',
                                      style:
                                          TextStyle(
                                        fontFamily:
                                            'Nunito',
                                        fontSize:
                                            12,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Menjaga pola hidup sehat dapat membantu\n'
                                      'mengurangi risiko GERD.',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            10,
                                        height:
                                            1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected:
            _onNavigationTap,
      ),
    );
  }
}