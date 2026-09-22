import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'screening_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'doctor_detail_screen.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int _selectedIndex = 2;

  bool _showAvailableOnly = false;
  String _searchQuery = '';

  final Color backgroundColor = const Color(0xFFFFF5ED);
  final Color primaryBrown = const Color(0xFFB65339);
  final Color darkBrown = const Color(0xFF2F211D);
  final Color borderBrown = const Color(0xFFE76F51);

  // ================================================================
  // DATA DOKTER
  // ================================================================

  final List<DoctorData> doctors = [
    DoctorData(
      name: 'dr. Amanda Putri',
      specialty: 'Dokter Umum',
      status: 'Online',
      rating: '4.9',
      reviews: '128',
      image: 'assets/images/dokter_amanda.jpeg',
      schedules: ['10.00', '13.00', '19.00'],
    ),
    DoctorData(
      name: 'dr. Jefri Nichol',
      specialty: 'Dokter Umum',
      status: 'Offline',
      rating: '4.8',
      reviews: '96',
      image: 'assets/images/dokter_jefri.jpeg',
      schedules: ['09.00', '14.00', '20.00'],
    ),
    DoctorData(
      name: 'dr. Karina Lestari',
      specialty: 'Dokter Umum',
      status: 'Offline',
      rating: '4.8',
      reviews: '87',
      image: 'assets/images/dokter_karina.jpeg',
      schedules: ['11.00', '16.00', '21.00'],
    ),
  ];

  // ================================================================
  // FILTER DATA
  // ================================================================

  List<DoctorData> get filteredDoctors {
    return doctors.where((doctor) {
      final query = _searchQuery.toLowerCase().trim();

      final matchesSearch =
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);

      final matchesAvailability =
          !_showAvailableOnly || doctor.status == 'Online';

      return matchesSearch && matchesAvailability;
    }).toList();
  }

  // ================================================================
  // NAVIGATION
  // ================================================================

  void _onNavigationTap(int index) {
    // Dokter
    if (index == 2) {
      return;
    }

    // Beranda
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // Skrining
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // Edukasi
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // Profil
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

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
                  14,
                  10,
                  14,
                  90,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // SEARCH
                    _buildSearchBar(),

                    const SizedBox(height: 20),

                    // FILTER
                    _buildFilterButtons(),

                    const SizedBox(height: 20),

                    // DOCTOR LIST
                    ...filteredDoctors.map(
                      (doctor) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: _buildDoctorCard(doctor),
                      ),
                    ),

                    if (filteredDoctors.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ================================================================
      // BOTTOM NAVIGATION
      // ================================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
        ),

        Expanded(
          child: Center(
            child: Text(
              'Konsultasi Dokter',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
          ),
        ),

        const SizedBox(width: 40),
      ],
    );
  }

  // ================================================================
  // SEARCH BAR
  // ================================================================

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderBrown,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: Colors.black,
          ),
          hintText: 'Cari dokter atau spesialis',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFF8C8582),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FILTER BUTTON
  // ================================================================

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showAvailableOnly = false;
              });
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: !_showAvailableOnly
                    ? primaryBrown
                    : const Color(0xFFFFFCFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderBrown,
                  width: 0.8,
                ),
                boxShadow: [
                  if (!_showAvailableOnly)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  'Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_showAvailableOnly
                        ? Colors.white
                        : darkBrown,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showAvailableOnly = true;
              });
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: _showAvailableOnly
                    ? primaryBrown
                    : const Color(0xFFFFFCFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderBrown,
                  width: 0.8,
                ),
                boxShadow: [
                  if (_showAvailableOnly)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  'Tersedia Hari Ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _showAvailableOnly
                        ? Colors.white
                        : darkBrown,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DOCTOR CARD
  // ================================================================

  Widget _buildDoctorCard(DoctorData doctor) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DoctorDetailScreen(
                doctor: doctor,
              ),
            ),
          );
        },
        child: Container(
        width: double.infinity,
        height: 172,
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderBrown,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  _buildDoctorImage(doctor.image),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          doctor.status,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                doctor.status == 'Online'
                                    ? const Color(
                                        0xFF18C85A,
                                      )
                                    : const Color(
                                        0xFFFF3F3F,
                                      ),
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Color(0xFFFFC107),
                            ),

                            const SizedBox(width: 3),

                            Expanded(
                              child: Text(
                                '${doctor.rating} '
                                '(${doctor.reviews} ulasan)',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          doctor.status == 'Online'
                              ? 'Tersedia Hari Ini'
                              : 'Tidak Tersedia Hari Ini',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                doctor.status == 'Online'
                                    ? const Color(
                                        0xFF18C85A,
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: doctor.schedules.map(
                (time) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: _buildScheduleButton(time),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
  // ================================================================
  // FOTO DOKTER
  // ================================================================

    Widget _buildDoctorImage(String imagePath) {
    return Container(
        width: 62,
        height: 62,
        decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEDE5DF),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
            return const Icon(
            Icons.person_rounded,
            size: 42,
            color: Color(0xFFB65339),
            );
        },
        ),
    );
    }

  // ================================================================
  // SCHEDULE BUTTON
  // ================================================================

    Widget _buildScheduleButton(String time) {
    return GestureDetector(
        onTap: () {
        _showScheduleDialog(time);
        },
        child: Container(
        width: 54,
        height: 30,
        decoration: BoxDecoration(
            color: const Color(0xFFFFFCFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
            color: borderBrown,
            width: 0.8,
            ),
            boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 3,
                offset: const Offset(0, 2),
            ),
            ],
        ),
        child: Center(
            child: Text(
            time,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
            ),
            ),
        ),
        ),
    );
    }

  // ================================================================
  // DIALOG PILIH JADWAL
  // ================================================================

  void _showScheduleDialog(String time) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Pilih Jadwal Konsultasi',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah kamu ingin memilih jadwal pukul $time?',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Jadwal pukul $time dipilih.',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Pilih',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // EMPTY SEARCH
  // ================================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderBrown,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 45,
            color: primaryBrown,
          ),

          const SizedBox(height: 12),

          const Text(
            'Dokter tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Coba cari dengan nama dokter atau spesialis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MODEL DATA DOKTER
// ================================================================

class DoctorData {
  final String name;
  final String specialty;
  final String status;
  final String rating;
  final String reviews;
  final String image;
  final List<String> schedules;

  DoctorData({
    required this.name,
    required this.specialty,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.schedules,
  });
}