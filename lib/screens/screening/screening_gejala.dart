import 'package:flutter/material.dart';

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
              errorBuilder: (context, error, stackTrace) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
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
                    fontSize: 12,
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

  // ============================================================
  // TOMBOL FREKUENSI
  // ============================================================

  Widget _buildFrequencyButton({
    required String title,
    required String value,
  }) {
    final bool selected = answers[title] == value;

    return GestureDetector(
      onTap: () {
        onAnswer(
          MapEntry(title, value),
        );
      },
      child: Container(
        height: 21,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE0D5)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? brown
                : const Color(0xFFFF765B),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
}