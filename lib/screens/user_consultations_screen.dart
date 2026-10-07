import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'consultation_chat_screen.dart';
import 'notification_screen.dart';

class UserConsultationsScreen extends StatefulWidget {
  final String searchQuery;

  const UserConsultationsScreen({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<UserConsultationsScreen> createState() =>
      _UserConsultationsScreenState();
}

class _UserConsultationsScreenState extends State<UserConsultationsScreen> {
  static const Color backgroundColor = Color(0xFFFFF5ED);
  static const Color primaryBrown = Color(0xFFB05039);

  Timer? _statusTimer;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncStatuses();
    });
    _statusTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _syncStatuses(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _consultationStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('consultations')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  bool _isDue(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();
    if (status == 'active') return true;
    if (status != 'booked') return false;

    final ts = data['consultationTimestamp'];
    return ts is Timestamp && !DateTime.now().isBefore(ts.toDate());
  }

  Future<void> _syncStatuses() async {
    if (_syncing) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _syncing = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('userId', isEqualTo: user.uid)
          .get();

      final due = <MapEntry<String, Map<String, dynamic>>>[];
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();

        if (status == 'booked' && _isDue(data)) {
          batch.set(
            doc.reference,
            {
              'status': 'active',
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
          due.add(MapEntry(doc.id, data));
        }
      }

      if (due.isNotEmpty) {
        await batch.commit();
        for (final item in due) {
          try {
            final doctorName =
                (item.value['doctorName'] ?? 'Dokter').toString();
            await AppNotification.create(
              uid: user.uid,
              type: 'consultation',
              title: 'Waktunya Konsultasi!',
              body:
                  'Konsultasi dengan $doctorName sudah dimulai. Kamu bisa mulai chat sekarang.',
            );
          } catch (_) {}
        }
      }
    } catch (_) {
    } finally {
      _syncing = false;
    }
  }

  Future<void> _openChat(
    Map<String, dynamic> data,
    String consultationId,
  ) async {
    var status = (data['status'] ?? '').toString().toLowerCase();

    if (status == 'booked') {
      if (_isDue(data)) {
        await _syncStatuses();
        status = 'active';
      } else {
        if (!mounted) return;
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
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }
    }

    // Konsultasi yang sudah selesai tetap bisa dibuka
    // untuk melihat riwayat chat.
    if (status != 'active' && status != 'completed') {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Konsultasi ini belum dapat dibuka.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    await FirebaseFirestore.instance
        .collection('consultations')
        .doc(consultationId)
        .set(
      {'unreadForUser': 0},
      SetOptions(merge: true),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationChatScreen(
          consultationId: consultationId,
          doctorName: (data['doctorName'] ?? 'Dokter').toString(),
          specialty: (data['specialty'] ?? '').toString(),
          doctorImage: (data['doctorImage'] ?? '').toString(),
          selectedTime: (data['consultationTime'] ?? '').toString(),
        ),
      ),
    );
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final doctorName = (data['doctorName'] ?? '').toString().toLowerCase();
    final specialty = (data['specialty'] ?? '').toString().toLowerCase();
    final day = (data['consultationDay'] ?? '').toString().toLowerCase();
    final time = (data['consultationTime'] ?? '').toString().toLowerCase();

    return doctorName.contains(query) ||
        specialty.contains(query) ||
        day.contains(query) ||
        time.contains(query);
  }

  String _statusText(String status, bool due) {
    if (status == 'completed') return 'Selesai';
    if (status == 'active' || due) return 'Mulai Chat';
    return 'Belum waktunya';
  }

  Color _statusColor(String status, bool due) {
    if (status == 'completed') return const Color(0xFF77716E);
    if (status == 'active' || due) return const Color(0xFF18A957);
    return const Color(0xFFB8860B);
  }

  Widget _buildDoctorAvatar(String image) {
    if (image.startsWith('http')) {
      return Container(
        width: 72,
        height: 72,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFE3D1),
        ),
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person_rounded,
            size: 40,
            color: primaryBrown,
          ),
        ),
      );
    }

    if (image.isNotEmpty) {
      try {
        return Container(
          width: 72,
          height: 72,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFE3D1),
          ),
          child: Image.memory(
            base64Decode(image),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_rounded,
              size: 40,
              color: primaryBrown,
            ),
          ),
        );
      } catch (_) {}
    }

    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFE3D1),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 40,
        color: primaryBrown,
      ),
    );
  }

  Widget _buildCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'booked').toString().toLowerCase();
    final due = _isDue(data);
    final canChat = status == 'active' || (status == 'booked' && due);

    final doctorName = (data['doctorName'] ?? 'Dokter').toString();
    final specialty = (data['specialty'] ?? 'Dokter Umum').toString();
    final day = (data['consultationDay'] ?? '-').toString();
    final time = (data['consultationTime'] ?? '-').toString();
    final statusText = _statusText(status, due);
    final statusColor = _statusColor(status, due);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openChat(data, doc.id),
      child: Container(
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildDoctorAvatar((data['doctorImage'] ?? '').toString()),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        status == 'completed'
                            ? Icons.done_all_rounded
                            : canChat
                                ? Icons.chat_bubble_rounded
                                : Icons.schedule_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$day, $time WIB',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 26,
              color: primaryBrown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFFE3D1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 30,
                  color: primaryBrown,
                ),
              ),
            ),
            SizedBox(height: 14),
            Text(
              'Belum ada booking',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Booking konsultasi akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _consultationStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryBrown,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Gagal memuat konsultasi.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          );
        }

        final docs = (snapshot.data?.docs ?? [])
            .where((doc) => _matchesSearch(doc.data()))
            .toList();

        docs.sort((a, b) {
          final at = a.data()['consultationTimestamp'];
          final bt = b.data()['consultationTimestamp'];
          if (at is Timestamp && bt is Timestamp) {
            return bt.compareTo(at);
          }
          return 0;
        });

        if (docs.isEmpty) return _buildEmpty();

        return ListView.separated(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _buildCard(docs[index]),
        );
      },
    );
  }
}
