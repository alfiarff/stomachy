import 'package:flutter/material.dart';

class ScreeningKondisi extends StatelessWidget {
  final Map<String, bool?> answers;
  final ValueChanged<MapEntry<String, bool>> onAnswer;

  final Color brown;
  final Color cardColor;
  final Map<String, String> symptomImages;

  const ScreeningKondisi({
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
        crossAxisAlignment: CrossAxisAlignment.center,
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

  // ============================================================
  // TOMBOL YA / TIDAK
  // ============================================================

  Widget _buildYesNoButton({
    required String title,
    required bool value,
    required String label,
  }) {
    final bool selected = answers[title] == value;

    return GestureDetector(
      onTap: () {
        onAnswer(
          MapEntry(title, value),
        );
      },
      child: Container(
        width: 70,
        height: 21,
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
}