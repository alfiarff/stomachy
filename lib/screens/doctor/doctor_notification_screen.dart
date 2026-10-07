import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../notification_screen.dart';

class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({super.key});

  @override
  State<DoctorNotificationScreen> createState() =>
      _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color brown = Color(0xFFB05039);

  bool _isLoading = true;
  List<LocalNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final local = await AppNotification.getAll(user.uid);

      final snapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('doctorId', isEqualTo: user.uid)
          .get();

      final generated = <LocalNotification>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final patient = (data['userName'] ?? 'Pasien').toString();
        final day = (data['consultationDay'] ?? '').toString();
        final time = (data['consultationTime'] ?? '').toString();

        if (status != 'booked' && status != 'active') continue;

        final ts = data['consultationTimestamp'];
        DateTime createdAt = DateTime.now();
        if (ts is Timestamp) createdAt = ts.toDate();

        generated.add(
          LocalNotification(
            id: 'consultation_${doc.id}_$status',
            type: status == 'active' ? 'reminder' : 'consultation',
            title: status == 'active'
                ? 'Waktunya Konsultasi!'
                : 'Booking Konsultasi',
            body: status == 'active'
                ? 'Konsultasi dengan $patient pada $day, $time WIB sudah dimulai.'
                : 'Pasien $patient memiliki booking pada $day, $time WIB.',
            createdAt: createdAt,
            isRead: false,
          ),
        );
      }

      final Map<String, LocalNotification> merged = {};
      for (final item in local) {
        merged[item.id] = item;
      }
      for (final item in generated) {
        if (!merged.containsKey(item.id)) merged[item.id] = item;
      }

      final items = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;

      setState(() {
        _notifications = items;
        _isLoading = false;
      });

      await AppNotification.markAllAsRead(user.uid);
    } catch (_) {
      final items = await AppNotification.getAll(user.uid);
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
      await AppNotification.markAllAsRead(user.uid);
    }
  }

  String _formatLabel(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays == 1) return 'Kemarin';

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

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'chat':
      case 'patient_message':
        return Icons.chat_bubble_outline_rounded;
      case 'consultation':
      case 'booking':
        return Icons.calendar_month_outlined;
      case 'reminder':
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: brown,
                  strokeWidth: 2,
                ),
              )
            : RefreshIndicator(
                color: brown,
                onRefresh: _loadNotifications,
                child: _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
              ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
      children: [
        _buildHeader(),
        const SizedBox(height: 22),
        for (int i = 0; i < _notifications.length; i++) ...[
          _buildNotificationCard(_notifications[i]),
          if (i != _notifications.length - 1) const SizedBox(height: 11),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
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
                  fontWeight: FontWeight.w800,
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

  Widget _buildNotificationCard(LocalNotification item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE3D1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(item.type),
              size: 21,
              color: brown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.3,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatLabel(item.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
      children: [
        _buildHeader(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.58,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 110,
                  height: 110,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 52,
                      color: brown,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Belum Ada Notifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Pengingat konsultasi dan pesan baru dari pasien akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
