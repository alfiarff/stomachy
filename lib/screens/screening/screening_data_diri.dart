
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:stomachy/widgets/stomachy_card.dart';

class ScreeningDataDiri extends StatelessWidget {
  final DateTime? birthDate;
  final String age;
  final String? gender;

  final ValueChanged<DateTime> onBirthDateChanged;
  final ValueChanged<String> onGenderChanged;

  final Color brown;
  final Color cardColor;

  const ScreeningDataDiri({
    super.key,
    required this.birthDate,
    required this.age,
    required this.gender,
    required this.onBirthDateChanged,
    required this.onGenderChanged,
    required this.brown,
    required this.cardColor,
  });

  // ============================================================
  // MEMILIH TANGGAL LAHIR
  // ============================================================

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    final DateTime defaultDate = DateTime(
      today.year - 20,
      today.month,
      today.day,
    );

    final DateTime initialDate =
        birthDate != null && !birthDate!.isAfter(today)
            ? birthDate!
            : defaultDate;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Pilih tanggal lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: brown,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!context.mounted) return;

    if (selectedDate != null) {
      onBirthDateChanged(selectedDate);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBirthDateCard(context),
        const SizedBox(height: 15),
        _buildAgeCard(),
        const SizedBox(height: 20),
        _buildGenderCard(),
      ],
    );
  }

  // ============================================================
  // KARTU TANGGAL LAHIR
  // ============================================================

  Widget _buildBirthDateCard(BuildContext context) {
    final String formattedBirthDate = birthDate == null
        ? 'Pilih tanggal lahir'
        : DateFormat('dd/MM/yyyy').format(birthDate!);

    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggal Lahir',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 7),

            GestureDetector(
              onTap: () => _selectBirthDate(context),
              child: Container(
                height: 38,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF8B817D),
                  ),
                ),
                child: Text(
                  formattedBirthDate,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: birthDate == null
                        ? const Color(0xFF99918E)
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU USIA OTOMATIS
  // ============================================================

  Widget _buildAgeCard() {
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 75,
        child: Row(
          children: [
            const Text(
              'Usia',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Container(
                height: 38,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFBDB3AE),
                  ),
                ),
                child: Text(
                  age.isEmpty ? 'Otomatis' : age,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            const Text(
              'Tahun',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          _buildGenderOption('Perempuan'),

          const SizedBox(height: 9),

          _buildGenderOption('Laki - laki'),
        ],
      ),
    );
  }

  // ============================================================
  // RADIO BUTTON JENIS KELAMIN
  // ============================================================

  Widget _buildGenderOption(String value) {
    final bool selected = gender == value;

    return InkWell(
      onTap: () {
        onGenderChanged(value);
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
