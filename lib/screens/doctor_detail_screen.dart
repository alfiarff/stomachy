import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';
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
  // JAM YANG DIPILIH
  // ===============================================================

  String? _selectedTime;

  final Color backgroundColor =
      const Color(0xFFFFF5ED);

  final Color primaryBrown =
      const Color(0xFFB65339);

  final Color darkBrown =
      const Color(0xFF2F211D);

  final Color borderBrown =
      const Color(0xFFE76F51);

  // ===============================================================
  // DAFTAR JAM KONSULTASI
  // ===============================================================

  final List<String> consultationTimes = [
    '07.00',
    '10.00',
    '12.00',
    '15.00',
    '16.00',
    '17.00',
  ];

  // ===============================================================
  // NAVIGATION BOTTOM
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // BERANDA
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // SKRINING
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // DOKTER
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // PROFIL
    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  90,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================

                    _buildHeader(),

                    const SizedBox(height: 20),

                    // =================================================
                    // INFORMASI DOKTER
                    // =================================================

                    _buildDoctorProfile(),

                    const SizedBox(height: 20),

                    // =================================================
                    // INFORMASI PENGALAMAN
                    // =================================================

                    _buildDoctorInformation(),

                    const SizedBox(height: 18),

                    // =================================================
                    // TENTANG DOKTER
                    // =================================================

                    _buildSectionTitle(
                      'Tentang Dokter',
                    ),

                    const SizedBox(height: 8),

                    _buildAboutDoctor(),

                    const SizedBox(height: 20),

                    // =================================================
                    // JENIS LAYANAN
                    // =================================================

                    _buildSectionTitle(
                      'Jenis Layanan',
                    ),

                    const SizedBox(height: 10),

                    _buildServiceCard(),

                    const SizedBox(height: 20),

                    // =================================================
                    // PILIH JADWAL
                    // =================================================

                    _buildSectionTitle(
                      'Pilih Jadwal',
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Waktu yang dipilih adalah waktu mulai sesi konsultasi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // GRID JADWAL
                    // =================================================

                    _buildScheduleGrid(),

                    const SizedBox(height: 28),

                    // =================================================
                    // TOMBOL LANJUTKAN
                    // =================================================

                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =============================================================
      // BOTTOM NAVIGATION
      // =============================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
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
                alignment: Alignment.centerLeft,
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
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: darkBrown,
                ),
              ),
            ),
          ),

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFIL DOKTER
  // ===============================================================

  Widget _buildDoctorProfile() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        // FOTO
        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEDE5DF),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            widget.doctor.image,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Icon(
                Icons.person_rounded,
                size: 50,
                color: Color(0xFFB65339),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        // DATA DOKTER
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.doctor.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                widget.doctor.specialty,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          widget.doctor.status ==
                                  'Online'
                              ? const Color(
                                  0xFF5BE37A,
                                )
                              : const Color(
                                  0xFFFF3F3F,
                                ),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    widget.doctor.status,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.doctor.status ==
                                  'Online'
                              ? const Color(
                                  0xFF52D86F,
                                )
                              : const Color(
                                  0xFFFF3F3F,
                                ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFFFC107),
                  ),

                  const SizedBox(width: 3),

                  Text(
                    '${widget.doctor.rating} '
                    '(${widget.doctor.reviews} ulasan)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
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
  // INFORMASI DOKTER
  // ===============================================================

  Widget _buildDoctorInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderBrown,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInformationItem(
              icon:
                  Icons.medical_services_outlined,
              title: 'Pengalaman',
              value: '10 tahun',
            ),
          ),

          Expanded(
            child: _buildInformationItem(
              icon: Icons.school_outlined,
              title: 'Pendidikan',
              value: 'S1 Kedokteran',
            ),
          ),

          Expanded(
            child: _buildInformationItem(
              icon:
                  Icons.location_on_outlined,
              title: 'Lokasi',
              value: 'Jember',
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ITEM INFORMASI
  // ===============================================================

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
          color: primaryBrown,
        ),

        const SizedBox(height: 5),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primaryBrown,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }

  // ===============================================================
  // TENTANG DOKTER
  // ===============================================================

  Widget _buildAboutDoctor() {
    return const Text(
      'Dokter umum yang berpengalaman dalam menangani '
      'berbagai keluhan kesehatan sehari - hari dengan pendekatan '
      'yang ramah dan komunikatif.',
      style: TextStyle(
        fontSize: 11,
        height: 1.45,
        color: Colors.black,
      ),
    );
  }

  // ===============================================================
  // JENIS LAYANAN
  // ===============================================================

  Widget _buildServiceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderBrown,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE3D0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_rounded,
              size: 20,
              color: Color(0xFFB65339),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chat Konsultasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Konsultasi melalui chat dengan dokter secara '
                  'aman dan nyaman.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Colors.black,
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
  // GRID JADWAL
  // ===============================================================

  Widget _buildScheduleGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: consultationTimes.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final time =
            consultationTimes[index];

        final bool isSelected =
            _selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryBrown
                  : const Color(0xFFFFFCFA),
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: borderBrown,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.10,
                  ),
                  blurRadius: 3,
                  offset:
                      const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // TOMBOL LANJUTKAN
  // ===============================================================

  Widget _buildContinueButton() {
    final bool isEnabled =
        _selectedTime != null;

    return Center(
      child: SizedBox(
        width: 228,
        height: 42,
        child: ElevatedButton(
          onPressed: isEnabled
              ? _continueConsultation
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBrown,

            disabledBackgroundColor:
                const Color(0xFFD9B8AA),

            foregroundColor: Colors.white,

            disabledForegroundColor:
                Colors.white70,

            elevation:
                isEnabled ? 3 : 0,

            shadowColor:
                Colors.black.withOpacity(
              0.25,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                25,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Lanjutkan',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // LANJUT KE CHAT
  // ===============================================================

  void _continueConsultation() {
    if (_selectedTime == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConsultationChatScreen(
          doctorName:
              widget.doctor.name,

          specialty:
              widget.doctor.specialty,

          doctorImage:
              widget.doctor.image,

          selectedTime:
              _selectedTime!,

          rating:
              widget.doctor.rating,

          reviews:
              widget.doctor.reviews,
        ),
      ),
    );
  }
}