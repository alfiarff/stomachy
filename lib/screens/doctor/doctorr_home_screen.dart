import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  // ===============================================================
  // WARNA STOMACHY
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);

  final Color primaryBrown = const Color(0xFF5A392F);

  final Color accentBrown = const Color(0xFFB9543A);

  // Warna icon dan selected bottom navigation
  final Color navigationBrown = const Color(0xFF93432F);

  final Color navigationBackground = const Color(0xFFFFE5D5);

  String _doctorName = 'Dokter';

  bool isOnline = true;

  // ===============================================================
  // JUMLAH PESAN BELUM DIBACA
  // ===============================================================

  int get notificationCount {
    int total = 0;

    for (final chat in DoctorChatScreen.chatItems) {
      final int unread = chat['unread'] as int;
      total += unread;
    }

    return total;
  }

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _loadDoctorName();
  }

  // ===============================================================
  // LOAD NAMA DOKTER
  // ===============================================================

  Future<void> _loadDoctorName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      String name = user.displayName ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final firestoreName = data['name'];

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

      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        _doctorName =
            user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Dokter';
      });
    }
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });

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

      return;
    }
  }

  // ===============================================================
  // BUKA NOTIFIKASI
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

  // ===============================================================
  // BUKA PROFIL
  // ===============================================================

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DoctorProfileScreen(),
      ),
    );
  }

  // ===============================================================
  // BUKA CHAT PASIEN
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
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
              // HEADER
              _buildHeader(),

              const SizedBox(
                height: 18,
              ),

              // GREETING
              _buildGreeting(),

              const SizedBox(
                height: 18,
              ),

              // STATUS PRAKTIK
              _buildPracticeStatus(),

              const SizedBox(
                height: 18,
              ),

              // STATISTIK
              _buildStatistics(),

              const SizedBox(
                height: 25,
              ),

              // PESAN TERBARU
              _buildRecentMessages(),

              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 75,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // ---------------------------------------------------------
          // LOGO
          // ---------------------------------------------------------

          Expanded(
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo_beranda_stomachy.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // NOTIFIKASI
          // ---------------------------------------------------------

          GestureDetector(
            onTap: _openNotifications,
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

                // BADGE NOTIFIKASI

                if (notificationCount > 0)
                  Positioned(
                    right: -3,
                    top: -4,
                    child: Container(
                      width: 19,
                      height: 19,
                      alignment:
                          Alignment.center,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFFFF6680),
                        shape:
                            BoxShape.circle,
                      ),
                      child: Text(
                        notificationCount > 9
                            ? '9+'
                            : notificationCount
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

          // ---------------------------------------------------------
          // PROFIL
          // Warna disamakan dengan icon bottom navigation
          // ---------------------------------------------------------

          GestureDetector(
            onTap: _openProfile,
            child: Container(
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

  Widget _buildGreeting() {
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
                  'Nunito',
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
                  'Nunito',
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
            notificationCount > 0
                ? 'Anda punya $notificationCount pesan belum dibaca.'
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
        color: Colors.white,
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
                        'Nunito',
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
                            : Colors.grey,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Flexible(
                      child: Text(
                        isOnline
                            ? 'Online – pasien bisa chat'
                            : 'Offline – pasien tidak bisa chat',
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w400,
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

          // SWITCH

          GestureDetector(
            onTap: () {
              setState(() {
                isOnline =
                    !isOnline;
              });
            },
            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 250,
              ),
              width: 58,
              height: 30,
              padding:
                  const EdgeInsets.all(3),
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
                child: Container(
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

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child:
              _buildStatisticCard(
            icon:
                Icons.groups_rounded,
            iconColor:
                const Color(
              0xFFFF806E,
            ),
            iconBackground:
                const Color(
              0xFFFFE8E2,
            ),
            value: '5',
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
                Icons
                    .chat_bubble_rounded,
            iconColor:
                const Color(
              0xFF9074E8,
            ),
            iconBackground:
                const Color(
              0xFFEAE3FF,
            ),
            value:
                notificationCount
                    .toString(),
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
                Icons
                    .calendar_month_rounded,
            iconColor:
                const Color(
              0xFFEBA21D,
            ),
            iconBackground:
                const Color(
              0xFFFFF0D7,
            ),
            value: '24',
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
        color: Colors.white,
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
            child: Icon(
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
              fontSize: 10,
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

  Widget _buildRecentMessages() {
    final recentChats =
        DoctorChatScreen.chatItems
            .take(3)
            .toList();

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
        color: Colors.white,
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
          // ---------------------------------------------------------
          // JUDUL
          // ---------------------------------------------------------

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
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFFB65339,
                        ),
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
                          Color(
                        0xFFB65339,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          // ---------------------------------------------------------
          // DATA CHAT
          // ---------------------------------------------------------

          ...recentChats.map(
            (chat) {
              return _buildMessageItem(
                chat,
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
    Map<String, dynamic> chat,
  ) {
    final int unread =
        chat['unread'] as int;

    return GestureDetector(
      onTap: () {
        _openPatientChat(chat);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
        ),
        decoration:
            const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  Color(0xFFEFE7E3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // -------------------------------------------------------
            // AVATAR
            // -------------------------------------------------------

            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color:
                    chat['avatarColor'],
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                chat['avatarIcon'],
                size: 31,
                color:
                    chat[
                        'avatarIconColor'],
              ),
            ),

            const SizedBox(
              width: 11,
            ),

            // -------------------------------------------------------
            // NAMA + PESAN
            // -------------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'],
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
                    chat['message'],
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontFamily:
                          'Nunito',
                      fontSize: 10.5,
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

            // -------------------------------------------------------
            // UNREAD
            // Warnanya disamakan dengan bottom navigation
            // -------------------------------------------------------

            if (unread > 0)
              Container(
                width:
                    unread > 1
                        ? 28
                        : 11,
                height:
                    unread > 1
                        ? 28
                        : 11,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color: unread > 1
                      ? navigationBackground
                      : const Color(
                          0xFFFFD9E1,
                        ),
                  shape:
                      BoxShape.circle,
                ),
                child: unread > 1
                    ? Text(
                        unread.toString(),
                        style:
                            TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              navigationBrown,
                        ),
                      )
                    : null,
              )
            else
              // -----------------------------------------------------
              // SELESAI
              // -----------------------------------------------------

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
                      const Color(
                    0xFFFFEEE5,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child:
                    const Text(
                  'Selesai',
                  style:
                      TextStyle(
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

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 94,
      decoration:
          BoxDecoration(
        color: Colors.white,
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
        _selectedIndex == index;

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