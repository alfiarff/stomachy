
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

  // Memilih tanggal lahir menggunakan date picker
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    // Tanggal awal yang ditampilkan pada date picker
    final DateTime defaultDate = DateTime(
      today.year - 20,
      today.month,
      today.day,
    );

    // Pastikan tanggal awal tidak melebihi tanggal hari ini
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

    // Pastikan widget masih aktif setelah date picker ditutup
    if (!context.mounted) return;

    if (selectedDate != null) {
      onBirthDateChanged(selectedDate);
    }
  }

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

  // Kartu tanggal lahir
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
        child: Row(
          children: [
            const SizedBox(
              width: 55,
              child: Icon(
                Icons.calendar_month_rounded,
                size: 40,
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
                    'Tanggal Lahir',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: () => _selectBirthDate(context),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF8B817D),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formattedBirthDate,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                color: birthDate == null
                                    ? const Color(0xFF99918E)
                                    : Colors.black,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Color(0xFFB05039),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu usia (otomatis dari tanggal lahir)
  Widget _buildAgeCard() {
    return StomachyCard(
      color: cardColor,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 75,
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
                    fontSize: 11,
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
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu jenis kelamin
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
                      fontWeight: FontWeight.w800,
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

  // Tombol pilihan jenis kelamin
  Widget _buildGenderButton(String value) {
    final bool selected = gender == value;

    return GestureDetector(
      onTap: () => onGenderChanged(value),
      child: Container(
        width: 98,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE3D9)
              : const Color(0xFFFFFCF9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? brown : const Color(0xFF9A908B),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: selected ? brown : const Color(0xFF827A76),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
