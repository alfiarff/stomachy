import 'package:tflite_flutter/tflite_flutter.dart';

class StomachyModelService {
  late Interpreter _interpreter;

  bool _isLoaded = false;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/stomachy_ann.tflite',
    );

    _isLoaded = true;
  }

  double predict({
    required double age,
    required String gender,
    required String heartBurn,
    required String hbFrequency,
    required String reflux,
    required String refluxFrequency,
    required String chestPain,
    required String cpFrequency,
    required String abdFullness,
    required String medication,
    required String enoughSleep,
  }) {
    if (!_isLoaded) {
      throw StateError(
        'Model belum dimuat. Jalankan loadModel() terlebih dahulu.',
      );
    }

    final input = _buildInput(
      age: age,
      gender: gender,
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

    final output = [
      [0.0]
    ];

    _interpreter.run(input, output);

    return (output[0][0] as num).toDouble();
  }

  List<List<double>> _buildInput({
    required double age,
    required String gender,
    required String heartBurn,
    required String hbFrequency,
    required String reflux,
    required String refluxFrequency,
    required String chestPain,
    required String cpFrequency,
    required String abdFullness,
    required String medication,
    required String enoughSleep,
  }) {
    final List<double> input = [];

    // ============================================================
    // 0. AGE
    // MinMaxScaler:
    // scaled = (age - (-18)) * 0.01923077
    // ============================================================

    final double scaledAge =
        (age - (-18.0)) * 0.01923077;

    input.add(scaledAge);

    // ============================================================
    // 1 - 2. GENDER
    // ============================================================

    input.add(
      gender == 'Female' ? 1.0 : 0.0,
    );

    input.add(
      gender == 'Male' ? 1.0 : 0.0,
    );

    // ============================================================
    // 3 - 7. HEARTBURN
    // ============================================================

    input.add(
      heartBurn == 'All the time' ? 1.0 : 0.0,
    );

    input.add(
      heartBurn == 'No' ? 1.0 : 0.0,
    );

    input.add(
      heartBurn == 'Once a month' ? 1.0 : 0.0,
    );

    input.add(
      heartBurn == 'Once a week' ? 1.0 : 0.0,
    );

    input.add(
      heartBurn == 'Twice a week' ? 1.0 : 0.0,
    );

    // ============================================================
    // 8 - 11. HEARTBURN FREQUENCY
    // ============================================================

    input.add(
      hbFrequency == 'Daily' ? 1.0 : 0.0,
    );

    input.add(
      hbFrequency == 'Monthly' ? 1.0 : 0.0,
    );

    input.add(
      hbFrequency == 'No symptoms' ? 1.0 : 0.0,
    );

    input.add(
      hbFrequency == 'Weekly' ? 1.0 : 0.0,
    );

    // ============================================================
    // 12 - 16. REFLUX
    // ============================================================

    input.add(
      reflux == 'All the time' ? 1.0 : 0.0,
    );

    input.add(
      reflux == 'No' ? 1.0 : 0.0,
    );

    input.add(
      reflux == 'Once a month' ? 1.0 : 0.0,
    );

    input.add(
      reflux == 'Once a week' ? 1.0 : 0.0,
    );

    input.add(
      reflux == 'Twice a week' ? 1.0 : 0.0,
    );

    // ============================================================
    // 17 - 20. REFLUX FREQUENCY
    // ============================================================

    input.add(
      refluxFrequency == 'Daily' ? 1.0 : 0.0,
    );

    input.add(
      refluxFrequency == 'Monthly' ? 1.0 : 0.0,
    );

    input.add(
      refluxFrequency == 'No symptoms' ? 1.0 : 0.0,
    );

    input.add(
      refluxFrequency == 'Weekly' ? 1.0 : 0.0,
    );

    // ============================================================
    // 21 - 25. CHEST PAIN
    // ============================================================

    input.add(
      chestPain == 'All the time' ? 1.0 : 0.0,
    );

    input.add(
      chestPain == 'No' ? 1.0 : 0.0,
    );

    input.add(
      chestPain == 'Once a month' ? 1.0 : 0.0,
    );

    input.add(
      chestPain == 'Once a week' ? 1.0 : 0.0,
    );

    input.add(
      chestPain == 'Twice a week' ? 1.0 : 0.0,
    );

    // ============================================================
    // 26 - 29. CHEST PAIN FREQUENCY
    // ============================================================

    input.add(
      cpFrequency == 'Daily' ? 1.0 : 0.0,
    );

    input.add(
      cpFrequency == 'Monthly' ? 1.0 : 0.0,
    );

    input.add(
      cpFrequency == 'No symptoms' ? 1.0 : 0.0,
    );

    input.add(
      cpFrequency == 'Weekly' ? 1.0 : 0.0,
    );

    // ============================================================
    // 30 - 34. ABDOMINAL FULLNESS
    // ============================================================

    input.add(
      abdFullness == 'All the time' ? 1.0 : 0.0,
    );

    input.add(
      abdFullness == 'No' ? 1.0 : 0.0,
    );

    input.add(
      abdFullness == 'Once a month' ? 1.0 : 0.0,
    );

    input.add(
      abdFullness == 'Once a week' ? 1.0 : 0.0,
    );

    input.add(
      abdFullness == 'Twice a week' ? 1.0 : 0.0,
    );

    // ============================================================
    // 35 - 36. MEDICATION
    // ============================================================

    input.add(
      medication == 'No' ? 1.0 : 0.0,
    );

    input.add(
      medication == 'yes' ? 1.0 : 0.0,
    );

    // ============================================================
    // 37 - 38. ENOUGH SLEEP
    // ============================================================

    input.add(
      enoughSleep == 'no' ? 1.0 : 0.0,
    );

    input.add(
      enoughSleep == 'yes' ? 1.0 : 0.0,
    );

    // ============================================================
    // VALIDASI
    // ============================================================

    if (input.length != 39) {
      throw Exception(
        'Jumlah feature salah: ${input.length}. '
        'Seharusnya 39.',
      );
    }

    return [input];
  }

  String classify(double probability) {
    return probability >= 0.5
        ? 'GORD+'
        : 'GORD-';
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
      _isLoaded = false;
    }
  }
}