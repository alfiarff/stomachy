import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

// ===============================================================
// PENYIMPANAN NOTIFIKASI LOKAL (SharedPreferences)
//
// Sementara memakai penyimpanan lokal di dalam HP karena
// akses Firestore terblokir aturan keamanan (permission-denied).
// Tidak butuh internet & tidak butuh Firebase Console.
// ===============================================================

class AppNotification {
  static const String _keyPrefix =
      'stomachy_notifications_';

  static String _key(String uid) => '$_keyPrefix$uid';

  // -------------------------------------------------------------
  // BUAT NOTIFIKASI BARU
  // -------------------------------------------------------------

  static Future<void> create({
    required String uid,
    required String type,
    required String title,
    required String body,

    // Opsional — dipakai untuk tes notifikasi lama
    DateTime? createdAt,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final List<LocalNotification> items =
          await getAll(uid);

      items.insert(
        0,
        LocalNotification(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          type: type,
          title: title,
          body: body,
          createdAt:
              createdAt ?? DateTime.now(),
          isRead: false,
        ),
      );

      // Simpan maksimal 50 notifikasi terbaru
      final List<LocalNotification> trimmed =
          items.take(50).toList();

      await prefs.setString(
        _key(uid),
        jsonEncode(
          trimmed.map((item) => item.toMap()).toList(),
        ),
      );
    } catch (e) {
      debugPrint('NOTIFIKASI CREATE ERROR: $e');
    }
  }

  // -------------------------------------------------------------
  // AMBIL SEMUA NOTIFIKASI (TERBARU DI ATAS)
  // -------------------------------------------------------------

  static Future<List<LocalNotification>> getAll(
    String uid,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final String? raw = prefs.getString(_key(uid));

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final List decoded = jsonDecode(raw) as List;

      return decoded.map((item) {
        return LocalNotification.fromMap(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } catch (e) {
      debugPrint('NOTIFIKASI PARSE ERROR: $e');
      return [];
    }
  }

  // -------------------------------------------------------------
  // BATAS WAKTU "BELUM DIBACA"
  //
  // Notifikasi berumur lebih dari 24 jam otomatis pindah
  // ke bagian "Sebelumnya" meskipun belum dibaca.
  // -------------------------------------------------------------

  static const Duration freshWindow =
      Duration(hours: 24);

  static bool isFresh(LocalNotification item) {
    final DateTime cutoff =
        DateTime.now().subtract(freshWindow);

    return item.createdAt.isAfter(cutoff);
  }

  // -------------------------------------------------------------
  // JUMLAH BELUM DIBACA YANG MASIH < 24 JAM
  //
  // Dipakai badge lonceng di beranda supaya angkanya
  // konsisten dengan isi halaman notifikasi.
  // -------------------------------------------------------------

  static Future<int> getRecentUnreadCount(
    String uid,
  ) async {
    final items = await getAll(uid);

    return items
        .where(
          (item) =>
              !item.isRead &&
              isFresh(item),
        )
        .length;
  }

  // -------------------------------------------------------------
  // TANDAI SEMUA SEBAGAI DIBACA
  // -------------------------------------------------------------

  static Future<void> markAllAsRead(String uid) async {
    final items = await getAll(uid);

    if (items.isEmpty) return;

    final updated = items
        .map((item) => item.copyWith(isRead: true))
        .toList();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _key(uid),
      jsonEncode(
        updated.map((item) => item.toMap()).toList(),
      ),
    );
  }

  // -------------------------------------------------------------
  // HAPUS SEMUA (UNTUK TES)
  // -------------------------------------------------------------

  static Future<void> clearAll(String uid) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key(uid));
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
  final bool isRead;

  const LocalNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'createdAt':
          createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory LocalNotification.fromMap(
    Map<String, dynamic> map,
  ) {
    return LocalNotification(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      isRead: map['isRead'] == true,
    );
  }

  LocalNotification copyWith({bool? isRead}) {
    return LocalNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
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

class _NotificationScreenState
    extends State<NotificationScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color accentBrown = const Color(0xFFB9543A);

  bool _isLoading = true;

  List<LocalNotification> _unread = [];
  List<LocalNotification> _read = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ===============================================================
  // LOAD NOTIFIKASI + TANDAI SEMUA DIBACA
  // ===============================================================

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final items =
        await AppNotification.getAll(user.uid);

    // Belum dibaca DAN belum lewat 24 jam
    final List<LocalNotification> unread = items
        .where(
          (item) =>
              !item.isRead &&
              AppNotification.isFresh(item),
        )
        .toList();

    // Sudah dibaca ATAU sudah lewat 24 jam
    final List<LocalNotification> read = items
        .where(
          (item) =>
              item.isRead ||
              !AppNotification.isFresh(item),
        )
        .toList();

    if (!mounted) return;

    setState(() {
      _unread = unread;
      _read = read;
      _isLoading = false;
    });

    // Tandai semua sebagai dibaca
    // -> badge di beranda otomatis hilang
    await AppNotification.markAllAsRead(user.uid);
  }

