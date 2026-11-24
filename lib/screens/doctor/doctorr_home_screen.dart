import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'doctor_chat_screen.dart';
import 'doctor_notification_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_profile_screen.dart';
import 'doctor_schedule_screen.dart';

import '../notification_screen.dart';

import '../../widgets/doctor_bottom_navigation.dart';
import '../../services/notification_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color brown = const Color(0xFFB05039);
  String _doctorName = 'Dokter';
  Timer? _activationTimer;
  bool _syncingConsultations = false;
  
  @override
  void initState() {
    super.initState();
    _loadDoctorName();
    _activationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _activateDueConsultations(),
    );
    _activateDueConsultations();
  }

  @override
  void dispose() {
    _activationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDoctorName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String name = user.displayName ?? '';
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final firestoreName = (doc.data()?['name'] ?? '').toString().trim();
      if (firestoreName.isNotEmpty) name = firestoreName;
      if (!mounted) return;
      setState(() => _doctorName = name.isNotEmpty ? name : 'Dokter');
    } catch (_) {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      setState(
        () => _doctorName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!.trim()
            : 'Dokter',
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _consultationStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('consultations')
        .where('doctorId', isEqualTo: user.uid)
        .snapshots();
  }

  DateTime? _consultationDate(Map<String, dynamic> data) {
    final value = data['consultationTimestamp'];
    if (value is Timestamp) return value.toDate();
    final fallback = data['consultationDate'];
    if (fallback is Timestamp) return fallback.toDate();
    return null;
  }


Future<void> _activateDueConsultations() async {
  if (_syncingConsultations) return;

  final doctor = FirebaseAuth.instance.currentUser;
  if (doctor == null) return;

  _syncingConsultations = true;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .where('doctorId', isEqualTo: doctor.uid)
        .get();

    for (final doc in snapshot.docs) {
      final consultationRef = doc.reference;

      final transition =
          await FirebaseFirestore.instance.runTransaction<String?>(
        (transaction) async {
          final freshSnapshot =
              await transaction.get(consultationRef);

          if (!freshSnapshot.exists) return null;

          final data = freshSnapshot.data() ?? {};

          final status =
              (data['status'] ?? '').toString().toLowerCase();

          if (status != 'booked' && status != 'active') {
            return null;
          }

          final startValue = data['consultationTimestamp'];
          if (startValue is! Timestamp) return null;

          final startTime = startValue.toDate();

          DateTime endTime;
          final endValue = data['consultationEndTimestamp'];

          if (endValue is Timestamp) {
            endTime = endValue.toDate();
          } else {
            final duration =
                (data['durationMinutes'] as num?)?.toInt() ?? 60;

            if (![15, 30, 60].contains(duration)) {
              return null;
            }

            endTime = startTime.add(
              Duration(minutes: duration),
            );
          }

          final now = DateTime.now();

          // Belum waktunya konsultasi.
          if (now.isBefore(startTime)) return null;

          // Waktu konsultasi sudah habis.
          if (!now.isBefore(endTime)) {
            transaction.update(consultationRef, {
              'status': 'completed',
              'updatedAt': FieldValue.serverTimestamp(),
            });

            return status == 'booked'
                ? 'started_and_completed'
                : 'completed';
          }

          // Waktu konsultasi dimulai.
          if (status == 'booked') {
            transaction.update(consultationRef, {
              'status': 'active',
              'updatedAt': FieldValue.serverTimestamp(),
            });

            return 'started';
          }

          return null;
        },
      );

      if (transition == null) continue;

      final data = doc.data();

      final patientId = (data['userId'] ?? '').toString();
      final patientName =
          (data['userName'] ?? 'Pasien').toString();

      // Notifikasi konsultasi dimulai.
      if (transition == 'started' ||
          transition == 'started_and_completed') {
        try {
          await AppNotification.create(
            uid: doctor.uid,
            type: 'consultation',
            title: 'Konsultasi Dimulai',
            body: 'Konsultasi dengan $patientName sudah dimulai.',
          );

          if (patientId.isNotEmpty) {
            await AppNotification.create(
              uid: patientId,
              type: 'consultation',
              title: 'Waktunya Konsultasi!',
              body:
                  'Konsultasi dengan dr. $_doctorName sudah dimulai. Kamu bisa mulai chat sekarang.',
            );
          }
        } catch (e) {
          debugPrint('Notifikasi konsultasi dimulai gagal: $e');
        }
      }

      // Notifikasi konsultasi selesai.
      if (transition == 'completed' ||
          transition == 'started_and_completed') {
        try {
          await AppNotification.create(
            uid: doctor.uid,
            type: 'consultation',
            title: 'Konsultasi Selesai',
            body: 'Konsultasi dengan $patientName telah berakhir.',
          );

          if (patientId.isNotEmpty) {
            await AppNotification.create(
              uid: patientId,
              type: 'consultation',
              title: 'Konsultasi Selesai',
              body:
                  'Konsultasi dengan dr. $_doctorName telah berakhir. Kamu masih bisa melihat riwayat chat.',
            );
          }
        } catch (e) {
          debugPrint('Notifikasi konsultasi selesai gagal: $e');
        }
      }
    }
  } catch (e) {
    debugPrint('Gagal memperbarui status konsultasi dokter: $e');
  } finally {
    _syncingConsultations = false;
  }
}

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorPatientsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorChatScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
      );
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorNotificationScreen()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
    );
  }

  void _openPatientChat(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientChatScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _consultationStream(),
          builder: (context, snapshot) {
            final consultations =
                snapshot.data?.docs ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            final unreadCount = _getUnreadCount(consultations);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildGreeting(unreadCount),
                  const SizedBox(height: 18),
                  _buildPracticeSchedule(),
                  const SizedBox(height: 18),
                  _buildStatistics(consultations, unreadCount),
                  const SizedBox(height: 25),
                  _buildRecentMessages(consultations),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }


Widget _buildPracticeSchedule() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return const SizedBox.shrink();

  const List<String> dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  const List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final now = DateTime.now();
  final String today = dayNames[now.weekday - 1];

  final String formattedDate =
      '${now.day} ${monthNames[now.month - 1]} ${now.year}';

  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots(),
    builder: (context, snapshot) {
      final data = snapshot.data?.data() ?? {};
      final scheduleData = data['doctorSchedule'];

      String practiceTime = 'Belum diatur';
      String duration = '30 Menit';
      bool hasSchedule = false;

      if (scheduleData is Map) {
        final todayData = scheduleData[today];

        if (todayData is Map && todayData['active'] == true) {
          final String start =
              (todayData['start'] ?? '').toString();

          final String end =
              (todayData['end'] ?? '').toString();

          final dynamic durationValue =
              todayData['durationMinutes'] ??
              scheduleData['durationMinutes'] ??
              data['durationMinutes'];

          if (start.isNotEmpty && end.isNotEmpty) {
            practiceTime =
                '${start.replaceAll(':', '.')} - '
                '${end.replaceAll(':', '.')}';

            if (durationValue != null) {
              duration = '$durationValue Menit';
            }

            hasSchedule = true;
          }
        }
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE5),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER JADWAL PRAKTIK
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Jadwal Praktik',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DoctorScheduleScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                       color: Colors.black,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // KARTU HARI, TANGGAL, DAN JAM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 19,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCFA),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // HARI DAN TANGGAL
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          today,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF30231F),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formattedDate,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF77706C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // GARIS PEMBATAS TENGAH
                  Container(
                    width: 1.5,
                    height: 65,
                    color: const Color(0xFFE5DAD4),
                  ),

                  // JAM DAN DURASI
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasSchedule
                              ? practiceTime
                              : 'Tidak ada jadwal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF30231F),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE3D1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            hasSchedule
                                ? duration
                                : 'Belum tersedia',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB05039),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildHeaderContent(photoBase64: null, googlePhotoUrl: '');
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final photoValue = data?['photoBase64']?.toString().trim() ?? '';
        String googlePhotoUrl = user.photoURL ?? '';

        if (googlePhotoUrl.startsWith('data:')) {
          googlePhotoUrl = '';
        }

        return _buildHeaderContent(
          photoBase64: photoValue.isNotEmpty ? photoValue : null,
          googlePhotoUrl: googlePhotoUrl,
        );
      },
    );
  }


