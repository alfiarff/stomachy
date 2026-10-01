import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/doctor_bottom_navigation.dart';
import 'doctor_patients_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() =>
      _DoctorHomeScreenState();
}

class _DoctorHomeScreenState
    extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  String _doctorName = 'Dokter';

  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    _loadDoctorName();
    _loadDoctorStatus();
  }

  // ===============================================================
  // LOAD NAMA DOKTER
  // ===============================================================

  Future<void> _loadDoctorName() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      String name =
          user.displayName ?? '';

      final DocumentSnapshot<
          Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final Map<String, dynamic>? data =
            doc.data();

        if (data != null) {
          final dynamic firestoreName =
              data['name'];

          if (firestoreName is String &&
              firestoreName.trim().isNotEmpty) {
            name = firestoreName.trim();
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _doctorName =
            name.isNotEmpty ? name : 'Dokter';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final User? user =
          FirebaseAuth.instance.currentUser;

      setState(() {
        _doctorName =
            user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : 'Dokter';
      });
    }
  }

  // ===============================================================
  // LOAD STATUS DOKTER
  // ===============================================================

  Future<void> _loadDoctorStatus() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<
          Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!mounted) {
        return;
      }

      if (doc.exists) {
        final Map<String, dynamic>? data =
            doc.data();

        setState(() {
          isOnline =
              data?['status'] == 'online';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isOnline = false;
      });
    }
  }

  // ===============================================================
  // UBAH STATUS DOKTER
  // ===============================================================

  Future<void> _toggleDoctorStatus() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final bool previousStatus =
        isOnline;

    final bool newStatus =
        !isOnline;

    setState(() {
      isOnline = newStatus;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'status':
              newStatus ? 'online' : 'offline',
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Status kamu sekarang Online.'
                : 'Status kamu sekarang Offline.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isOnline = previousStatus;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mengubah status praktik.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ===============================================================
  // STREAM KONSULTASI
  // ===============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _consultationStream() {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('consultations')
        .where(
          'doctorId',
          isEqualTo: user.uid,
        )
        .snapshots();
  }

  // ===============================================================
  // JUMLAH PESAN BELUM DIBACA
  // ===============================================================

  int _getUnreadCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        consultations,
  ) {
    int total = 0;

    for (final consultation in consultations) {
      final Map<String, dynamic> data = consultation.data();
      final dynamic value = data['unreadForDoctor'];
      final int unread = value is int
          ? value
          : value is num
              ? value.toInt()
              : int.tryParse(value?.toString() ?? '0') ?? 0;
      if (unread > 0) total += unread;
    }

    return total;
  }

  // ===============================================================
  // JUMLAH PASIEN
  // ===============================================================

  int _getPatientCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        consultations,
  ) {
    final Set<String> patients = {};

    for (final consultation in consultations) {
      final data = consultation.data();

      final String status =
          data['status']?.toString().toLowerCase() ?? '';

      final String userId =
          data['userId']?.toString() ?? '';

      if (status == 'active' &&
          userId.isNotEmpty) {
        patients.add(userId);
      }
    }

    return patients.length;
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });

      _loadDoctorStatus();

      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorPatientsScreen(),
        ),
      );

      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorChatScreen(),
        ),
      );

      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorProfileScreen(),
        ),
      );
    }
  }

  // ===============================================================
  // BUKA CHAT
  // ===============================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DoctorChatScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DoctorProfileScreen(),
      ),
    );
  }

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
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _consultationStream(),
          builder: (context, snapshot) {
            final consultations =
                snapshot.data?.docs ?? [];

            final int unreadCount =
                _getUnreadCount(
              consultations,
            );

            return SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                15,
                10,
                15,
                25,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    unreadCount,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildGreeting(
                    unreadCount,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildPracticeStatus(),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildStatistics(
                    consultations,
                    unreadCount,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  _buildRecentMessages(
                    consultations,
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar:
          DoctorBottomNavigation(
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

  Widget _buildHeader(
    int unreadCount,
  ) {
    return SizedBox(
      height: 75,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo_beranda_baru.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),

          GestureDetector(
            onTap:
                _openNotifications,
            child: Stack(
              clipBehavior:
                  Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xFFFFE1D6),
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons
                        .notifications_none_rounded,
                    size: 27,
                    color:
                        Color(0xFFB9543A),
                  ),
                ),

                if (unreadCount > 0)
                  Positioned(
                    right: -3,
                    top: -4,
                    child:
                        Container(
                      width: 19,
                      height: 19,
                      alignment:
                          Alignment.center,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFFAA4E39),
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          Text(
                        unreadCount > 9
                            ? '9+'
                            : unreadCount
                                .toString(),
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          GestureDetector(
            onTap:
                _openProfile,
            child:
                Container(
              width: 42,
              height: 42,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFFE5D5),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .account_circle_rounded,
                size: 39,
                color:
                    Color(0xFF93432F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // GREETING
  // ===============================================================

  Widget _buildGreeting(
    int unreadCount,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        34,
        25,
        25,
        25,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFEDE3),
        borderRadius:
            BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo,',
            style:
                TextStyle(
              fontFamily:
                  'Fredoka',
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF4A2119),
              height: 1.2,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            'dr. $_doctorName 👋',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontFamily:
                  'Fredoka',
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF4A2119),
              height: 1.2,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            unreadCount > 0
                ? 'Anda punya $unreadCount pesan belum dibaca.'
                : 'Tidak ada pesan baru.',
            style:
                const TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 12,
              fontWeight:
                  FontWeight.w400,
              color:
                  Color(0xFF764C43),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATUS PRAKTIK
  // ===============================================================

  Widget _buildPracticeStatus() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 20,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.07,
            ),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Praktik',
                  style:
                      TextStyle(
                    fontFamily:
                        'Fredoka',
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF251814),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(
                        color: isOnline
                            ? const Color(
                                0xFF54C467,
                              )
                            : const Color(
                                0xFF9E9E9E,
                              ),
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Flexible(
                      child:
                          Text(
                        isOnline
                            ? 'Online – pasien bisa chat'
                            : 'Offline – pasien tidak bisa chat',
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 12,
                          color:
                              Color(
                            0xFF777783,
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

          GestureDetector(
            onTap:
                _toggleDoctorStatus,
            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 250,
              ),
              width: 58,
              height: 30,
              padding:
                  const EdgeInsets.all(
                3,
              ),
              decoration:
                  BoxDecoration(
                color: isOnline
                    ? const Color(
                        0xFF55C566,
                      )
                    : const Color(
                        0xFFB9B9B9,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child:
                  AnimatedAlign(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),
                alignment: isOnline
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child:
                    Container(
                  width: 24,
                  height: 24,
                  decoration:
                      const BoxDecoration(
                    color:
                        Colors.white,
                    shape:
                        BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATISTICS
  // ===============================================================

  Widget _buildStatistics(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        consultations,
    int unreadCount,
  ) {
    final int patientCount =
        _getPatientCount(
      consultations,
    );

    return Row(
      children: [
        Expanded(
          child:
              _buildStatisticCard(
            icon:
                Icons.groups_rounded,
            iconColor:
                const Color(0xFFFF806E),
            iconBackground:
                const Color(0xFFFFE8E2),
            value:
                patientCount.toString(),
            label:
                'PASIEN HARI INI',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              _buildStatisticCard(
            icon:
                Icons.chat_bubble_rounded,
            iconColor:
                const Color(0xFFAA4E39),
            iconBackground:
                const Color(0xFFFFE5D8),
            value:
                unreadCount.toString(),
            label:
                'BELUM DIBACA',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              _buildStatisticCard(
            icon:
                Icons.calendar_month_rounded,
            iconColor:
                const Color(0xFFEBA21D),
            iconBackground:
                const Color(0xFFFFF0D7),
            value:
                _getPatientCount(consultations).toString(),
            label:
                'TOTAL PASIEN',
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // STATISTIC CARD
  // ===============================================================

  Widget _buildStatisticCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String value,
    required String label,
  }) {
    return Container(
      height: 205,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 18,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.07,
            ),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  iconBackground,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              size: 33,
              color:
                  iconColor,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 30,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF562118),
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontFamily:
                  'Nunito',
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF687080),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PESAN TERBARU
  // ===============================================================

  Widget _buildRecentMessages(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        consultations,
  ) {
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> latestByUser = {};

    for (final document in consultations) {
      final Map<String, dynamic> data = document.data();
      final String userId = (data['userId'] ?? '').toString();
      if (userId.isEmpty) continue;

      final existing = latestByUser[userId];
      if (existing == null) {
        latestByUser[userId] = document;
        continue;
      }

      final Timestamp? oldTime = existing.data()['updatedAt'] is Timestamp
          ? existing.data()['updatedAt'] as Timestamp
          : null;
      final Timestamp? newTime = data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null;

      if (newTime != null &&
          (oldTime == null || newTime.compareTo(oldTime) > 0)) {
        latestByUser[userId] = document;
      }
    }

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> recentChats =
        latestByUser.values.toList();

    recentChats.sort((a, b) {
      final Timestamp? aTime = a.data()['updatedAt'] is Timestamp
          ? a.data()['updatedAt'] as Timestamp
          : null;
      final Timestamp? bTime = b.data()['updatedAt'] is Timestamp
          ? b.data()['updatedAt'] as Timestamp
          : null;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> limitedChats =
        recentChats.take(3).toList();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        16,
        8,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.07,
            ),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
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
                  style:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF5A2017),
                  ),
                ),
              ),

              GestureDetector(
                onTap:
                    _openNotifications,
                child:
                    const Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style:
                          TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFFAA4E39),
                      ),
                    ),

                    SizedBox(
                      width: 2,
                    ),

                    Icon(
                      Icons
                          .chevron_right_rounded,
                      size: 19,
                      color:
                          Color(0xFFAA4E39),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          if (limitedChats.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Text(
                'Belum ada pesan terbaru.',
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  color:
                      Color(0xFF777777),
                ),
              ),
            )
          else
            ...limitedChats.map(
              (document) {
                return _buildMessageItem(
                  document,
                );
              },
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // MESSAGE ITEM
  // ===============================================================

  Widget _buildMessageItem(
    QueryDocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final Map<String, dynamic> data =
        document.data();

    final String patientName =
        data['userName']?.toString() ??
            data['name']?.toString() ??
            'Pasien';

    final String message =
        data['lastMessage']?.toString() ??
            '';

    final String status =
        data['status']?.toString().toLowerCase() ??
            '';

    final String lastSenderId =
        data['lastSenderId']?.toString() ??
            '';

    final dynamic unreadValue = data['unreadForDoctor'];
    final int unreadCount = unreadValue is int
        ? unreadValue
        : unreadValue is num
            ? unreadValue.toInt()
            : int.tryParse(unreadValue?.toString() ?? '0') ?? 0;
    final bool unread = unreadCount > 0;

    final Map<String, dynamic> patient =
        {
      ...data,
      'consultationId':
          document.id,
      'userName':
          patientName,
    };

    return GestureDetector(
      onTap: () {
        _openPatientChat(
          patient,
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
        ),
        decoration:
            const BoxDecoration(
          border: Border(
            bottom:
                BorderSide(
              color:
                  Color(0xFFEFE7E3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFFE5D8),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.person_rounded,
                size: 31,
                color:
                    Color(0xFFAA4E39),
              ),
            ),

            const SizedBox(
              width: 11,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
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
                    height: 2,
                  ),

                  Text(
                    message.isNotEmpty
                        ? message
                        : 'Belum ada pesan',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontFamily:
                          'Nunito',
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w400,
                      color:
                          Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 6,
            ),

            if (unread)
              Container(
                width: 11,
                height: 11,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFFFD9E1),
                  shape:
                      BoxShape.circle,
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      status == 'active'
                          ? const Color(
                              0xFFFFE5D8,
                            )
                          : const Color(
                              0xFFFFEEE5,
                            ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child:
                    Text(
                  status == 'active'
                      ? 'Aktif'
                      : 'Selesai',
                  style:
                      const TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF8A4A3A),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}