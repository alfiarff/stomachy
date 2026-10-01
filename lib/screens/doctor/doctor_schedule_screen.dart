import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState
    extends State<DoctorScheduleScreen> {
  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  final Color primaryBrown =
      const Color(0xFF5A392F);

  final Color softOrange =
      const Color(0xFFFFE3D1);

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Map<String, Map<String, dynamic>> _schedule = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  // ===============================================================
  // LOAD JADWAL
  // ===============================================================

  Future<void> _loadSchedule() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final DocumentSnapshot<
          Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final Map<String, dynamic>? data =
            doc.data();

        final dynamic rawSchedule =
            data?['doctorSchedule'];

        if (rawSchedule is Map) {
          final Map<String, Map<String, dynamic>>
              loadedSchedule = {};

          for (final String day in _days) {
            final dynamic rawDay =
                rawSchedule[day];

            if (rawDay is Map) {
              loadedSchedule[day] = {
                'active':
                    rawDay['active'] == true,
                'start':
                    rawDay['start']?.toString() ??
                        '08:00',
                'end':
                    rawDay['end']?.toString() ??
                        '16:00',
              };
            }
          }

          if (!mounted) return;

          setState(() {
            _schedule = loadedSchedule;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal mengambil jadwal dokter.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          backgroundColor: primaryBrown,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          margin:
              const EdgeInsets.all(18),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===============================================================
  // SAVE JADWAL
  // ===============================================================

  Future<void> _saveSchedule() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'doctorSchedule': _schedule,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Jadwal dokter berhasil disimpan.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          backgroundColor: primaryBrown,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          margin:
              const EdgeInsets.all(18),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal menyimpan jadwal dokter.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          backgroundColor: primaryBrown,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          margin:
              const EdgeInsets.all(18),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ===============================================================
  // GET DAY DATA
  // ===============================================================

  Map<String, dynamic> _getDayData(
    String day,
  ) {
    return _schedule[day] ??
        {
          'active': false,
          'start': '08:00',
          'end': '16:00',
        };
  }

  // ===============================================================
  // TOGGLE DAY
  // ===============================================================

  void _toggleDay(
    String day,
    bool value,
  ) {
    final Map<String, dynamic> current =
        Map<String, dynamic>.from(
      _getDayData(day),
    );

    current['active'] = value;

    setState(() {
      _schedule[day] = current;
    });
  }

  // ===============================================================
  // PICK TIME
  // ===============================================================

  Future<void> _pickTime({
    required String day,
    required bool isStart,
  }) async {
    final Map<String, dynamic> current =
        _getDayData(day);

    final String currentTime = isStart
        ? current['start'].toString()
        : current['end'].toString();

    final List<String> parts =
        currentTime.split(':');

    final TimeOfDay initialTime =
        TimeOfDay(
      hour: int.tryParse(
            parts.isNotEmpty
                ? parts[0]
                : '8',
          ) ??
          8,
      minute: int.tryParse(
            parts.length > 1
                ? parts[1]
                : '0',
          ) ??
          0,
    );

    final TimeOfDay? selectedTime =
        await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context)
                    .colorScheme
                    .copyWith(
              primary: primaryBrown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final String hour =
        selectedTime.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        selectedTime.minute
            .toString()
            .padLeft(2, '0');

    final Map<String, dynamic> updated =
        Map<String, dynamic>.from(
      current,
    );

    updated[isStart ? 'start' : 'end'] =
        '$hour:$minute';

    setState(() {
      _schedule[day] = updated;
    });
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(0xFFB9543A),
                  strokeWidth: 2.5,
                ),
              )
            : SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  16,
                  22,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildInformationCard(),

                    const SizedBox(height: 18),

                    ..._days.map(
                      (String day) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),
                          child:
                              _buildDayCard(day),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildSaveButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              behavior:
                  HitTestBehavior.opaque,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    size: 21,
                    color:
                        Color(0xFF30221E),
                  ),
                ),
              ),
            ),
          ),

          const Center(
            child: Text(
              'Jadwal Konsultasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF30221E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // INFORMATION CARD
  // ===============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: softOrange,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 21,
              color: Color(0xFF705044),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Atur Jadwal Praktik',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF30221E),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Tentukan hari dan jam konsultasi yang tersedia untuk pasien.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color:
                        Color(0xFF776C67),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DAY CARD
  // ===============================================================

  Widget _buildDayCard(
    String day,
  ) {
    final Map<String, dynamic> data =
        _getDayData(day);

    final bool active =
        data['active'] == true;

    final String start =
        data['start']?.toString() ??
            '08:00';

    final String end =
        data['end']?.toString() ??
            '16:00';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: active
                      ? softOrange
                      : const Color(
                          0xFFF0ECE9,
                        ),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons
                      .calendar_today_rounded,
                  size: 18,
                  color: active
                      ? const Color(
                          0xFF705044,
                        )
                      : const Color(
                          0xFF99918D,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: active
                        ? primaryBrown
                        : const Color(
                            0xFF776C67,
                          ),
                  ),
                ),
              ),

              Switch(
                value: active,
                onChanged: (bool value) {
                  _toggleDay(
                    day,
                    value,
                  );
                },
                activeColor:
                    const Color(
                  0xFF54C467,
                ),
                activeTrackColor:
                    const Color(
                  0xFFCDEFD2,
                ),
                inactiveThumbColor:
                    const Color(
                  0xFF9E9E9E,
                ),
                inactiveTrackColor:
                    const Color(
                  0xFFE5E2E0,
                ),
              ),
            ],
          ),

          if (active) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTimeButton(
                    label: 'Mulai',
                    time: start,
                    onTap: () {
                      _pickTime(
                        day: day,
                        isStart: true,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildTimeButton(
                    label: 'Selesai',
                    time: end,
                    onTap: () {
                      _pickTime(
                        day: day,
                        isStart: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 2),

            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Tidak ada jadwal praktik',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  color:
                      Color(0xFF9A918C),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===============================================================
  // TIME BUTTON
  // ===============================================================

  Widget _buildTimeButton({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Container(
        height: 58,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xFFFFF5EF),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color:
                const Color(0xFFF0D9CC),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: softOrange,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                size: 17,
                color:
                    Color(0xFF705044),
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      color:
                          Color(0xFF776C67),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    time,
                    style:
                        const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF493C37),
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

  // ===============================================================
  // SAVE BUTTON
  // ===============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            _isSaving
                ? null
                : _saveSchedule,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFFB9543A),
          disabledBackgroundColor:
              const Color(0xFFD9B9AD),
          foregroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Simpan Jadwal',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
      ),
    );
  }
}