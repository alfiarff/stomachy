import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/notification_service.dart';
import '../notification_screen.dart';

// ===============================================================
// HALAMAN NOTIFIKASI DOKTER
//
// Sengaja dibuat seragam dengan halaman notifikasi user:
// - Sumber data  : AppNotification (penyimpanan lokal per-uid)
// - Struktur     : "Belum Dibaca" (< 24 jam) + "Sebelumnya"
// - Badge beranda: dihitung dari sumber yang sama
//                  (getRecentUnreadCount)
//
// Dengan begitu angka badge di beranda dokter selalu konsisten
// dengan isi halaman ini.
// ===============================================================

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

    final items = await AppNotification.getAll(user.uid);

    // Belum dibaca DAN belum lewat 24 jam
    final List<LocalNotification> unread = items
        .where((item) => !item.isRead && AppNotification.isFresh(item))
        .toList();

    // Sudah dibaca ATAU sudah lewat 24 jam
    final List<LocalNotification> read = items
        .where((item) => item.isRead || !AppNotification.isFresh(item))
        .toList();

    if (!mounted) return;

    setState(() {
      _unread = unread;
      _read = read;
      _isLoading = false;
    });

    // Tandai semua sebagai dibaca
    // -> badge di beranda dokter otomatis hilang
    await AppNotification.markAllAsRead(user.uid);
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

            const SizedBox(height: 26),

            _buildTestButtons(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ⚠️ TOMBOL TES SEMENTARA — HAPUS SETELAH SELESAI TES!
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
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.create(
                uid: user.uid,
                type: 'chat',
                title: 'Pasien Rina mengirim pesan',
                body: '"Dok, perut saya sakit setelah makan..."',
              );

              if (!mounted) return;

              // Reload supaya langsung kelihatan
              setState(() {
                _isLoading = true;
              });

              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8068D3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
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
                  messageId: 'test-${DateTime.now().millisecondsSinceEpoch}',
                  patientName: 'Test Pasien',
                  message: 'Tes notif pasien dari HP dokter',
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Notifikasi Android berhasil dipanggil 🔔'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Gagal membuat notif: $e'),
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
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.create(
                uid: user.uid,
                type: 'chat',
                title: 'Pasien Budi mengirim pesan',
                body: 'Mau tanya soal pola makan, Dok',
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
              );

              if (!mounted) return;

              setState(() {
                _isLoading = true;
              });

              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E8D6E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
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
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await AppNotification.clearAll(user.uid);

              if (!mounted) return;

              setState(() {
                _unread = [];
                _read = [];
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Semua notifikasi dihapus.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8B0AC),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
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
