
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../services/notification_service.dart';
import '../services/admin_content_service.dart';
import 'user_content_detail_screen.dart';
import 'admin/admin_article_detail_screen.dart';

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

  static CollectionReference<Map<String, dynamic>> _notifications(
    String uid,
  ) {
    return _db.collection('users').doc(uid).collection('notifications');
  }

  // ===============================================================
  // CEK PENGATURAN NOTIFIKASI
  // ===============================================================

  static Future<bool> isCategoryEnabled(String uid, String type) async {
    // Booking dan pesan pasien selalu diizinkan.
    if (type == 'consultation' || type == 'pesan_pasien') {
      return true;
    }

    final key = _settingKeys[type];

    if (key == null) return false;

    final userDoc = await _db.collection('users').doc(uid).get();
    final settings = userDoc.data()?['settings'];

    if (settings is Map && settings.containsKey(key)) {
      return settings[key] == true;
    }

    // Default sesuai nilai awal SettingsScreen.
    return type != 'chat';
  }

  // ===============================================================
  // MEMBUAT NOTIFIKASI
  // ===============================================================

  static Future<void> create({
    required String uid,
    required String type,
    required String title,
    required String body,
    String? contentId,
    DateTime? createdAt,
    DateTime? visibleAt,
    String? notificationId,
    bool respectSetting = true,
    bool overwriteExisting = false,
  }) async {
    if (uid.isEmpty || title.trim().isEmpty) return;

    try {
      if (respectSetting &&
          !await isCategoryEnabled(uid, type)) {
        debugPrint(
          'Notifikasi $type dilewati karena kategori nonaktif.',
        );
        return;
      }

      final collection = _notifications(uid);

      final hasCustomId =
          notificationId != null && notificationId.trim().isNotEmpty;

      final doc = hasCustomId
          ? collection.doc(notificationId)
          : collection.doc();

      // Mencegah notifikasi dengan ID yang sama tersimpan dua kali.
      if (hasCustomId && !overwriteExisting && (await doc.get()).exists) {
        return;
      }

      await doc.set({
        'id': doc.id,
        'type': type,
        'title': title,
        'body': body,
        'contentId': contentId,
        'createdAt': Timestamp.fromDate(
          createdAt ?? DateTime.now(),
        ),
        if (visibleAt != null) 'visibleAt': Timestamp.fromDate(visibleAt),
        'isRead': false,
      });

      debugPrint('NOTIFIKASI TERSIMPAN DI FIRESTORE: $title');

      // Perbarui badge khusus notifikasi booking.
      // Mekanisme notifikasi chat tetap dipertahankan.
      if (type == 'consultation') {
        NotificationService.badgeSignal.value++;
      }
    } catch (e) {
      debugPrint('NOTIFIKASI CREATE ERROR: $e');
      rethrow;
    }
  }

  // ===============================================================
  // MENGAMBIL SEMUA NOTIFIKASI
  // ===============================================================

  static Future<List<LocalNotification>> getAll(String uid) async {
    final snapshot = await _notifications(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map(
          (doc) => LocalNotification.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();
  }

  static bool isFresh(LocalNotification item) {
    return item.createdAt.isAfter(
      DateTime.now().subtract(freshWindow),
    );
  }

  static Future<int> getRecentUnreadCount(String uid) async {
    final items = await getAll(uid);

    return items
        .where((item) => !item.isRead && isFresh(item))
        .length;
  }

  // ===============================================================
  // TANDAI SEMUA DIBACA
  // ===============================================================

  static Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notifications(uid)
        .where('isRead', isEqualTo: false)
        .get();

    final now = DateTime.now();
    final visibleDocs = snapshot.docs.where((doc) {
      final rawVisibleAt = doc.data()['visibleAt'];
      if (rawVisibleAt == null) return true;
      final visibleAt = rawVisibleAt is Timestamp
          ? rawVisibleAt.toDate()
          : DateTime.tryParse(rawVisibleAt.toString());
      return visibleAt == null || !visibleAt.isAfter(now);
    }).toList();

    for (var start = 0; start < visibleDocs.length; start += 450) {
      final batch = _db.batch();

      final end = (start + 450 < visibleDocs.length)
          ? start + 450
          : visibleDocs.length;

      for (var i = start; i < end; i++) {
        batch.update(
          visibleDocs[i].reference,
          {'isRead': true},
        );
      }

      await batch.commit();
    }
  }

  // ===============================================================
  // HAPUS SEMUA NOTIFIKASI
  // ===============================================================

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

// ===============================================================
// MODEL NOTIFIKASI
// ===============================================================

class LocalNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? visibleAt;
  final bool isRead;
  final String? contentId;

  const LocalNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.visibleAt,
    required this.isRead,
    required this.contentId,
  });

  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    final rawDate = map['createdAt'];

    DateTime date;

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is num) {
      date = DateTime.fromMillisecondsSinceEpoch(
        rawDate.toInt(),
      );
    } else {
      date = DateTime.now();
    }

    final rawVisibleAt = map['visibleAt'];
    DateTime? visibleAt;
    if (rawVisibleAt is Timestamp) {
      visibleAt = rawVisibleAt.toDate();
    } else if (rawVisibleAt is DateTime) {
      visibleAt = rawVisibleAt;
    } else if (rawVisibleAt != null) {
      visibleAt = DateTime.tryParse(rawVisibleAt.toString());
    }

    return LocalNotification(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      createdAt: date,
      visibleAt: visibleAt,
      isRead: map['isRead'] == true,
      contentId: map['contentId']?.toString(),
    );
  }

  bool get isVisible => visibleAt == null || !visibleAt!.isAfter(DateTime.now());

  LocalNotification copyWith({bool? isRead}) {
    return LocalNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      visibleAt: visibleAt,
      isRead: isRead ?? this.isRead,
      contentId: contentId,
    );
  }
}