Widget _buildHeaderContent({
  required String? photoBase64,
  required String googlePhotoUrl,
}) {
  return SizedBox(
    height: 75,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo_beranda_baru.png',
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const _DoctorNotificationBell(),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DoctorProfileScreen(),
              ),
            );
            if (!mounted) return;
            setState(() {});
          },
          child: Container(
            width: 42,
            height: 42,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5D8),
              shape: BoxShape.circle,
            ),
            child: _buildDoctorProfilePhoto(
              photoBase64: photoBase64,
              googlePhotoUrl: googlePhotoUrl,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDoctorProfilePhoto({
    required String? photoBase64,
    required String googlePhotoUrl,
  }) {
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        String encodedPhoto = photoBase64;
        // Mendukung Base64 biasa maupun data URI: data:image/...;base64,...
        if (encodedPhoto.startsWith('data:') && encodedPhoto.contains(',')) {
          encodedPhoto = encodedPhoto.substring(encodedPhoto.indexOf(',') + 1);
        }

        return Image.memory(
          base64Decode(encodedPhoto),
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultDoctorProfileIcon(),
        );
      } catch (_) {
        // Jika Base64 tidak valid, coba foto Firebase Authentication.
      }
    }

    if (googlePhotoUrl.isNotEmpty) {
      return Image.network(
        googlePhotoUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultDoctorProfileIcon(),
      );
    }

    return _defaultDoctorProfileIcon();
  }

  Widget _defaultDoctorProfileIcon() {
    return const Icon(
      Icons.account_circle_rounded,
      size: 39,
      color: Color(0xFFB05039),
    );
  }

  Widget _buildGreeting(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34, 25, 25, 25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE3),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo,',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'dr. $_doctorName 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            unreadCount > 0
                ? 'Anda punya $unreadCount pesan belum dibaca.'
                : 'Tidak ada pesan baru.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }


