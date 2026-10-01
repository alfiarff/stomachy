import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/stomachy_card.dart';
import '../widgets/bottom_navigation.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'consultation_chat_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorData doctor;

  const DoctorDetailScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDetailScreen> createState() =>
      _DoctorDetailScreenState();
}

class _DoctorDetailScreenState
    extends State<DoctorDetailScreen> {
  int _selectedIndex = 2;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF5ED);

  final Color primaryBrown =
      const Color(0xFFB65339);

  final Color darkBrown =
      const Color(0xFF2F211D);

  final Color borderBrown =
      const Color(0xFFE76F51);

  // ===============================================================
  // DATA DOKTER
  // ===============================================================

  Map<String, dynamic>? _doctorData;

  bool _isLoadingDoctor = true;
  bool _isCreatingConsultation = false;

  // ===============================================================
  // JADWAL DOKTER
  // ===============================================================

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  String? _selectedDay;
  String? _selectedTime;

  List<DoctorScheduleSlot> _scheduleSlots = [];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  // ===============================================================
  // LOAD DATA DOKTER DARI FIRESTORE
  // ===============================================================

  Future<void> _loadDoctorData() async {
    try {
      final DocumentSnapshot<
          Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.doctor.id)
              .get();

      if (!mounted) {
        return;
      }

      if (document.exists) {
        final Map<String, dynamic> data =
            document.data() ?? {};

        setState(() {
          _doctorData = data;
          _isLoadingDoctor = false;
        });

        _loadDoctorSchedule(data);
      } else {
        setState(() {
          _doctorData = {
            'name': widget.doctor.name,
            'specialization':
                widget.doctor.specialty,
            'status': widget.doctor.status,
            'experience':
                widget.doctor.experience,
            'education':
                widget.doctor.education,
            'location':
                widget.doctor.location,
            'photoBase64':
                widget.doctor.photoBase64,
            'photoUrl':
                widget.doctor.photoUrl,
          };

          _isLoadingDoctor = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _doctorData = {
          'name': widget.doctor.name,
          'specialization':
              widget.doctor.specialty,
          'status': widget.doctor.status,
          'experience':
              widget.doctor.experience,
          'education':
              widget.doctor.education,
          'location':
              widget.doctor.location,
          'photoBase64':
              widget.doctor.photoBase64,
          'photoUrl':
              widget.doctor.photoUrl,
        };

        _isLoadingDoctor = false;
      });

      _showMessage(
        'Data dokter tidak dapat dimuat.',
      );
    }
  }

  // ===============================================================
  // LOAD JADWAL DOKTER
  // ===============================================================

  void _loadDoctorSchedule(
    Map<String, dynamic> data,
  ) {
    final dynamic scheduleData =
        data['doctorSchedule'];

    if (scheduleData is! Map) {
      setState(() {
        _scheduleSlots = [];
      });
      return;
    }

    final List<DoctorScheduleSlot> slots = [];

    for (final String day in _days) {
      final dynamic dayData =
          scheduleData[day];

      if (dayData is! Map) {
        continue;
      }

      final bool active =
          dayData['active'] == true;

      if (!active) {
        continue;
      }

      final String start =
          (dayData['start'] ?? '')
              .toString()
              .trim();

      final String end =
          (dayData['end'] ?? '')
              .toString()
              .trim();

      if (start.isEmpty ||
          end.isEmpty) {
        continue;
      }

      final List<String> times =
          _generateTimeSlots(
        start,
        end,
      );

      for (final String time in times) {
        slots.add(
          DoctorScheduleSlot(
            day: day,
            time: time,
          ),
        );
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _scheduleSlots = slots;
    });
  }

  // ===============================================================
  // GENERATE JAM DARI JADWAL DOKTER
  // ===============================================================

  List<String> _generateTimeSlots(
    String start,
    String end,
  ) {
    final int? startMinutes =
        _timeToMinutes(start);

    final int? endMinutes =
        _timeToMinutes(end);

    if (startMinutes == null ||
        endMinutes == null ||
        startMinutes >= endMinutes) {
      return [];
    }

    final List<String> slots = [];

    int current =
        startMinutes;

    while (current < endMinutes) {
      slots.add(
        _minutesToTime(current),
      );

      current += 60;
    }

    return slots;
  }

  int? _timeToMinutes(
    String value,
  ) {
    final String normalized =
        value.replaceAll('.', ':');

    final List<String> parts =
        normalized.split(':');

    if (parts.length != 2) {
      return null;
    }

    final int? hour =
        int.tryParse(parts[0]);

    final int? minute =
        int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return (hour * 60) + minute;
  }

  String _minutesToTime(
    int minutes,
  ) {
    final int hour =
        minutes ~/ 60;

    final int minute =
        minutes % 60;

    return '${hour.toString().padLeft(2, '0')}.'
        '${minute.toString().padLeft(2, '0')}';
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(
    int index,
  ) {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const EdukasiScreen(),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ProfileScreen(),
        ),
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: _isLoadingDoctor
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFFB65339),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child:
                        SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        20,
                        8,
                        20,
                        90,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          // HEADER
                          _buildHeader(),

                          const SizedBox(
                            height: 20,
                          ),

                          // PROFIL DOKTER
                          _buildDoctorProfile(),

                          const SizedBox(
                            height: 20,
                          ),

                          // INFORMASI DOKTER
                          _buildDoctorInformation(),

                          const SizedBox(
                            height: 18,
                          ),

                          // TENTANG DOKTER
                          _buildSectionTitle(
                            'Tentang Dokter',
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          _buildAboutDoctor(),

                          const SizedBox(
                            height: 20,
                          ),

                          // JENIS LAYANAN
                          _buildSectionTitle(
                            'Jenis Layanan',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          _buildServiceCard(),

                          const SizedBox(
                            height: 20,
                          ),

                          // PILIH JADWAL
                          _buildSectionTitle(
                            'Pilih Jadwal',
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          const Text(
                            'Pilih hari dan waktu yang tersedia untuk konsultasi.',
                            style:
                                TextStyle(
                              fontFamily:
                                  'Nunito',
                              fontSize: 11,
                              color:
                                  Colors.black,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          _buildSchedule(),

                          const SizedBox(
                            height: 28,
                          ),

                          // BUTTON
                          _buildContinueButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),

      bottomNavigationBar:
          AppBottomNavigation(
        selectedIndex:
            _selectedIndex,
        onItemSelected:
            _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Detail Dokter',
                style:
                    TextStyle(
                  fontFamily:
                      'Fredoka',
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      darkBrown,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 42,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFIL DOKTER
  // ===============================================================

  Widget _buildDoctorProfile() {
final String name =
    'dr. ${_getDoctorValue(
  'name',
  widget.doctor.name,
)}';

    final String specialty =
        _getDoctorValue(
      'specialization',
      widget.doctor.specialty,
    );

    final String status =
        _getDoctorValue(
      'status',
      widget.doctor.status,
    );

    final bool isOnline =
        status.toLowerCase() ==
            'online';

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        _buildDoctorImage(),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Colors.black,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                specialty,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 11,
                  color:
                      Colors.black,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(
                      color: isOnline
                          ? const Color(
                              0xFF5BE37A,
                            )
                          : const Color(
                              0xFFFF3F3F,
                            ),
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    isOnline
                        ? 'Online'
                        : 'Offline',
                    style:
                        TextStyle(
                      fontFamily:
                          'Nunito',
                      fontSize: 11,
                      color: isOnline
                          ? const Color(
                              0xFF52D86F,
                            )
                          : const Color(
                              0xFFFF3F3F,
                            ),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // FOTO DOKTER
  // ===============================================================

  Widget _buildDoctorImage() {
    final String base64Image =
        _getDoctorValue(
      'photoBase64',
      widget.doctor.photoBase64 ??
          '',
    );

    if (base64Image.isNotEmpty) {
      try {
        final Uint8List bytes =
            base64Decode(
          base64Image,
        );

        if (bytes.isNotEmpty) {
          return Container(
            width: 78,
            height: 78,
            decoration:
                const BoxDecoration(
              shape:
                  BoxShape.circle,
              color:
                  Color(0xFFEDE5DF),
            ),
            clipBehavior:
                Clip.antiAlias,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return _fallbackDoctorIcon();
              },
            ),
          );
        }
      } catch (_) {}
    }

    final String photoUrl =
        _getDoctorValue(
      'photoUrl',
      widget.doctor.photoUrl ??
          '',
    );

    if (photoUrl.isNotEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration:
            const BoxDecoration(
          shape:
              BoxShape.circle,
          color:
              Color(0xFFEDE5DF),
        ),
        clipBehavior:
            Clip.antiAlias,
        child:
            Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) {
            return _fallbackDoctorIcon();
          },
        ),
      );
    }

    return Container(
      width: 78,
      height: 78,
      decoration:
          const BoxDecoration(
        shape:
            BoxShape.circle,
        color:
            Color(0xFFEDE5DF),
      ),
      child:
          _fallbackDoctorIcon(),
    );
  }

  Widget _fallbackDoctorIcon() {
    return const Icon(
      Icons.person_rounded,
      size: 50,
      color:
          Color(0xFFB65339),
    );
  }

  // ===============================================================
  // INFORMASI DOKTER
  // ===============================================================

  Widget _buildDoctorInformation() {
    final String experience =
        _getDoctorValue(
      'experience',
      '-',
    );

    final String education =
        _getDoctorValue(
      'education',
      '-',
    );

    final String location =
        _getDoctorValue(
      'location',
      '-',
    );

    return StomachyCard(
      color:
          const Color(0xFFFFFCFA),
      radius: 20,
      useBorder: false,
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child:
                _buildInformationItem(
              icon:
                  Icons.medical_services_outlined,
              title: 'Pengalaman',
              value: experience,
            ),
          ),

          Expanded(
            child:
                _buildInformationItem(
              icon:
                  Icons.school_outlined,
              title: 'Pendidikan',
              value: education,
            ),
          ),

          Expanded(
            child:
                _buildInformationItem(
              icon:
                  Icons.location_on_outlined,
              title: 'Lokasi',
              value: location,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 23,
          color:
              primaryBrown,
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          title,
          textAlign:
              TextAlign.center,
          style:
              TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            color:
                primaryBrown,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          value,
          textAlign:
              TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 11,
            color:
                Colors.black,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // JUDUL SECTION
  // ===============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontFamily:
            'Nunito',
        fontSize: 12,
        fontWeight:
            FontWeight.w700,
        color:
            Colors.black,
      ),
    );
  }

  // ===============================================================
  // TENTANG DOKTER
  // MANUAL
  // ===============================================================

  Widget _buildAboutDoctor() {
    return const Text(
      'Dokter umum yang berpengalaman dalam menangani berbagai '
      'keluhan kesehatan sehari-hari dengan pendekatan yang '
      'ramah dan komunikatif.',
      style:
          TextStyle(
        fontFamily:
            'Nunito',
        fontSize: 11,
        height: 1.45,
        color:
            Colors.black,
      ),
    );
  }

  // ===============================================================
  // JENIS LAYANAN
  // MANUAL
  // ===============================================================

  Widget _buildServiceCard() {
    return StomachyCard(
      color:
          const Color(0xFFFFFCFA),
      radius: 20,
      useBorder: false,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFFE3D0),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.chat_rounded,
              size: 20,
              color:
                  Color(0xFFB65339),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: const [
                Text(
                  'Chat Konsultasi',
                  style:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Colors.black,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'Konsultasi melalui chat dengan dokter secara aman dan nyaman.',
                  style:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 11,
                    height: 1.35,
                    color:
                        Colors.black,
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
  // PILIH JADWAL
  // MENGIKUTI JADWAL DOKTER DI FIRESTORE
  // ===============================================================

  Widget _buildSchedule() {
    if (_scheduleSlots.isEmpty) {
      return StomachyCard(
        color:
            const Color(0xFFFFFCFA),
        radius: 18,
        useBorder: false,
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 25,
              color:
                  Color(0xFFB65339),
            ),

            const SizedBox(
              width: 10,
            ),

            const Expanded(
              child: Text(
                'Dokter belum mengatur jadwal konsultasi.',
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 11,
                  color:
                      Color(0xFF777777),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final List<String>
        availableDays =
        _scheduleSlots
            .map(
              (slot) => slot.day,
            )
            .toSet()
            .toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =========================================================
        // HARI
        // =========================================================

        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                availableDays.length,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(
              width: 8,
            ),
            itemBuilder:
                (context, index) {
              final String day =
                  availableDays[index];

              final bool selected =
                  _selectedDay == day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay =
                        day;
                    _selectedTime =
                        null;
                  });
                },
                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 17,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? primaryBrown
                        : const Color(
                            0xFFFFFCFA,
                          ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      19,
                    ),
                    border:
                        Border.all(
                      color:
                          borderBrown,
                      width: 1,
                    ),
                  ),
                  child:
                      Center(
                    child: Text(
                      day,
                      style:
                          TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize:
                            12,
                        fontWeight:
                            FontWeight
                                .w600,
                        color: selected
                            ? Colors
                                .white
                            : Colors
                                .black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        // =========================================================
        // JAM
        // =========================================================

        if (_selectedDay == null)
          const Text(
            'Pilih hari terlebih dahulu.',
            style:
                TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 11,
              color:
                  Color(0xFF777777),
            ),
          )
        else
          _buildTimeGrid(),
      ],
    );
  }

  // ===============================================================
  // GRID JAM
  // ===============================================================

  Widget _buildTimeGrid() {
    final List<
            DoctorScheduleSlot>
        daySlots =
        _scheduleSlots
            .where(
              (slot) =>
                  slot.day ==
                  _selectedDay,
            )
            .toList();

    if (daySlots.isEmpty) {
      return const Text(
        'Tidak ada jadwal pada hari ini.',
        style:
            TextStyle(
          fontFamily:
              'Nunito',
          fontSize: 11,
          color:
              Color(0xFF777777),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          daySlots.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder:
          (context, index) {
        final String time =
            daySlots[index].time;

        final bool isSelected =
            _selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime =
                  time;
            });
          },
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            decoration:
                BoxDecoration(
              color: isSelected
                  ? primaryBrown
                  : const Color(
                      0xFFFFFCFA,
                    ),
              borderRadius:
                  BorderRadius
                      .circular(
                10,
              ),
              border:
                  Border.all(
                color:
                    borderBrown,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors
                      .black
                      .withOpacity(
                    0.08,
                  ),
                  blurRadius: 4,
                  offset:
                      const Offset(
                    0,
                    2,
                  ),
                ),
              ],
            ),
            child:
                Center(
              child: Text(
                time,
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize:
                      11,
                  fontWeight:
                      FontWeight
                          .w600,
                  color: isSelected
                      ? Colors
                          .white
                      : Colors
                          .black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // BUTTON LANJUTKAN
  // ===============================================================

  Widget _buildContinueButton() {
    final bool isEnabled =
        _selectedDay != null &&
            _selectedTime != null &&
            !_isCreatingConsultation;

    return Center(
      child: SizedBox(
        width: 228,
        height: 42,
        child:
            ElevatedButton(
          onPressed: isEnabled
              ? _continueConsultation
              : null,
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                primaryBrown,
            disabledBackgroundColor:
                const Color(
              0xFFD9B8AA,
            ),
            foregroundColor:
                Colors.white,
            disabledForegroundColor:
                Colors.white70,
            elevation:
                isEnabled ? 3 : 0,
            shadowColor:
                Colors.black
                    .withOpacity(
              0.25,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                25,
              ),
            ),
          ),
          child:
              _isCreatingConsultation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          'Lanjutkan',
                          style:
                              TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // ===============================================================
  // BUAT KONSULTASI
  // ===============================================================

  Future<void>
      _continueConsultation() async {
    if (_selectedDay == null ||
        _selectedTime == null) {
      return;
    }

    final User? user =
        FirebaseAuth.instance
            .currentUser;

    if (user == null) {
      _showMessage(
        'Silakan login terlebih dahulu.',
      );
      return;
    }

    final String status =
        _getDoctorValue(
      'status',
      widget.doctor.status,
    );

    if (status.toLowerCase() !=
        'online') {
      _showMessage(
        'Dokter sedang offline.',
      );
      return;
    }

    if (_isCreatingConsultation) {
      return;
    }

    setState(() {
      _isCreatingConsultation =
          true;
    });

    try {
      // ===========================================================
      // DATA USER
      // ===========================================================

      final DocumentSnapshot<
          Map<String, dynamic>>
          userDocument =
          await FirebaseFirestore
              .instance
              .collection('users')
              .doc(user.uid)
              .get();

      final Map<String, dynamic>
          userData =
          userDocument.data() ??
              {};

      final String userName =
          (userData['name'] ??
                  user.displayName ??
                  'Pasien')
              .toString()
              .trim();

      // ===========================================================
      // DATA DOKTER
      // ===========================================================

      final String doctorName =
          _getDoctorValue(
        'name',
        widget.doctor.name,
      );

      final String specialty =
          _getDoctorValue(
        'specialization',
        widget.doctor.specialty,
      );

      // ===========================================================
      // BUAT CONSULTATION
      // ===========================================================

      final DocumentReference<
          Map<String, dynamic>>
          consultationReference =
          FirebaseFirestore
              .instance
              .collection(
                'consultations',
              )
              .doc();

      await consultationReference
          .set({
        'userId':
            user.uid,

        'doctorId':
            widget.doctor.id,

        'userName':
            userName.isEmpty
                ? 'Pasien'
                : userName,

        'doctorName':
            doctorName,

        'specialty':
            specialty,

        'consultationDay':
            _selectedDay,

        'consultationTime':
            _selectedTime,

        'consultationDate':
            _selectedDay,

        'status':
            'active',

        'createdAt':
            FieldValue
                .serverTimestamp(),

        'updatedAt':
            FieldValue
                .serverTimestamp(),

        'lastMessage':
            '',

        'lastSenderId':
            '',
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isCreatingConsultation =
            false;
      });

      // ===========================================================
      // MASUK KE CHAT
      // ===========================================================

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConsultationChatScreen(
            consultationId:
                consultationReference.id,
            doctorName:
                doctorName,
            specialty:
                specialty,
            doctorImage:
                widget.doctor.photoBase64 ??
                    '',
            selectedTime:
                _selectedTime!,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCreatingConsultation =
            false;
      });

      _showMessage(
        'Gagal membuat konsultasi. Silakan coba lagi.',
      );
    }
  }

  // ===============================================================
  // AMBIL DATA DOKTER
  // ===============================================================

  String _getDoctorValue(
    String key,
    String fallback,
  ) {
    final dynamic value =
        _doctorData?[key];

    if (value == null) {
      return fallback;
    }

    final String result =
        value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 11,
          ),
        ),
        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }
}

// ===============================================================
// MODEL SLOT JADWAL
// ===============================================================

class DoctorScheduleSlot {
  final String day;
  final String time;

  DoctorScheduleSlot({
    required this.day,
    required this.time,
  });
}