  // ===============================================================
  // FORMAT WAKTU
  // ===============================================================

  String _formatLabel(
    DateTime date, {
    required bool isUnread,
  }) {
    if (isUnread) {
      final hour =
          date.hour.toString().padLeft(2, '0');
      final minute =
          date.minute.toString().padLeft(2, '0');

      return '$hour.$minute';
    }

    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final thatDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int diffDays =
        today.difference(thatDay).inDays;

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

  ({String emoji, Color bg}) _typeStyle(
    String type,
  ) {
    switch (type) {
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
    final bool isEmpty =
        _unread.isEmpty && _read.isEmpty;

    if (isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        22,
        12,
        22,
        30,
      ),
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
              _buildNotificationCard(
                item: _unread[i],
                isUnread: true,
              ),

              if (i != _unread.length - 1)
                const SizedBox(height: 11),
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
              _buildNotificationCard(
                item: _read[i],
                isUnread: false,
              ),

              if (i != _read.length - 1)
                const SizedBox(height: 11),
            ],
          ],

          const SizedBox(height: 26),

          // ================================================
          // TOMBOL TES (SELALU TERLIHAT)
          // ================================================

          _buildTestButtons(),

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
                  fontFamily: 'Nunito',
                  fontSize: 24,
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
                style: const TextStyle(
                  fontSize: 19,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  item.body,
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
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 34,
        ),
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
                  style: TextStyle(
                    fontSize: 52,
                  ),
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

            const SizedBox(height: 26),

            _buildTestButtons(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ⚠️ TOMBOL TES SEMENTARA — HAPUS SETELAH SELESAI TES!
  //
  // Selalu tampil (baik di empty state maupun di bawah
  // daftar notifikasi) supaya bisa membuat notifikasi
  // baru kapan saja untuk pengujian.
  // ===============================================================

  Widget _buildTestButtons() {
    return Column(
      children: [
        // NOTIFIKASI BARU (SEKARANG)
        SizedBox(
          width: 210,
          height: 46,
          child: ElevatedButton(
            onPressed: () async {
              final user =
                  FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.create(
                uid: user.uid,
                type: 'chat',
                title:
                    'dr. Sarah Amelia membalas pesanmu',
                body:
                    '"Baik, coba hindari makanan asam & pedas dulu..."',
              );

              if (!mounted) return;

              // Reload supaya langsung kelihatan
              setState(() {
                _isLoading = true;
              });

              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF8068D3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Buat Notifikasi Baru 🧪',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // TEST NOTIFIKASI ANDROID
        SizedBox(
          width: 210,
          height: 46,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await NotificationService.showPatientMessage(
                  messageId:
                      'test-${DateTime.now().millisecondsSinceEpoch}',
                  patientName: 'Test Pasien',
                  message: 'Tes notif dokter dari Samsung A04',
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Notifikasi Android berhasil dipanggil 🔔',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Gagal membuat notif: $e',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB9543A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'TEST NOTIF ANDROID 🔔',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
        
        // NOTIFIKASI LAMA (2 HARI)
        SizedBox(
          width: 210,
          height: 46,
          child: ElevatedButton(
            onPressed: () async {
              final user =
                  FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.create(
                uid: user.uid,
                type: 'skrining',
                title: 'Saatnya Skrining Mingguan',
                body:
                    'Pantau perkembangan lambungmu minggu ini',
                createdAt: DateTime.now().subtract(
                  const Duration(days: 2),
                ),
              );

              if (!mounted) return;

              setState(() {
                _isLoading = true;
              });

              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF4E8D6E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Buat Notifikasi Lama 🕐',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // HAPUS SEMUA (RESET)
        SizedBox(
          width: 210,
          height: 46,
          child: ElevatedButton(
            onPressed: () async {
              final user =
                  FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.clearAll(
                user.uid,
              );

              if (!mounted) return;

              setState(() {
                _unread = [];
                _read = [];
              });

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Semua notifikasi dihapus.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFB8B0AC),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Hapus Semua 🗑️',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}