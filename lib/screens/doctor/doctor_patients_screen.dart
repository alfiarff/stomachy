import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/doctor_bottom_navigation.dart';
import 'doctorr_home_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_profile_screen.dart';
class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({
    super.key,
  });
  @override
  State<DoctorPatientsScreen> createState() =>
      _DoctorPatientsScreenState();
}
class _DoctorPatientsScreenState
    extends State<DoctorPatientsScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  String _searchQuery = '';
  final Map<String, String> _genderCache = {};
  static const Color backgroundColor =
      Color(0xFFFFF5EF);
  static const Color primaryBrown =
      Color(0xFFB65339);
  static const Color cardColor =
      Color(0xFFFFFCF9);
  static const Color searchColor =
      Color(0xFFFFFCFA);
  static const Color softOrange =
      Color(0xFFFFE3D1);
  static const Color greyText =
      Color(0xFF8C8582);
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ===============================================================
  // STREAM DATA PASIEN
  // ===============================================================
  Stream<QuerySnapshot<Map<String, dynamic>>>
      _patientStream() {
    final User? doctor =
        FirebaseAuth.instance.currentUser;
    if (doctor == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
       .collection('consultations')
       .where(
          'doctorId',
          isEqualTo: doctor.uid,
        )
       .snapshots();
  }
  // ===============================================================
  // BENTUK DAFTAR PASIEN
  // ===============================================================
  List<Map<String, dynamic>> _buildPatientList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, Map<String, dynamic>>
        patientsByUser = {};
    for (final QueryDocumentSnapshot<
        Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data =
          document.data();
      final String status =
          (data['status'] ?? 'active')
             .toString()
             .toLowerCase();
      if (status != 'active' && status != 'booked' && status != 'completed') {
        continue;
      }
      final String userId =
          (data['userId'] ?? '').toString();
      if (userId.isEmpty) {
        continue;
      }
      final Map<String, dynamic> patient = {
       ...data,
        'consultationId': document.id,
      };
      final Map<String, dynamic>? existing =
          patientsByUser[userId];
      if (existing == null) {
        patientsByUser[userId] = patient;
        continue;
      }
      final Timestamp? existingUpdatedAt =
          existing['updatedAt'] is Timestamp
              ? existing['updatedAt'] as Timestamp
              : null;
      final Timestamp? currentUpdatedAt =
          data['updatedAt'] is Timestamp
              ? data['updatedAt'] as Timestamp
              : null;
      if (currentUpdatedAt != null &&
          (existingUpdatedAt == null ||
              currentUpdatedAt.compareTo(
                    existingUpdatedAt,
                  ) >
                  0)) {
        patientsByUser[userId] = patient;
      }
    }
    final List<Map<String, dynamic>> patients =
        patientsByUser.values.toList();
    patients.sort(
      (a, b) {
        final Timestamp? aTime =
            a['updatedAt'] is Timestamp
                ? a['updatedAt'] as Timestamp
                : null;
        final Timestamp? bTime =
            b['updatedAt'] is Timestamp
                ? b['updatedAt'] as Timestamp
                : null;
        if (aTime == null && bTime == null) {
          return 0;
        }
        if (aTime == null) {
          return 1;
        }
        if (bTime == null) {
          return -1;
        }
        return bTime.compareTo(aTime);
      },
    );
    return patients;
  }
  // ===============================================================
  // FILTER PASIEN
  // ===============================================================
  List<Map<String, dynamic>> _filterPatients(
    List<Map<String, dynamic>> patients,
  ) {
    if (_searchQuery.isEmpty) {
      return patients;
    }
    return patients.where(
      (patient) {
        final String name =
            (patient['userName'] ??
                    patient['name'] ??
                    '')
               .toString()
               .toLowerCase();
        return name.contains(_searchQuery);
      },
    ).toList();
  }
  // ===============================================================
  // AMBIL JENIS KELAMIN
  // ===============================================================
  Future<String> _getPatientGender(
    Map<String, dynamic> patient,
  ) async {
    final String userId =
        (patient['userId'] ?? '').toString();
    if (userId.isEmpty) {
      return 'Jenis kelamin';
    }
    if (_genderCache.containsKey(userId)) {
      return _genderCache[userId]!;
    }
    final String consultationGender =
        (patient['gender'] ?? '')
           .toString()
           .trim();
    if (consultationGender.isNotEmpty) {
      final String formatted =
          _formatGender(consultationGender);
      _genderCache[userId] = formatted;
      return formatted;
    }
    try {
      final DocumentSnapshot<
          Map<String, dynamic>> userDocument =
          await FirebaseFirestore.instance
             .collection('users')
             .doc(userId)
             .get();
      if (userDocument.exists) {
        final Map<String, dynamic> data =
            userDocument.data() ?? {};
        final String gender =
            (data['gender'] ?? '')
               .toString()
               .trim();
        if (gender.isNotEmpty) {
          final String formatted =
              _formatGender(gender);
          _genderCache[userId] = formatted;
          return formatted;
        }
      }
    } catch (_) {
      // Gunakan fallback.
    }
    _genderCache[userId] = 'Jenis kelamin';
    return 'Jenis kelamin';
  }
  // ===============================================================
  // FORMAT GENDER
  // ===============================================================
  String _formatGender(String gender) {
    final String value =
        gender.trim().toLowerCase();
    if (value == 'perempuan' ||
        value == 'female' ||
        value == 'wanita' ||
        value == 'p') {
      return 'Perempuan';
    }
    if (value == 'laki-laki' ||
        value == 'laki laki' ||
        value == 'male' ||
        value == 'pria' ||
        value == 'l') {
      return 'Laki-laki';
    }
    return gender;
  }
  // ===============================================================
  // ICON GENDER
  // ===============================================================
  IconData _genderIcon(String gender) {
    if (gender == 'Perempuan') {
      return Icons.female_rounded;
    }
    if (gender == 'Laki-laki') {
      return Icons.male_rounded;
    }
    return Icons.person_outline_rounded;
  }
  Color _genderColor(String gender) {
    if (gender == 'Perempuan') {
      return const Color(0xFFD45B8C);
    }
    if (gender == 'Laki-laki') {
      return const Color(0xFF3E8DB5);
    }
    return greyText;
  }
  // ===============================================================
  // DETAIL PASIEN
  // ===============================================================
  void _openPatientDetail(
    Map<String, dynamic> patient,
  ) {
    final String name =
        (patient['userName'] ??
                patient['name'] ??
                'Pasien')
           .toString();
    final String day =
        (patient['consultationDay'] ?? '-')
           .toString();
    final String time =
        (patient['consultationTime'] ?? '-')
           .toString();
    final String status =
        (patient['status'] ?? 'active').toString().toLowerCase();
    final bool isCompleted = status == 'completed' || status == 'selesai' || status == 'done';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return FutureBuilder<String>(
          future: _getPatientGender(patient),
          builder: (
            context,
            snapshot,
          ) {
            final String gender =
                snapshot.data ?? 'Jenis kelamin';
            return Container(
              padding: const EdgeInsets.fromLTRB(
                22,
                12,
                22,
                24,
              ),
              decoration: const BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8D0CC),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildDetailRow(
                      _genderIcon(gender),
                      'Jenis kelamin',
                      gender,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Hari konsultasi',
                      day,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.access_time_rounded,
                      'Waktu konsultasi',
                      time,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () {
                                Navigator.pop(bottomSheetContext);
                                _openPatientChat(patient);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? const Color(0xFFE8E4E1)
                              : primaryBrown,
                          disabledBackgroundColor: const Color(0xFFE8E4E1),
                          foregroundColor: isCompleted
                              ? Colors.black54
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          isCompleted ? 'Konsultasi Selesai' : 'Buka Chat',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? Colors.black54 : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ===============================================================
  // DETAIL ROW
  // ===============================================================
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: softOrange,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: primaryBrown,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: greyText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ===============================================================
  // BUKA CHAT
  // ===============================================================
  void _openPatientChat(
    Map<String, dynamic> patient,
  ) {
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
  // BOTTOM NAVIGATION
  // ===============================================================
  void _onNavigationTap(
    int index,
  ) {
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
    if (index == 1) {
      return;
    }
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
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorProfileScreen(),
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            0,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: _patientStream(),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color: primaryBrown,
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildEmptyState(
                        icon:
                            Icons.error_outline_rounded,
                        title:
                            'Data pasien tidak dapat dimuat',
                        subtitle:
                            'Coba periksa koneksi atau Firestore.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return _buildEmptyState(
                        icon:
                            Icons.people_outline_rounded,
                        title:
                            'Belum ada pasien',
                        subtitle:
                            'Pasien yang melakukan konsultasi akan muncul di sini.',
                      );
                    }
                    final List<
                            Map<String, dynamic>>
                        allPatients =
                        _buildPatientList(
                      snapshot.data!,
                    );
                    final List<
                            Map<String, dynamic>>
                        patients =
                        _filterPatients(
                      allPatients,
                    );
                    if (allPatients.isEmpty) {
                      return _buildEmptyState(
                        icon:
                            Icons.people_outline_rounded,
                        title:
                            'Belum ada pasien',
                        subtitle:
                            'Pasien yang melakukan konsultasi akan muncul di sini.',
                      );
                    }
                    if (patients.isEmpty) {
                      return _buildEmptyState(
                        icon:
                            Icons.search_off_rounded,
                        title:
                            'Pasien tidak ditemukan',
                        subtitle:
                            'Coba gunakan nama pasien yang berbeda.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                      ),
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount: patients.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: 10),
                      itemBuilder:
                          (context, index) {
                        return _buildPatientCard(
                          patients[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          DoctorBottomNavigation(
        selectedIndex: 1,
        onItemSelected: _onNavigationTap,
      ),
    );
  }
  // ===============================================================
  // HEADER
  // ===============================================================
  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 23,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Daftar Pasien',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
  // ===============================================================
  // SEARCH BAR
  // ===============================================================
  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: searchColor,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 19,
            color: primaryBrown,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              textAlignVertical:
                  TextAlignVertical.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.black,
              ),
              decoration:
                  const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isCollapsed: true,
                hintText:
                    'Cari nama pasien...',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: greyText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ===============================================================
  // PATIENT CARD
  // ===============================================================
  Widget _buildPatientCard(
    Map<String, dynamic> patient,
  ) {
    final String name =
        (patient['userName'] ??
                patient['name'] ??
                'Pasien')
           .toString();
    final String day =
        (patient['consultationDay'] ?? '')
           .toString();
    final String time =
        (patient['consultationTime'] ?? '')
           .toString();
    final String status =
        (patient['status'] ?? 'active').toString().toLowerCase();
    final bool isCompleted = status == 'completed' || status == 'selesai' || status == 'done';
    return GestureDetector(
      onTap: () {
        _openPatientDetail(patient);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: softOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color: primaryBrown,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: FutureBuilder<String>(
                future: _getPatientGender(patient),
                builder: (
                  context,
                  snapshot,
                ) {
                  final String gender =
                      snapshot.data ??
                          'Jenis kelamin';
                  return Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _genderIcon(gender),
                            size: 15,
                            color: _genderColor(
                              gender,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _buildPatientSubtitle(
                                gender: gender,
                                day: day,
                                time: time,
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                fontFamily:
                                    'Nunito',
                                fontSize: 11,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E4E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }
  // ===============================================================
  // SUBTITLE PASIEN
  // ===============================================================
  String _buildPatientSubtitle({
    required String gender,
    required String day,
    required String time,
  }) {
    final List<String> parts = [];
    if (gender != 'Jenis kelamin') {
      parts.add(gender);
    }
    if (day.isNotEmpty) {
      parts.add(day);
    }
    if (time.isNotEmpty) {
      parts.add(time);
    }
    if (parts.isEmpty) {
      return 'Data pasien';
    }
    return parts.join(' • ');
  }
  // ===============================================================
  // EMPTY STATE
  // ===============================================================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: softOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 31,
                color: primaryBrown,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
