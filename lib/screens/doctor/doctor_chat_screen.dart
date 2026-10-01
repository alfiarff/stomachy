import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/doctor_bottom_navigation.dart';

import 'doctorr_home_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({
    super.key,
  });

  @override
  State<DoctorChatScreen> createState() =>
      _DoctorChatScreenState();
}

class _DoctorChatScreenState
    extends State<DoctorChatScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  bool _showUnreadOnly = false;

  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  final Color primaryBrown =
      const Color(0xFFB65339);

  final Color softOrange =
      const Color(0xFFFFE3D1);

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchQuery =
            _searchController.text
                .trim()
                .toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===============================================================
  // STREAM CHAT
  // ===============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _chatStream() {
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
  // BENTUK DAFTAR CHAT
  // ===============================================================

  List<Map<String, dynamic>> _buildChatList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, Map<String, dynamic>>
        chatsByUser = {};

    for (final QueryDocumentSnapshot<
        Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data =
          document.data();

      final String status =
          (data['status'] ?? 'active')
              .toString()
              .toLowerCase();

      if (status != 'active') {
        continue;
      }

      final String userId =
          (data['userId'] ?? '').toString();

      if (userId.isEmpty) {
        continue;
      }

      final Map<String, dynamic> chat = {
        ...data,
        'consultationId': document.id,
      };

      final Map<String, dynamic>? existing =
          chatsByUser[userId];

      if (existing == null) {
        chatsByUser[userId] = chat;
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
        chatsByUser[userId] = chat;
      }
    }

    final List<Map<String, dynamic>> chats =
        chatsByUser.values.toList();

    chats.sort(
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

    return chats;
  }

  // ===============================================================
  // FILTER CHAT
  // ===============================================================

  List<Map<String, dynamic>> _filterChats(
    List<Map<String, dynamic>> chats,
  ) {
    return chats.where(
      (chat) {
        final String name =
            (chat['userName'] ??
                    chat['name'] ??
                    '')
                .toString()
                .toLowerCase();

        final bool matchesSearch =
            name.contains(_searchQuery);

        final int unread =
            int.tryParse(
                  (chat['unreadForDoctor'] ?? 0)
                      .toString(),
                ) ??
                0;

        final bool matchesUnread =
            !_showUnreadOnly ||
                unread > 0;

        return matchesSearch &&
            matchesUnread;
      },
    ).toList();
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorPatientsScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
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
  // BUKA CHAT
  // ===============================================================

  void _openChat(
    Map<String, dynamic> chat,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DoctorPatientChatScreen(
          patient: chat,
        ),
      ),
    );
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
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            0,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(
                height: 10,
              ),

              _buildSearchBar(),

              const SizedBox(
                height: 12,
              ),

              StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream: _chatStream(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return _buildFilterButtons(
                      0,
                    );
                  }

                  final List<
                          Map<String, dynamic>>
                      allChats =
                      _buildChatList(
                    snapshot.data!,
                  );

                  final int unreadCount =
                      _getUnreadCount(
                    allChats,
                  );

                  return _buildFilterButtons(
                    unreadCount,
                  );
                },
              ),

              const SizedBox(
                height: 14,
              ),

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: _chatStream(),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot
                            .connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              Color(0xFFB65339),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildEmptyState(
                        icon: Icons
                            .error_outline_rounded,
                        title:
                            'Chat tidak dapat dimuat',
                        subtitle:
                            'Coba periksa koneksi atau Firestore.',
                      );
                    }

                    if (!snapshot.hasData) {
                      return _buildEmptyState(
                        icon: Icons
                            .chat_bubble_outline_rounded,
                        title:
                            'Belum ada chat',
                        subtitle:
                            'Chat dengan pasien akan muncul di sini.',
                      );
                    }

                    final List<
                            Map<String, dynamic>>
                        allChats =
                        _buildChatList(
                      snapshot.data!,
                    );

                    final List<
                            Map<String, dynamic>>
                        chats =
                        _filterChats(
                      allChats,
                    );

                    if (allChats.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons
                            .chat_bubble_outline_rounded,
                        title:
                            'Belum ada chat',
                        subtitle:
                            'Chat dengan pasien akan muncul di sini.',
                      );
                    }

                    if (chats.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons
                            .mark_chat_unread_outlined,
                        title:
                            'Tidak ada chat belum dibaca',
                        subtitle:
                            'Semua chat dengan pasien sudah dibaca.',
                      );
                    }

                    return ListView.separated(
                      padding:
                          const EdgeInsets.only(
                        bottom: 20,
                      ),
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount:
                          chats.length,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height: 11,
                        );
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return _buildChatCard(
                          chats[index],
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
        selectedIndex: 2,
        onItemSelected:
            _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // DAFTAR CHAT = FREDOKA
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
              );
            },
            child: const SizedBox(
              width: 32,
              height: 42,
              child: Center(
                child: Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                  size: 21,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Transform.translate(
                offset:
                    const Offset(-16, 0),
                child: const Text(
                  'Daftar Chat',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontFamily:
                        'Fredoka',
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Colors.black,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 32,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SEARCH BAR
  // BENAR-BENAR RATA TENGAH
  // ===============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(
          21,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.07,
            ),
            blurRadius: 6,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_rounded,
            size: 19,
            color:
                Color(0xFFB65339),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: TextField(
              controller:
                  _searchController,
              textAlignVertical:
                  TextAlignVertical.center,
              style:
                  const TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 11,
                color:
                    Colors.black,
              ),
              decoration:
                  const InputDecoration(
                border:
                    InputBorder.none,
                enabledBorder:
                    InputBorder.none,
                focusedBorder:
                    InputBorder.none,
                disabledBorder:
                    InputBorder.none,
                isCollapsed:
                    true,
                hintText:
                    'Cari nama pasien...',
                hintStyle:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 11,
                  color:
                      Color(0xFF8C8582),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FILTER
  // TANPA STROKE
  // TANPA ANIMASI
  // ===============================================================

  Widget _buildFilterButtons(
    int unreadCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterButton(
            label: 'Semua',
            selected:
                !_showUnreadOnly,
            onTap: () {
              if (_showUnreadOnly) {
                setState(() {
                  _showUnreadOnly =
                      false;
                });
              }
            },
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _buildFilterButton(
            label: unreadCount > 0
                ? 'Belum Dibaca ($unreadCount)'
                : 'Belum Dibaca',
            selected:
                _showUnreadOnly,
            onTap: () {
              if (!_showUnreadOnly) {
                setState(() {
                  _showUnreadOnly =
                      true;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Container(
        width:
            double.infinity,
        height: 38,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color: selected
              ? primaryBrown
              : const Color(
                  0xFFFFFCFA,
                ),
          borderRadius:
              BorderRadius.circular(
            19,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                0.07,
              ),
              blurRadius: 5,
              offset:
                  const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign:
              TextAlign.center,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
            color: selected
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // JUMLAH CHAT BELUM DIBACA
  // ===============================================================

  int _getUnreadCount(
    List<Map<String, dynamic>>
        chats,
  ) {
    int count = 0;

    for (final chat in chats) {
      final int unread =
          int.tryParse(
                (chat[
                            'unreadForDoctor'] ??
                        0)
                    .toString(),
              ) ??
              0;

      if (unread > 0) {
        count++;
      }
    }

    return count;
  }

  // ===============================================================
  // CHAT CARD
  // ===============================================================

  Widget _buildChatCard(
    Map<String, dynamic> chat,
  ) {
    final String name =
        (chat['userName'] ??
                chat['name'] ??
                'Pasien')
            .toString();

    final String lastMessage =
        (chat['lastMessage'] ??
                'Belum ada pesan')
            .toString();

    final String time =
        _formatTime(
      chat['updatedAt'],
    );

    final int unread =
        int.tryParse(
              (chat['unreadForDoctor'] ??
                      0)
                  .toString(),
            ) ??
            0;

    final bool isUnread =
        unread > 0;

    final bool isDoctorLastSender =
        (chat['lastSenderId'] ?? '')
                .toString() ==
            (FirebaseAuth
                    .instance
                    .currentUser
                    ?.uid ??
                '');

    return GestureDetector(
      onTap: () {
        _openChat(
          chat,
        );
      },
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFFFFFCF9),
          borderRadius:
              BorderRadius.circular(
            19,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                0.08,
              ),
              blurRadius: 7,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            // =====================================================
            // FOTO PASIEN
            // =====================================================

            Container(
              width: 56,
              height: 56,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFFE3D1),
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color:
                    Color(0xFFB65339),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // =====================================================
            // INFORMASI CHAT
            // =====================================================

            Expanded(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // NAMA + WAKTU
                  // =================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 12,
                            fontWeight:
                                isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                            color:
                                Colors.black,
                          ),
                        ),
                      ),

                      if (time
                          .isNotEmpty) ...[
                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          time,
                          style:
                              const TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 11,
                            color:
                                Colors.black,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // =================================================
                  // PESAN + UNREAD
                  // =================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      if (isDoctorLastSender)
                        const Padding(
                          padding:
                              EdgeInsets.only(
                            right: 4,
                          ),
                          child: Icon(
                            Icons
                                .done_all_rounded,
                            size: 14,
                            color:
                                Colors.black,
                          ),
                        ),

                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 11,
                            fontWeight:
                                isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                            color:
                                Colors.black,
                          ),
                        ),
                      ),

                      if (isUnread)
                        Container(
                          constraints:
                              const BoxConstraints(
                            minWidth: 20,
                          ),
                          height: 20,
                          margin:
                              const EdgeInsets
                                  .only(
                            left: 7,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 5,
                          ),
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xFFB65339,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              Center(
                            child:
                                Text(
                              unread >
                                      99
                                  ? '99+'
                                  : unread
                                      .toString(),
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  const TextStyle(
                                fontFamily:
                                    'Nunito',
                                fontSize:
                                    11,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        padding:
            const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  BoxDecoration(
                color: softOrange,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 31,
                color:
                    primaryBrown,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,
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
                    Colors.black,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 11,
                color:
                    Colors.black,
                fontWeight:
                    FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // FORMAT WAKTU
  // ===============================================================

  String _formatTime(
    dynamic timestamp,
  ) {
    if (timestamp is! Timestamp) {
      return '';
    }

    final DateTime date =
        timestamp.toDate();

    final String hour =
        date.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$hour:$minute';
  }
}