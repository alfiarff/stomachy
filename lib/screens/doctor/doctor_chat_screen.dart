import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/doctor_bottom_navigation.dart';
import 'doctorr_home_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_profile_screen.dart';
class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});
  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}
class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showUnreadOnly = false;
  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color brown = Color(0xFFB65339);
  static const Color softOrange = Color(0xFFFFE3D1);
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
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
  Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream() {
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
  Timestamp? _getTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value;
    }
    return null;
  }
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
  List<Map<String, dynamic>> _buildChatList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<Map<String, dynamic>> chats = [];
    for (final document in snapshot.docs) {
      final Map<String, dynamic> data =
          document.data();
      final String status =
          (data['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      if (status != 'booked' &&
          status != 'active' &&
          status != 'completed') {
        continue;
      }
      final String userId =
          (data['userId'] ?? '')
              .toString()
              .trim();
      if (userId.isEmpty) {
        continue;
      }
      final String lastMessage =
          (data['lastMessage'] ?? '')
              .toString()
              .trim();
      // Konsultasi selesai hanya ditampilkan
      // kalau memang pernah mempunyai pesan.
      if (status == 'completed' &&
          lastMessage.isEmpty) {
        continue;
      }
      chats.add({
        ...data,
        'consultationId': document.id,
      });
    }
    chats.sort((a, b) {
      final Timestamp? aTime =
          _getTimestamp(a['updatedAt']) ??
              _getTimestamp(a['createdAt']) ??
              _getTimestamp(
                a['consultationTimestamp'],
              );
      final Timestamp? bTime =
          _getTimestamp(b['updatedAt']) ??
              _getTimestamp(b['createdAt']) ??
              _getTimestamp(
                b['consultationTimestamp'],
              );
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
    });
    return chats;
  }
  List<Map<String, dynamic>> _filterChats(
    List<Map<String, dynamic>> chats,
  ) {
    return chats.where((chat) {
      final String name =
          (chat['userName'] ??
                  chat['name'] ??
                  '')
              .toString()
              .toLowerCase();
      final int unread =
          _toInt(chat['unreadForDoctor']);
      final bool matchesSearch =
          name.contains(_searchQuery);
      final bool matchesUnread =
          !_showUnreadOnly || unread > 0;
      return matchesSearch &&
          matchesUnread;
    }).toList();
  }
  int _getUnreadCount(
    List<Map<String, dynamic>> chats,
  ) {
    int total = 0;
    for (final chat in chats) {
      total += _toInt(
        chat['unreadForDoctor'],
      );
    }
    return total;
  }
  void _onNavigationTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DoctorHomeScreen(),
        ),
      );
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
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
          builder: (_) =>
              const DoctorProfileScreen(),
        ),
      );
    }
  }
  void _openChat(
    Map<String, dynamic> chat,
  ) {
    final String status =
        (chat['status'] ?? '')
            .toString()
            .toLowerCase();
    if (status == 'booked') {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Belum waktunya konsultasi.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
              ),
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
      return;
    }
    if (status != 'active' &&
        status != 'completed') {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DoctorPatientChatScreen(
          patient: chat,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
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
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 12),
              StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream: _chatStream(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final chats = snapshot.hasData
                      ? _buildChatList(
                          snapshot.data!,
                        )
                      : <Map<String, dynamic>>[];
                  return _buildFilterButtons(
                    _getUnreadCount(chats),
                  );
                },
              ),
              const SizedBox(height: 14),
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
                          color: brown,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildEmptyState(
                        Icons.error_outline_rounded,
                        'Chat tidak dapat dimuat',
                        'Coba periksa koneksi atau Firestore.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return _buildEmptyState(
                        Icons.chat_bubble_outline_rounded,
                        'Belum ada chat',
                        'Chat dengan pasien akan muncul di sini.',
                      );
                    }
                    final allChats =
                        _buildChatList(
                      snapshot.data!,
                    );
                    final chats =
                        _filterChats(
                      allChats,
                    );
                    if (allChats.isEmpty) {
                      return _buildEmptyState(
                        Icons.chat_bubble_outline_rounded,
                        'Belum ada chat',
                        'Chat dengan pasien akan muncul di sini.',
                      );
                    }
                    if (chats.isEmpty) {
                      return _buildEmptyState(
                        Icons.mark_chat_unread_outlined,
                        'Tidak ada chat belum dibaca',
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
                      itemCount: chats.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 11,
                      ),
                      itemBuilder:
                          (context, index) {
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
  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pop(context),
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
          const Expanded(
            child: Center(
              child: Text(
                'Daftar Chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.07,
            ),
            blurRadius: 6,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 19,
            color: brown,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller:
                  _searchController,
              textAlignVertical:
                  TextAlignVertical.center,
              style:
                  const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.black,
              ),
              decoration:
                  const InputDecoration(
                border:
                    InputBorder.none,
                isCollapsed: true,
                hintText:
                    'Cari nama pasien...',
                hintStyle:
                    TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterButtons(
    int unreadCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterButton(
            'Semua',
            !_showUnreadOnly,
            () {
              if (_showUnreadOnly) {
                setState(() {
                  _showUnreadOnly =
                      false;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFilterButton(
            unreadCount > 0
                ? 'Belum Dibaca ($unreadCount)'
                : 'Belum Dibaca',
            _showUnreadOnly,
            () {
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
  Widget _buildFilterButton(
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Container(
        height: 38,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color: selected
              ? brown
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            19,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.07,
              ),
              blurRadius: 5,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Nunito',
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
  Widget _buildChatCard(
    Map<String, dynamic> chat,
  ) {
    final String name =
        (chat['userName'] ??
                chat['name'] ??
                'Pasien')
            .toString();
    final String status =
        (chat['status'] ?? '')
            .toString()
            .toLowerCase();
    final String message =
        (chat['lastMessage'] ?? '')
            .toString()
            .trim();
    final String day =
        (chat['consultationDay'] ?? '')
            .toString();
    final String time =
        (chat['consultationTime'] ?? '')
            .toString();
    final int unread =
        _toInt(
      chat['unreadForDoctor'],
    );
    final bool completed =
        status == 'completed';
    final bool booked =
        status == 'booked';
    final String statusText =
        completed
            ? 'Selesai'
            : booked
                ? 'Belum waktunya'
                : 'Aktif';
    return GestureDetector(
      onTap: () => _openChat(chat),
      behavior:
          HitTestBehavior.opaque,
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.08,
              ),
              blurRadius: 6,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration:
                  const BoxDecoration(
                color: softOrange,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.person_rounded,
                size: 32,
                color: brown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Colors.black,
                          ),
                        ),
                      ),
                      if (unread > 0 &&
                          !completed &&
                          !booked)
                        Container(
                          height: 20,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 6,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: brown,
                            shape:
                                BoxShape.circle,
                          ),
                          alignment:
                              Alignment.center,
                          child: Text(
                            unread > 99
                                ? '99+'
                                : '$unread',
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
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.isEmpty
                        ? 'Belum ada pesan'
                        : message,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontFamily:
                          'Nunito',
                      fontSize: 10.5,
                      color:
                          Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        statusText,
                        style:
                            TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              completed
                                  ? Colors.black
                                  : booked
                                      ? const Color(
                                          0xFF9A6B00,
                                        )
                                      : const Color(
                                          0xFF188447,
                                        ),
                        ),
                      ),
                      if (day.isNotEmpty ||
                          time.isNotEmpty) ...[
                        const SizedBox(width: 7),
                        const Text(
                          '•',
                          style:
                              TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 9,
                            color:
                                Colors.black,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            day.isNotEmpty
                                ? '$day${time.isNotEmpty ? ', $time' : ''}'
                                : time,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontFamily:
                                  'Nunito',
                              fontSize: 9,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),
                      ],
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
  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  const BoxDecoration(
                color: softOrange,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 35,
                color: brown,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
                color:
                    Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 11,
                height: 1.4,
                color:
                    Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
