import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// ===============================================================
// PENYIMPANAN NOTIFIKASI DI FIRESTORE
// Path: users/{uid}/notifications/{notificationId}
// ===============================================================

class AppNotification {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const Duration freshWindow = Duration(hours: 24);

  static const Map<String, String> _settingKeys = {
    'chat': 'notifBalasanDokter',
    'edukasi': 'notifEdukasi',
    'artikel': 'notifArtikel',
    'makanan': 'notifMakanan',
    'olahraga': 'notifOlahraga',
  };

  static CollectionReference<Map<String, dynamic>> _notifications(String uid) {
    return _db.collection('users').doc(uid).collection('notifications');
  }

  static Future<bool> isCategoryEnabled(String uid, String type) async {
    // Notifikasi pesan pasien untuk akun dokter bukan kategori preferensi pasien.
    if (type == 'pesan_pasien') return true;

    final key = _settingKeys[type];
    if (key == null) return false;

    final userDoc = await _db.collection('users').doc(uid).get();
    final settings = userDoc.data()?['settings'];

    if (settings is Map && settings.containsKey(key)) {
      return settings[key] == true;
    }

    // Default sesuai nilai awal pada SettingsScreen.
    return type != 'chat';
  }


static Future<void> create({
  required String uid,
  required String type,
  required String title,
  required String body,
  DateTime? createdAt,
  String? notificationId,
  bool respectSetting = true,
}) async {
  if (uid.isEmpty || title.trim().isEmpty) return;

  try {
    // Periksa pengaturan hanya jika respectSetting bernilai true.
    if (respectSetting &&
        !await isCategoryEnabled(uid, type)) {
      debugPrint(
        'Notifikasi $type dilewati karena kategori nonaktif.',
      );
      return;
    }

    final collection = _notifications(uid);

    final doc =
        notificationId != null &&
                notificationId.trim().isNotEmpty
            ? collection.doc(notificationId)
            : collection.doc();

    // Hindari menyimpan notifikasi yang sama dua kali.
    if (notificationId != null &&
        notificationId.trim().isNotEmpty) {
      if ((await doc.get()).exists) return;
    }

    await doc.set({
      'id': doc.id,
      'type': type,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(
        createdAt ?? DateTime.now(),
      ),
      'isRead': false,
    });

    debugPrint('NOTIFIKASI TERSIMPAN DI FIRESTORE: $title');
  } catch (e) {
    debugPrint('NOTIFIKASI CREATE ERROR: $e');
    rethrow;
  }
}

  static Future<List<LocalNotification>> getAll(String uid) async {
    final snapshot = await _notifications(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map((doc) => LocalNotification.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  static bool isFresh(LocalNotification item) =>
      item.createdAt.isAfter(DateTime.now().subtract(freshWindow));

  static Future<int> getRecentUnreadCount(String uid) async {
    final items = await getAll(uid);
    return items.where((item) => !item.isRead && isFresh(item)).length;
  }

  static Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notifications(uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var start = 0; start < snapshot.docs.length; start += 450) {
      final batch = _db.batch();
      final end = (start + 450 < snapshot.docs.length)
          ? start + 450
          : snapshot.docs.length;
      for (var i = start; i < end; i++) {
        batch.update(snapshot.docs[i].reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  static Future<void> clearAll(String uid) async {
    final snapshot = await _notifications(uid).get();
    for (var start = 0; start < snapshot.docs.length; start += 450) {
      final batch = _db.batch();
      final end = (start + 450 < snapshot.docs.length)
          ? start + 450
          : snapshot.docs.length;
      for (var i = start; i < end; i++) {
        batch.delete(snapshot.docs[i].reference);
      }
      await batch.commit();
    }
  }
}

class LocalNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const LocalNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is num) {
      date = DateTime.fromMillisecondsSinceEpoch(rawDate.toInt());
    } else {
      date = DateTime.now();
    }

    return LocalNotification(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      createdAt: date,
      isRead: map['isRead'] == true,
    );
  }

  LocalNotification copyWith({bool? isRead}) => LocalNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );
}

// ===============================================================
// SCREEN NOTIFIKASI
// ===============================================================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB9543A);


bool _isLoading = true;

List<LocalNotification> _unread = [];
List<LocalNotification> _read = [];

StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    _notificationSubscription;



@override
void initState() {
  super.initState();
  _listenToNotifications();
}

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
    (snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => LocalNotification.fromMap({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();

      final unread = items
          .where(
            (item) =>
                !item.isRead && AppNotification.isFresh(item),
          )
          .toList();

      final read = items
          .where(
            (item) =>
                item.isRead || !AppNotification.isFresh(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _unread = unread;
        _read = read;
        _isLoading = false;
      });
    },
    onError: (Object error) {
      debugPrint('NOTIFIKASI REALTIME ERROR: $error');

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
  // LOAD NOTIFIKASI + TANDAI SEMUA DIBACA
  // ===============================================================

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final items = await AppNotification.getAll(user.uid);
      final unread = items
          .where((item) => !item.isRead && AppNotification.isFresh(item))
          .toList();
      final read = items
          .where((item) => item.isRead || !AppNotification.isFresh(item))
          .toList();

      if (!mounted) return;
      setState(() {
        _unread = unread;
        _read = read;
        _isLoading = false;
      });

      // Dipertahankan sesuai perilaku kode asli: tandai dibaca saat halaman dibuka.
      await AppNotification.markAllAsRead(user.uid);
    } catch (e) {
      debugPrint('NOTIFIKASI LOAD ERROR: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi gagal dimuat. Periksa koneksi dan aturan Firestore.')),
      );
    }
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
        return (emoji: '👨‍⚕️', bg: const Color(0xFFDFF2E4));

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
                  item.type == 'chat' &&
                          item.title == 'Dokter Membalas Pesanmu' &&
                          item.body.trim().isNotEmpty &&
                          !item.body.trim().toLowerCase().startsWith('dr.')
                      ? 'dr. ${item.body.trim()}'
                      : item.body,
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
              'Notifikasi balasan dokter, artikel mingguan, konten baru dan pengingat skrining mingguan akan muncul disini.',
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
