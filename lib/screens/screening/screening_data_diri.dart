import 'package:flutter/material.dart';
import 'package:stomachy/widgets/stomachy_card.dart';

class ScreeningDataDiri extends StatelessWidget {
  final String age;
  final String? gender;

  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onGenderChanged;

  final Color brown;
  final Color cardColor;

  const ScreeningDataDiri({
    super.key,
    required this.age,
    required this.gender,
    required this.onAgeChanged,
    required this.onGenderChanged,
    required this.brown,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAgeCard(),
        const SizedBox(height: 20),
        _buildGenderCard(),
      ],
    );
  }

  // ============================================================
  // KARTU USIA
  // ============================================================

  Widget _buildAgeCard() {
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 95,
        child: Row(
          children: [
            const SizedBox(
              width: 55,
              child: Icon(
                Icons.person_rounded,
                size: 42,
                color: Color(0xFFB05039),
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'Usia',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: onAgeChanged,
                  decoration: InputDecoration(
                    hintText: 'Isi usia anda',
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF99918E),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                    // BORDER INPUT TETAP
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF8B817D),
                      ),
                    ),

                    // BORDER INPUT TETAP
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFB05039),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            const Text(
              'Tahun',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU JENIS KELAMIN
  // ============================================================

  Widget _buildGenderCard() {
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 95,
        child: Row(
          children: [
            const SizedBox(
              width: 55,
              child: Icon(
                Icons.wc_rounded,
                size: 44,
                color: Color(0xFFB05039),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jenis Kelamin',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildGenderButton('Perempuan'),

                      const SizedBox(width: 8),

                      _buildGenderButton('Laki - laki'),
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

  // ============================================================
  // TOMBOL JENIS KELAMIN
  // ============================================================

  Widget _buildGenderButton(String value) {
    final bool selected = gender == value;

    return GestureDetector(
      onTap: () {
        onGenderChanged(value);
      },
      child: Container(
        width: 98,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE3D9)
              : const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(10),

          // BORDER TOMBOL TETAP
          border: Border.all(
            color: selected
                ? brown
                : const Color(0xFF9A908B),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: selected
                ? brown
                : const Color(0xFF827A76),
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}