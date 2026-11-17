
import 'package:flutter/material.dart';
import 'package:stomachy/widgets/stomachy_card.dart';

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
          question: 'Apakah kamu sering merasa perut penuh setelah makan?',
        ),
        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Waktu tidur',
          question: 'Apakah waktu tidurmu sudah cukup? (7-9 jam sehari)',
        ),
        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Penggunaan obat',
          question: 'Apakah kamu sedang mengonsumsi obat tertentu saat ini?',
        ),
        const SizedBox(height: 15),

        _buildYesNoCard(
          title: 'Sesak napas',
          question:
              'Apakah kamu sering mengalami sesak atau kesulitan bernapas?',
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
  // KARTU KONDISI
  // ============================================================

  Widget _buildYesNoCard({
    required String title,
    required String question,
    String? note,
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
          // JUDUL CARD
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

          // PERTANYAAN
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

          // KETERANGAN TAMBAHAN
          if (note != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E8),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                note,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  height: 1.2,
                  color: Color(0xFF766D68),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // PILIHAN YA / TIDAK VERTIKAL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYesNoOption(
                title: title,
                value: true,
                label: 'Ya',
              ),

              const SizedBox(height: 9),

              _buildYesNoOption(
                title: title,
                value: false,
                label: 'Tidak',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RADIO BUTTON YA / TIDAK DENGAN TANDA CENTANG
  // ============================================================

  Widget _buildYesNoOption({
    required String title,
    required bool value,
    required String label,
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
                label,
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
