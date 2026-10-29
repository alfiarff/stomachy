import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../notification_screen.dart';

class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({super.key});

  @override
  State<DoctorNotificationScreen> createState() =>
      _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB9543A);

  bool _isLoading = true;
  bool _markedAsReadOnOpen = false;

  List<LocalNotification> _unread = [];
  List<LocalNotification> _read = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  // ===============================================================
  // DENGARKAN NOTIFIKASI SECARA REALTIME
  // ===============================================================

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen(
      (snapshot) async {
        final items = snapshot.docs
            .map((doc) => LocalNotification.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();

        final unread = items
            .where((item) =>
                !item.isRead && AppNotification.isFresh(item))
            .toList();

        final read = items
            .where((item) =>
                item.isRead || !AppNotification.isFresh(item))
            .toList();

        if (!mounted) return;
        setState(() {
          _unread = unread;
          _read = read;
          _isLoading = false;
        });

        // Tandai notifikasi yang sudah ada sebagai dibaca saat halaman dibuka.
        // Flag mencegah proses ini berjalan berulang setiap snapshot berubah.
        if (!_markedAsReadOnOpen) {
          _markedAsReadOnOpen = true;
          try {
            await AppNotification.markAllAsRead(user.uid);
          } catch (e) {
            debugPrint('GAGAL MENANDAI NOTIFIKASI DIBACA: $e');
            _markedAsReadOnOpen = false;
          }
        }
      },
      onError: (Object error) {
        debugPrint('NOTIFIKASI DOKTER REALTIME ERROR: $error');
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // ===============================================================
  // FORMAT WAKTU
  // ===============================================================

  String _formatLabel(DateTime date, {required bool isUnread}) {
    if (isUnread) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$hour.$minute';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final thatDay = DateTime(date.year, date.month, date.day);

    final int diffDays = today.difference(thatDay).inDays;

    if (diffDays <= 7) {
      const days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];

      return days[date.weekday - 1];
    }

    return '${date.day} ${_monthShort(date.month)}';
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month];
  }

  // ===============================================================
  // STYLE PER TIPE NOTIFIKASI
  // ===============================================================

  ({String emoji, Color bg}) _typeStyle(String type) {
    switch (type) {
      case 'chat':
        return (emoji: '🧑‍🦰', bg: const Color(0xFFDFF2E4));

      case 'artikel':
        return (emoji: '📰', bg: const Color(0xFFE9E2F8));

      case 'edukasi':
        return (emoji: '📚', bg: const Color(0xFFE9E2F8));

      case 'olahraga':
        return (emoji: '🏃', bg: const Color(0xFFE2F1DB));

      case 'makanan':
        return (emoji: '🥗', bg: const Color(0xFFE2F1DB));

      case 'skrining':
        return (emoji: '⏰', bg: const Color(0xFFFCE0DB));

      default:
        return (emoji: '🔔', bg: const Color(0xFFFFE8D8));
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB9543A)),
              )
            : _buildContent(),
      ),
    );
  }

  // ===============================================================
  // KONTEN UTAMA
  // ===============================================================

  Widget _buildContent() {
    final bool isEmpty = _unread.isEmpty && _read.isEmpty;

    if (isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          // ================================================
          // BELUM DIBACA
          // ================================================
          if (_unread.isNotEmpty) ...[
            const SizedBox(height: 24),

            Text(
              'Belum Dibaca (${_unread.length})',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF30221E),
              ),
            ),

            const SizedBox(height: 12),

            for (int i = 0; i < _unread.length; i++) ...[
              _buildNotificationCard(item: _unread[i], isUnread: true),

              if (i != _unread.length - 1) const SizedBox(height: 11),
            ],
          ],

          // ================================================
          // SEBELUMNYA
          // ================================================
          if (_read.isNotEmpty) ...[
            const SizedBox(height: 22),

            const Text(
              'Sebelumnya',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF30221E),
              ),
            ),

            const SizedBox(height: 12),

            for (int i = 0; i < _read.length; i++) ...[
              _buildNotificationCard(item: _read[i], isUnread: false),

              if (i != _read.length - 1) const SizedBox(height: 11),
            ],
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Notifikasi',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ===============================================================
  // KARTU NOTIFIKASI
  // ===============================================================

  Widget _buildNotificationCard({
    required LocalNotification item,
    required bool isUnread,
  }) {
    final style = _typeStyle(item.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
            child: Center(
              child: Text(style.emoji, style: const TextStyle(fontSize: 19)),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                    color: const Color(0xFF30221E),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  item.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    color: const Color(0xFF675B57),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            _formatLabel(item.createdAt, isUnread: isUnread),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF77716E),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 52)),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Belum Ada Notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171310),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Notifikasi pesan baru dari pasien akan muncul disini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF493C37),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
