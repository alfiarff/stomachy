
import 'package:flutter/material.dart';
import 'package:stomachy/widgets/stomachy_card.dart';

class ScreeningGejala extends StatelessWidget {
  final Map<String, String?> answers;
  final ValueChanged<MapEntry<String, String>> onAnswer;

  final Color brown;
  final Color cardColor;
  final Map<String, String> symptomImages;

  const ScreeningGejala({
    super.key,
    required this.answers,
    required this.onAnswer,
    required this.brown,
    required this.cardColor,
    required this.symptomImages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFrequencyCard(
          title: 'Sesak napas',
          question:
              'Seberapa sering kamu merasakan sesak napas atau kesulitan saat bernapas?',
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
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            question,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: Color(0xFF8A7D76),
            ),
          ),

          const SizedBox(height: 12),

          // PILIHAN FREKUENSI VERTIKAL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFrequencyOption(
                title: title,
                value: 'Tidak Ada',
              ),

              const SizedBox(height: 9),

              _buildFrequencyOption(
                title: title,
                value: 'Harian',
              ),

              const SizedBox(height: 9),

              _buildFrequencyOption(
                title: title,
                value: 'Mingguan',
              ),

              const SizedBox(height: 9),

              _buildFrequencyOption(
                title: title,
                value: 'Bulanan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PILIHAN RADIO DENGAN TANDA CENTANG
  // ============================================================

  Widget _buildFrequencyOption({
    required String title,
    required String value,
  }) {
    final bool selected = answers[title] == value;

    return InkWell(
      onTap: () {
        onAnswer(MapEntry(title, value));
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? brown : Colors.white,
                border: Border.all(
                  color: selected
                      ? brown
                      : const Color(0xFFA49B97),
                  width: 1.8,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
