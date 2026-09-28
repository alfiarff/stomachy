import 'package:flutter/material.dart';

import 'doctorr_home_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() =>
      _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState
    extends State<DoctorPatientsScreen> {
  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  final Color primaryBrown =
      const Color(0xFFB65339);

  final Color navigationBrown =
      const Color(0xFF93432F);

  final Color navigationBackground =
      const Color(0xFFFFE5D5);

  // ===============================================================
  // SEARCH
  // ===============================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  // ===============================================================
  // DATA PASIEN
  // ===============================================================

  static final List<Map<String, dynamic>> patients = [
    {
      'name': 'Jerome Polin',
      'age': 21,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFE8E8E8),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF343434),
    },
    {
      'name': 'Nadia Putri',
      'age': 20,
      'gender': 'Perempuan',
      'genderIcon': Icons.female_rounded,
      'genderColor': Color(0xFFE85C91),
      'avatarColor': Color(0xFFFFE4E1),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Raka Wijaya',
      'age': 22,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFE6E1FF),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Sinta Maharani',
      'age': 23,
      'gender': 'Perempuan',
      'genderIcon': Icons.female_rounded,
      'genderColor': Color(0xFFE85C91),
      'avatarColor': Color(0xFFFFEBD9),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Dimas Arya',
      'age': 20,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFFFE8E0),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
  ];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text
                .trim()
                .toLowerCase();
      });
    });
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===============================================================
  // FILTER PASIEN
  // ===============================================================

  List<Map<String, dynamic>> get filteredPatients {
    if (_searchQuery.isEmpty) {
      return patients;
    }

    return patients.where((patient) {
      final String name =
          patient['name']
              .toString()
              .toLowerCase();

      return name.contains(_searchQuery);
    }).toList();
  }

  // ===============================================================
  // BUKA DETAIL PASIEN
  // ===============================================================

  void _openPatientDetail(
    Map<String, dynamic> patient,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildPatientDetailSheet(
          patient,
        );
      },
    );
  }

  // ===============================================================
  // BUKA CHAT PASIEN
  // ===============================================================

  void _openPatientChat(
    Map<String, dynamic> patient,
  ) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DoctorPatientChatScreen(
          patient: patient,
        ),
      ),
    );
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    // -------------------------------------------------------------
    // BERANDA
    // -------------------------------------------------------------

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorHomeScreen(),
        ),
      );

      return;
    }

    // -------------------------------------------------------------
    // PASIEN
    // -------------------------------------------------------------

    if (index == 1) {
      return;
    }

    // -------------------------------------------------------------
    // CHAT
    // -------------------------------------------------------------

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorChatScreen(),
        ),
      );

      return;
    }

    // -------------------------------------------------------------
    // PROFIL
    // -------------------------------------------------------------

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorProfileScreen(),
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
    final List<Map<String, dynamic>> visiblePatients =
        filteredPatients;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------------------------------
            // HEADER
            // -------------------------------------------------------

            _buildHeader(),

            const SizedBox(
              height: 10,
            ),

            // -------------------------------------------------------
            // SEARCH
            // -------------------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                35,
                0,
                35,
                16,
              ),
              child: _buildSearchBar(),
            ),

            // -------------------------------------------------------
            // LIST PASIEN
            // -------------------------------------------------------

            Expanded(
              child: visiblePatients.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        33,
                        0,
                        33,
                        20,
                      ),
                      itemCount:
                          visiblePatients.length,
                      itemBuilder:
                          (context, index) {
                        final patient =
                            visiblePatients[index];

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child:
                              _buildPatientCard(
                            patient,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // -------------------------------------------------------------
      // BOTTOM NAVIGATION
      // -------------------------------------------------------------

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        28,
        10,
        28,
        0,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // -------------------------------------------------------
            // BACK
            // -------------------------------------------------------

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  const SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    size: 25,
                    color:
                        Color(0xFFB65339),
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------
            // TITLE
            // -------------------------------------------------------

            const Expanded(
              child: Center(
                child: Text(
                  'Daftar Pasien',
                  style:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 40,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // SEARCH BAR
  // ===============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(22),
        border:
            Border.all(
          color:
              const Color(0xFFE76F51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.12,
            ),
            blurRadius: 4,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller:
            _searchController,
        textAlignVertical:
            TextAlignVertical.center,
        style:
            const TextStyle(
          fontFamily:
              'Nunito',
          fontSize: 14,
          color:
              Colors.black,
        ),
        decoration:
            const InputDecoration(
          border:
              InputBorder.none,
          prefixIcon:
              Icon(
            Icons.search_rounded,
            size: 24,
            color:
                Colors.black,
          ),
          hintText:
              'Cari nama pasien...',
          hintStyle:
              TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 14,
            color:
                Color(0xFF8C8582),
          ),
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PATIENT CARD
  // ===============================================================

  Widget _buildPatientCard(
    Map<String, dynamic> patient,
  ) {
    return GestureDetector(
      onTap: () {
        _openPatientDetail(patient);
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.035,
              ),
              blurRadius: 7,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // -------------------------------------------------------
            // AVATAR
            // -------------------------------------------------------

            Container(
              width: 58,
              height: 58,
              decoration:
                  BoxDecoration(
                color:
                    patient[
                        'avatarColor'],
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                patient[
                    'avatarIcon'],
                size: 36,
                color:
                    patient[
                        'avatarIconColor'],
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            // -------------------------------------------------------
            // DATA PASIEN
            // -------------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name']
                        .toString(),
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

                  Row(
                    children: [
                      Text(
                        '${patient['age']} Tahun',
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w500,
                          color:
                              Color(
                            0xFF777777,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Container(
                        width: 4,
                        height: 4,
                        decoration:
                            const BoxDecoration(
                          color:
                              Color(
                            0xFF777777,
                          ),
                          shape:
                              BoxShape.circle,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Icon(
                        patient[
                            'genderIcon'],
                        size: 15,
                        color:
                            patient[
                                'genderColor'],
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Flexible(
                        child: Text(
                          patient[
                              'gender'],
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w500,
                            color:
                                Color(
                              0xFF777777,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            // -------------------------------------------------------
            // CHEVRON
            // -------------------------------------------------------

            const Icon(
              Icons
                  .chevron_right_rounded,
              size: 27,
              color:
                  Color(0xFFB65339),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // DETAIL PASIEN
  // ===============================================================

  Widget _buildPatientDetailSheet(
    Map<String, dynamic> patient,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        24,
        14,
        24,
        25,
      ),
      decoration:
          const BoxDecoration(
        color:
            Color(0xFFFFF5EF),
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          // ---------------------------------------------------------
          // HANDLE
          // ---------------------------------------------------------

          Container(
            width: 45,
            height: 5,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFD9C7BF,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ---------------------------------------------------------
          // AVATAR
          // ---------------------------------------------------------

          Container(
            width: 80,
            height: 80,
            decoration:
                BoxDecoration(
              color:
                  patient[
                      'avatarColor'],
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              patient[
                  'avatarIcon'],
              size: 48,
              color:
                  patient[
                      'avatarIconColor'],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ---------------------------------------------------------
          // NAMA
          // ---------------------------------------------------------

          Text(
            patient['name']
                .toString(),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF5A2017),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          // ---------------------------------------------------------
          // UMUR + GENDER
          // ---------------------------------------------------------

          Text(
            '${patient['age']} Tahun  •  ${patient['gender']}',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 12,
              fontWeight:
                  FontWeight.w500,
              color:
                  Color(0xFF777777),
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ---------------------------------------------------------
          // CHAT
          // ---------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                ElevatedButton.icon(
              onPressed: () {
                _openPatientChat(
                  patient,
                );
              },
              icon:
                  const Icon(
                Icons
                    .chat_bubble_rounded,
                size: 20,
                color:
                    Colors.white,
              ),
              label:
                  const Text(
                'Chat dengan Pasien',
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Colors.white,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryBrown,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // ---------------------------------------------------------
          // TUTUP
          // ---------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 44,
            child:
                TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'Tutup',
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF8A4A3A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFFE8DD),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons
                  .person_search_rounded,
              size: 38,
              color:
                  Color(0xFFB65339),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'Pasien tidak ditemukan',
            style:
                TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
              color:
                  Colors.black,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Text(
            'Coba cari nama pasien yang lain.',
            style:
                TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 11,
              color:
                  Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 94,
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            const BorderRadius.only(
          topLeft:
              Radius.circular(30),
          topRight:
              Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 7,
        ),
        child: Row(
          children: [
            _buildNavigationItem(
              index: 0,
              icon:
                  Icons.home_rounded,
              label: 'Beranda',
            ),

            _buildNavigationItem(
              index: 1,
              icon:
                  Icons.groups_rounded,
              label: 'Pasien',
            ),

            _buildNavigationItem(
              index: 2,
              icon:
                  Icons
                      .chat_bubble_outline_rounded,
              label: 'Chat',
            ),

            _buildNavigationItem(
              index: 3,
              icon:
                  Icons
                      .person_outline_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // NAVIGATION ITEM
  // ===============================================================

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected =
        index == 1;

    return Expanded(
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: () {
          _onNavigationTap(index);
        },
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          margin:
              const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          decoration:
              BoxDecoration(
            color: isSelected
                ? navigationBackground
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              27,
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color:
                    navigationBrown,
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                label,
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  fontWeight:
                      isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                  color:
                      const Color(
                    0xFF784033,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}