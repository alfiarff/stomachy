
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
          question: 'Apakah kamu sering mengalami sesak atau kesulitan bernapas?',
        ),
        const SizedBox(height: 15),
        _buildYesNoCard(
          title: 'Asam lambung naik',
          question: 'Apakah kamu pernah merasakan asam atau rasa pahit naik ke tenggorokan?',
        ),
        const SizedBox(height: 15),
        _buildYesNoCard(
          title: 'Nyeri dada atau ulu hati',
          question: 'Apakah kamu sering merasakan nyeri atau tidak nyaman di dada atau ulu hati?',
        ),
      ],
    );
  }

  Widget _buildYesNoCard({
    required String title,
    required String question,
    String? note,
  }) {
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 110),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              child: Image.asset(
                symptomImages[title] ?? 'assets/images/emoji_sesak.png',
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    question,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      color: Color(0xFF766D68),
                    ),
                  ),

                  // Keterangan tambahan jika tersedia
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: Color(0xFFB05039),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
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
                      ),
                    ),
                  ],

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
      ),
    );
  }

  Widget _buildYesNoButton({
    required String title,
    required bool value,
    required String label,
  }) {
    final bool selected = answers[title] == value;

    return GestureDetector(
      onTap: () => onAnswer(MapEntry(title, value)),
      child: Container(
        width: 70,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE0D5) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? brown : const Color(0xFFFF765B),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