// ===============================================================
// SCREEN NOTIFIKASI
// ===============================================================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB9543A);

  bool _isLoading = true;

  List<LocalNotification> _unread = [];
  List<LocalNotification> _read = [];
  List<LocalNotification> _allNotifications = [];
  Timer? _visibilityTimer;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  @override
  void initState() {
    super.initState();

    _listenToNotifications();
    _markNotificationsAsReadOnOpen();
    _visibilityTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _applyVisibleNotifications(),
    );
  }

  // ===============================================================
  // FORMAT NAMA DOKTER
  // ===============================================================

  String _addDoctorPrefix(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return trimmedName;

    if (RegExp(r'^dr\.?\s', caseSensitive: false)
        .hasMatch(trimmedName)) {
      return trimmedName;
    }

    return 'dr. $trimmedName';
  }

  String _formatNotificationBody(LocalNotification item) {
    final body = item.body.trim();

    if (body.isEmpty) return body;

    // Notifikasi dokter membalas pesan.
    if (item.type == 'chat' &&
        item.title == 'Dokter Membalas Pesanmu') {
      return _addDoctorPrefix(body);
    }

    // Notifikasi booking konsultasi.
    // Format: Konsultasi dengan Nama Dokter pada ...
    if (item.type == 'consultation') {
      const prefix = 'Konsultasi dengan ';

      if (body.toLowerCase().startsWith(
            prefix.toLowerCase(),
          )) {
        final startIndex = prefix.length;
        final endIndex = body.toLowerCase().indexOf(
              ' pada ',
              startIndex,
            );

        if (endIndex > startIndex) {
          final doctorName = body.substring(
            startIndex,
            endIndex,
          ).trim();

          final formattedName = _addDoctorPrefix(doctorName);

          return '$prefix$formattedName${body.substring(endIndex)}';
        }
      }
    }

    return body;
  }

  // ===============================================================
  // BUKA KONTEN NOTIFIKASI
  // ===============================================================

  Future<void> _openNotificationContent(
    LocalNotification item,
  ) async {
    final contentId = item.contentId;

    if (contentId == null || contentId.isEmpty) {
      debugPrint('NOTIFIKASI: contentId tidak tersedia.');
      return;
    }

    try {
      if (item.type == 'artikel') {
        final doc = await FirebaseFirestore.instance
            .collection('articles')
            .doc(contentId)
            .get();

        if (!mounted || !doc.exists) return;

        final article = AdminArticle.fromFirestore(doc);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminArticleDetailScreen(
              article: article,
            ),
          ),
        );

        return;
      }

      if (['edukasi', 'makanan', 'olahraga']
          .contains(item.type)) {
        final doc = await FirebaseFirestore.instance
            .collection('contents')
            .doc(contentId)
            .get();

        if (!mounted || !doc.exists) return;

        final content = AdminContentItem.fromFirestore(doc);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserContentDetailScreen(
              item: content,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('NOTIFIKASI: gagal membuka konten: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konten gagal dibuka.'),
        ),
      );
    }
  }

  // ===============================================================
  // TANDAI NOTIFIKASI DIBACA SAAT HALAMAN DIBUKA
  // ===============================================================

  Future<void> _markNotificationsAsReadOnOpen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await AppNotification.markAllAsRead(user.uid);
    } catch (e) {
      debugPrint('NOTIFIKASI MARK AS READ ERROR: $e');
    }
  }

  // ===============================================================
  // REALTIME LISTENER
  // ===============================================================

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

        _allNotifications = items;
        _applyVisibleNotifications();
      },
      onError: (Object error) {
        debugPrint('NOTIFIKASI REALTIME ERROR: $error');

        if (!mounted) return;

        setState(() => _isLoading = false);
      },
    );
  }

  void _applyVisibleNotifications() {
    final visibleItems = _allNotifications
        .where((item) => item.isVisible)
        .toList();

    final unread = visibleItems
        .where((item) => !item.isRead && AppNotification.isFresh(item))
        .toList();

    final read = visibleItems
        .where((item) => item.isRead || !AppNotification.isFresh(item))
        .toList();

    if (!mounted) return;
    setState(() {
      _unread = unread;
      _read = read;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // ===============================================================
  // LOAD NOTIFIKASI
  // ===============================================================

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final items = await AppNotification.getAll(user.uid);

      _allNotifications = items;
      _applyVisibleNotifications();

      if (!mounted) return;

      await AppNotification.markAllAsRead(user.uid);
    } catch (e) {
      debugPrint('NOTIFIKASI LOAD ERROR: $e');

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifikasi gagal dimuat. Periksa koneksi dan aturan Firestore.',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // FORMAT WAKTU
  // ===============================================================

  String _formatLabel(
    DateTime date, {
    required bool isUnread,
  }) {
    if (isUnread) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$hour.$minute';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(thatDay).inDays;

    if (diffDays >= 0 && diffDays <= 7) {
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
      case 'consultation':
        return (
          emoji: '📅',
          bg: const Color(0xFFFFE8D8),
        );

      case 'chat':
        return (
          emoji: '👨‍⚕️',
          bg: const Color(0xFFDFF2E4),
        );

      case 'artikel':
        return (
          emoji: '📰',
          bg: const Color(0xFFE9E2F8),
        );

      case 'edukasi':
        return (
          emoji: '📚',
          bg: const Color(0xFFE9E2F8),
        );

      case 'olahraga':
        return (
          emoji: '🏃',
          bg: const Color(0xFFE2F1DB),
        );

      case 'makanan':
        return (
          emoji: '🥗',
          bg: const Color(0xFFE2F1DB),
        );

      case 'skrining':
        return (
          emoji: '⏰',
          bg: const Color(0xFFFCE0DB),
        );

      default:
        return (
          emoji: '🔔',
          bg: const Color(0xFFFFE8D8),
        );
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
                child: CircularProgressIndicator(
                  color: Color(0xFFB9543A),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  // ===============================================================
  // KONTEN UTAMA
  // ===============================================================

  Widget _buildContent() {
    final isEmpty = _unread.isEmpty && _read.isEmpty;

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

          // BELUM DIBACA
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
              _buildNotificationCard(
                item: _unread[i],
                isUnread: true,
              ),
              if (i != _unread.length - 1)
                const SizedBox(height: 11),
            ],
          ],

          // SEBELUMNYA
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
              _buildNotificationCard(
                item: _read[i],
                isUnread: false,
              ),
              if (i != _read.length - 1)
                const SizedBox(height: 11),
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

    return InkWell(
      onTap: () => _openNotificationContent(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
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
              decoration: BoxDecoration(
                color: style.bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  style.emoji,
                  style: const TextStyle(fontSize: 19),
                ),
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
                      fontWeight: isUnread
                          ? FontWeight.w800
                          : FontWeight.w700,
                      color: const Color(0xFF30221E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatNotificationBody(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight: isUnread
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: const Color(0xFF675B57),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatLabel(
                item.createdAt,
                isUnread: isUnread,
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF77716E),
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
                child: Text(
                  '🔔',
                  style: TextStyle(fontSize: 52),
                ),
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
