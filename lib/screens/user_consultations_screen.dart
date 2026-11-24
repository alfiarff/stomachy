import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'consultation_chat_screen.dart';
import 'notification_screen.dart';

class UserConsultationsScreen extends StatefulWidget {
  final String searchQuery;

  const UserConsultationsScreen({super.key, this.searchQuery = ''});

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

    if (status != 'booked' && status != 'active') {
      return false;
    }

    final startValue = data['consultationTimestamp'];
    if (startValue is! Timestamp) return false;

    final DateTime now = DateTime.now();
    final DateTime startTime = startValue.toDate();

    DateTime? endTime;
    final endValue = data['consultationEndTimestamp'];

    if (endValue is Timestamp) {
      endTime = endValue.toDate();
    } else {
      final duration =
          (data['durationMinutes'] as num?)?.toInt() ?? 60;

      endTime = startTime.add(Duration(minutes: duration));
    }

    if (now.isBefore(startTime)) return false;
    if (!now.isBefore(endTime)) return false;

    return true;
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

      for (final doc in snapshot.docs) {
        final consultationRef = doc.reference;

        final transition =
            await FirebaseFirestore.instance.runTransaction<String?>(
          (transaction) async {
            final freshSnapshot =
                await transaction.get(consultationRef);

            if (!freshSnapshot.exists) return null;

            final data = freshSnapshot.data() ?? {};

            final status =
                (data['status'] ?? '').toString().toLowerCase();

            final startValue = data['consultationTimestamp'];

            if (startValue is! Timestamp) return null;

            final DateTime now = DateTime.now();
            final DateTime startTime = startValue.toDate();

            DateTime? endTime;
            final endValue = data['consultationEndTimestamp'];

            if (endValue is Timestamp) {
              endTime = endValue.toDate();
            } else {
              final duration =
                  (data['durationMinutes'] as num?)?.toInt() ?? 60;

              endTime = startTime.add(
                Duration(minutes: duration),
              );
            }

            // Konsultasi belum dimulai.
            if (now.isBefore(startTime)) return null;

            // Konsultasi sudah melewati waktu selesai.
            if (!now.isBefore(endTime)) {
              if (status == 'booked' || status == 'active') {
                transaction.update(consultationRef, {
                  'status': 'completed',
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                return status == 'booked'
                    ? 'started_and_completed'
                    : 'completed';
              }

              return null;
            }

            // Konsultasi dimulai.
            if (status == 'booked') {
              transaction.update(consultationRef, {
                'status': 'active',
                'updatedAt': FieldValue.serverTimestamp(),
              });

              return 'started';
            }

            return null;
          },
        );

        if (transition == null) continue;

        final data = doc.data();

        final doctorName =
            (data['doctorName'] ?? 'Dokter').toString();

        // Notifikasi ketika konsultasi dimulai.
        if (transition == 'started' ||
            transition == 'started_and_completed') {
          try {
            await AppNotification.create(
              uid: user.uid,
              type: 'consultation',
              title: 'Waktunya Konsultasi!',
              body:
                  'Konsultasi dengan $doctorName sudah dimulai. Kamu bisa mulai chat sekarang.',
            );
          } catch (e) {
            debugPrint('Notifikasi mulai gagal: $e');
          }
        }

        // Notifikasi ketika konsultasi selesai.
        if (transition == 'completed' ||
            transition == 'started_and_completed') {
          try {
            await AppNotification.create(
              uid: user.uid,
              type: 'consultation',
              title: 'Konsultasi Selesai',
              body:
                  'Konsultasi dengan $doctorName telah berakhir. Kamu masih bisa melihat riwayat chat.',
            );
          } catch (e) {
            debugPrint('Notifikasi selesai gagal: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal memperbarui status konsultasi: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _openChat(String consultationId) async {
    // Periksa status terbaru sebelum membuka chat.
    await _syncStatuses();

    if (!mounted) return;

    final consultationRef = FirebaseFirestore.instance
        .collection('consultations')
        .doc(consultationId);

    final latestSnapshot = await consultationRef.get();

    if (!latestSnapshot.exists) {
      _showConsultationMessage(
        'Data konsultasi tidak ditemukan.',
      );
      return;
    }

    final latestData = latestSnapshot.data() ?? {};

    final status =
        (latestData['status'] ?? '').toString().toLowerCase();

    if (status == 'booked') {
      _showConsultationMessage(
        'Belum waktunya konsultasi.',
      );
      return;
    }

    if (status != 'active' && status != 'completed') {
      _showConsultationMessage(
        'Konsultasi ini belum dapat dibuka.',
      );
      return;
    }

    await consultationRef.set(
      {'unreadForUser': 0},
      SetOptions(merge: true),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationChatScreen(
          consultationId: consultationId,
          doctorName:
              (latestData['doctorName'] ?? 'Dokter').toString(),
          specialty:
              (latestData['specialty'] ?? '').toString(),
          doctorImage:
              (latestData['doctorImage'] ?? '').toString(),
          selectedTime:
              (latestData['consultationTime'] ?? '').toString(),
        ),
      ),
    );
  }

  void _showConsultationMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior: SnackBarBehavior.floating,
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
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person_rounded, size: 40, color: primaryBrown),
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
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.person_rounded, size: 40, color: primaryBrown),
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
      child: const Icon(Icons.person_rounded, size: 40, color: primaryBrown),
    );
  }

 
  Widget _buildCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'booked').toString().toLowerCase();
    final due = _isDue(data);
    final canChat = status == 'active' && due;

    final doctorName = (data['doctorName'] ?? 'Dokter').toString();
    final message = (data['lastMessage'] ?? '').toString().trim();
    final specialty = (data['specialty'] ?? 'Dokter Umum').toString();
    final day = (data['consultationDay'] ?? '').toString().trim();
    final time = (data['consultationTime'] ?? '').toString().trim();

    final statusText = status == 'completed'
        ? 'Selesai'
        : canChat
            ? 'Aktif'
            : 'Belum waktunya';

    final statusColor = status == 'completed'
        ? const Color(0xFF77716E)
        : canChat
            ? const Color(0xFF188447)
            : const Color(0xFFB8860B);

    final dateText = [
      if (day.isNotEmpty && day != '-') day,
      if (time.isNotEmpty && time != '-') time,
    ].join(', ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openChat(doc.id),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
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
            _buildDoctorAvatar(
              (data['doctorImage'] ?? '').toString(),
            ),
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
                  const SizedBox(height: 4),
                  Text(
                    message.isNotEmpty ? message : specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        status == 'completed'
                            ? Icons.done_all_rounded
                            : canChat
                                ? Icons.chat_bubble_rounded
                                : Icons.schedule_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      if (dateText.isNotEmpty) ...[
                        const SizedBox(width: 7),
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            dateText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