int _getUnreadCount(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations,
) {
  int total = 0;

  for (final document in consultations) {
    final data = document.data();
    final value = data['unreadForDoctor'];

    if (value is num) {
      total += value.toInt();
    } else {
      total += int.tryParse(value?.toString() ?? '0') ?? 0;
    }
  }

  return total;
}

int _getPatientTodayCount(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations,
) {
  final now = DateTime.now();
  final todayPatients = <String>{};

  for (final document in consultations) {
    final data = document.data();

    final userId = (data['userId'] ?? '').toString().trim();
    if (userId.isEmpty) continue;

    final consultationDate = _consultationDate(data);
    if (consultationDate == null) continue;

    final isToday =
        consultationDate.year == now.year &&
        consultationDate.month == now.month &&
        consultationDate.day == now.day;

    if (isToday) {
      todayPatients.add(userId);
    }
  }

  return todayPatients.length;
}

int _getPatientCount(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations,
) {
  final patientIds = <String>{};

  for (final document in consultations) {
    final data = document.data();
    final userId = (data['userId'] ?? '').toString().trim();

    if (userId.isNotEmpty) {
      patientIds.add(userId);
    }
  }

  return patientIds.length;
}


  Widget _buildStatistics(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations,
    int unreadCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.groups_rounded,
            value: _getPatientTodayCount(consultations).toString(),
            label: 'Pasien Hari Ini',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.chat_bubble_rounded,
            value: unreadCount.toString(),
            label: 'Belum Dibaca',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.calendar_month_rounded,
            value: _getPatientCount(consultations).toString(),
            label: 'Total Pasien',
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE1C8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 27, color: brown),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMessages(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations,
  ) {
    final latestByUser =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final document in consultations) {
      final data = document.data();
      final lastMessage = (data['lastMessage'] ?? '').toString().trim();
      if (lastMessage.isEmpty) continue;

      final userId = (data['userId'] ?? '').toString().trim();
      if (userId.isEmpty) continue;

      final existing = latestByUser[userId];
      if (existing == null) {
        latestByUser[userId] = document;
        continue;
      }

      final oldTime = existing.data()['updatedAt'] is Timestamp
          ? existing.data()['updatedAt'] as Timestamp
          : null;
      final newTime = data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null;
      if (newTime != null &&
          (oldTime == null || newTime.compareTo(oldTime) > 0))
        latestByUser[userId] = document;
    }

    final recentChats = latestByUser.values.toList();
    recentChats.sort((a, b) {
      final aTime = a.data()['updatedAt'] is Timestamp
          ? a.data()['updatedAt'] as Timestamp
          : null;
      final bTime = b.data()['updatedAt'] is Timestamp
          ? b.data()['updatedAt'] as Timestamp
          : null;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    final limitedChats = recentChats.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [


Row(
  children: [
    const Expanded(
      child: Text(
        'Pesan Terbaru',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const DoctorChatScreen(),
          ),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lihat Semua',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 2),
          Icon(
            Icons.chevron_right_rounded,
            size: 19,
            color: Colors.black,
          ),
        ],
      ),
    ),
  ],
),

          const SizedBox(height: 8),
          if (limitedChats.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belum ada pesan terbaru.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            )
          else
            ...limitedChats.map(_buildMessageItem),
        ],
      ),
    );
  }

  
  Widget _buildPatientPhoto(
      String userId, {
      double size = 48,
    }) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          Widget fallback() {
            return Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5D8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.person_rounded,
                size: size * 0.58,
                color: const Color(0xFFAA4E39),
              ),
            );
          }

          if (userId.isEmpty ||
              snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return fallback();
          }

          final data = snapshot.data!.data() ?? {};

          final String photoBase64 =
              (data['photoBase64'] ?? '').toString().trim();

          if (photoBase64.isNotEmpty) {
            try {
              final String encodedPhoto = photoBase64.contains(',')
                  ? photoBase64.split(',').last
                  : photoBase64;

              return ClipOval(
                child: Image.memory(
                  base64Decode(encodedPhoto),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback(),
                ),
              );
            } catch (_) {
              return fallback();
            }
          }

      final String photoUrl =
          (data['photoURL'] ?? data['photoUrl'] ?? '')
              .toString()
              .trim();

      if (photoUrl.isNotEmpty) {
        return ClipOval(
          child: Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback(),
          ),
        );
      }

      return fallback();
    },
  );
}


  Widget _buildMessageItem(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final patientName = (data['userName'] ?? data['name'] ?? 'Pasien')
        .toString();
    final message = (data['lastMessage'] ?? '').toString().trim();
    final status = (data['status'] ?? '').toString().toLowerCase();
    final value = data['unreadForDoctor'];
    final unreadCount = value is int
        ? value
        : value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '0') ?? 0;
    final patient = {
      ...data,
      'consultationId': document.id,
      'userName': patientName,
    };

    return GestureDetector(
      onTap: () => _openPatientChat(patient),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEFE7E3), width: 1),
          ),
        ),
        child: Row(
          children: [
        ClipOval(
          child: _buildPatientPhoto(
            (data['userId'] ?? '').toString().trim(),
            size: 48,
          ),
        ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (unreadCount > 0)
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD9E1),
                  shape: BoxShape.circle,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? const Color(0xFFFFE5D8)
                      : status == 'completed'
                      ? const Color(0xFFECECEC)
                      : const Color(0xFFFFEEE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == 'active'
                      ? 'Aktif'
                      : status == 'booked'
                      ? 'Terjadwal'
                      : 'Selesai',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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

// ===============================================================
// TOMBOL LONCENG NOTIFIKASI DOKTER
//
// Badge dihitung dari AppNotification.getRecentUnreadCount
// (belum dibaca & < 24 jam) — sumber yang sama dengan halaman
// DoctorNotificationScreen, jadi angkanya selalu cocok.
//
// Selain itu lonceng juga mendengarkan badgeSignal dari
// NotificationService, sehingga angka langsung muncul saat
// ada pesan baru dari pasien tanpa harus buka-tutup halaman.
// ===============================================================

class _DoctorNotificationBell extends StatefulWidget {
  const _DoctorNotificationBell();

  @override
  State<_DoctorNotificationBell> createState() =>
      _DoctorNotificationBellState();
}

class _DoctorNotificationBellState extends State<_DoctorNotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();

    NotificationService.badgeSignal.addListener(_onBadgeSignal);
  }

  void _onBadgeSignal() {
    _refreshCount();
  }

  @override
  void dispose() {
    NotificationService.badgeSignal.removeListener(_onBadgeSignal);
    super.dispose();
  }

  Future<void> _refreshCount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
      return;
    }

    final int count = await AppNotification.getRecentUnreadCount(user.uid);

    if (!mounted) return;

    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = _unreadCount > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorNotificationScreen(),
          ),
        );

        _refreshCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              hasUnread
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              size: 27,
              color: const Color(0xFFB05039),
            ),
          ),

          if (hasUnread)
            Positioned(
              right: -3,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFAA4E39),
                  shape: _unreadCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: _unreadCount > 9
                      ? BorderRadius.circular(10)
                      : null,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
