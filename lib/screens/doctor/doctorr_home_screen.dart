import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/doctor_bottom_navigation.dart';
import 'doctor_chat_screen.dart';
import 'doctor_notification_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color brown = const Color(0xFFB05039);
  String _doctorName = 'Dokter';
  Timer? _activationTimer;

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
    _activationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _activateDueConsultations(),
    );
    _activateDueConsultations();
  }

  @override
  void dispose() {
    _activationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDoctorName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String name = user.displayName ?? '';
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final firestoreName = (doc.data()?['name'] ?? '').toString().trim();
      if (firestoreName.isNotEmpty) name = firestoreName;
      if (!mounted) return;
      setState(() => _doctorName = name.isNotEmpty ? name : 'Dokter');
    } catch (_) {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      setState(() => _doctorName = user?.displayName?.trim().isNotEmpty == true ? user!.displayName!.trim() : 'Dokter');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _consultationStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance.collection('consultations').where('doctorId', isEqualTo: user.uid).snapshots();
  }

  DateTime? _consultationDate(Map<String, dynamic> data) {
    final value = data['consultationTimestamp'];
    if (value is Timestamp) return value.toDate();
    final fallback = data['consultationDate'];
    if (fallback is Timestamp) return fallback.toDate();
    return null;
  }

  Future<void> _activateDueConsultations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('doctorId', isEqualTo: user.uid)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      bool changed = false;
      final now = DateTime.now();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final date = _consultationDate(data);
        if (status == 'booked' && date != null && !date.isAfter(now)) {
          batch.set(doc.reference, {
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          changed = true;
        }
      }
      if (changed) await batch.commit();
    } catch (_) {}
  }

  int _getUnreadCount(List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations) {
    int total = 0;
    for (final doc in consultations) {
      final value = doc.data()['unreadForDoctor'];
      final unread = value is int ? value : value is num ? value.toInt() : int.tryParse(value?.toString() ?? '0') ?? 0;
      if (unread > 0) total += unread;
    }
    return total;
  }

  int _getPatientTodayCount(List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final patients = <String>{};
    for (final doc in consultations) {
      final data = doc.data();
      final userId = (data['userId'] ?? '').toString();
      final date = _consultationDate(data);
      if (userId.isEmpty || date == null) continue;
      if (!date.isBefore(start) && date.isBefore(end)) patients.add(userId);
    }
    return patients.length;
  }

  int _getPatientCount(List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations) {
    final patients = <String>{};
    for (final doc in consultations) {
      final userId = (doc.data()['userId'] ?? '').toString().trim();
      if (userId.isNotEmpty) patients.add(userId);
    }
    return patients.length;
  }

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorPatientsScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorChatScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorProfileScreen()));
    }
  }

  void _openNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorNotificationScreen()));
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorProfileScreen()));
  }

  void _openPatientChat(Map<String, dynamic> patient) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorPatientChatScreen(patient: patient)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _consultationStream(),
          builder: (context, snapshot) {
            final consultations = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            final unreadCount = _getUnreadCount(consultations);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(unreadCount),
                  const SizedBox(height: 18),
                  _buildGreeting(unreadCount),
                  const SizedBox(height: 18),
                  _buildStatistics(consultations, unreadCount),
                  const SizedBox(height: 25),
                  _buildRecentMessages(consultations),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(selectedIndex: _selectedIndex, onItemSelected: _onNavigationTap),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return SizedBox(
      height: 75,
      child: Row(
        children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: Image.asset('assets/images/logo_beranda_baru.png', height: 72, fit: BoxFit.contain))),
          GestureDetector(
            onTap: _openNotifications,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(width: 42, height: 42, child: Icon(Icons.notifications_none_rounded, size: 27, color: Color(0xFFB05039))),
                if (unreadCount > 0)
                  Positioned(
                    right: -3,
                    top: -4,
                    child: Container(
                      width: 19,
                      height: 19,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFAA4E39), shape: BoxShape.circle),
                      child: Text(unreadCount > 9 ? '9+' : unreadCount.toString(), style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openProfile,
            child: const SizedBox(width: 42, height: 42, child: Icon(Icons.account_circle_rounded, size: 39, color: Color(0xFFB05039))),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34, 25, 25, 25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE3),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 7, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Halo,', style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black, height: 1.2)),
          const SizedBox(height: 2),
          Text('dr. $_doctorName 👋', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black, height: 1.2)),
          const SizedBox(height: 9),
          Text(unreadCount > 0 ? 'Anda punya $unreadCount pesan belum dibaca.' : 'Tidak ada pesan baru.', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations, int unreadCount) {
    return Row(
      children: [
        Expanded(child: _buildStatisticCard(icon: Icons.groups_rounded, value: _getPatientTodayCount(consultations).toString(), label: 'Pasien Hari Ini')),
        const SizedBox(width: 10),
        Expanded(child: _buildStatisticCard(icon: Icons.chat_bubble_rounded, value: unreadCount.toString(), label: 'Belum Dibaca')),
        const SizedBox(width: 10),
        Expanded(child: _buildStatisticCard(icon: Icons.calendar_month_rounded, value: _getPatientCount(consultations).toString(), label: 'Total Pasien')),
      ],
    );
  }

  Widget _buildStatisticCard({required IconData icon, required String value, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 7, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(color: Color(0xFFFFE1C8), shape: BoxShape.circle),
            child: Icon(icon, size: 27, color: brown),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 25, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildRecentMessages(List<QueryDocumentSnapshot<Map<String, dynamic>>> consultations) {
    final latestByUser = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final document in consultations) {
      final data = document.data();
      final lastMessage = (data['lastMessage'] ?? '').toString().trim();
      if (lastMessage.isEmpty) continue;

      final userId = (data['userId'] ?? '').toString().trim();
      if (userId.isEmpty) continue;

      final existing = latestByUser[userId];
      if (existing == null) {
        latestByUser[userId] = document;
        continue;
      }

      final oldTime = existing.data()['updatedAt'] is Timestamp ? existing.data()['updatedAt'] as Timestamp : null;
      final newTime = data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : null;
      if (newTime != null && (oldTime == null || newTime.compareTo(oldTime) > 0)) latestByUser[userId] = document;
    }

    final recentChats = latestByUser.values.toList();
    recentChats.sort((a, b) {
      final aTime = a.data()['updatedAt'] is Timestamp ? a.data()['updatedAt'] as Timestamp : null;
      final bTime = b.data()['updatedAt'] is Timestamp ? b.data()['updatedAt'] as Timestamp : null;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    final limitedChats = recentChats.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 7, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('Pesan Terbaru', style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black))),
              GestureDetector(
                onTap: _openNotifications,
                child: const Row(
                  children: [
                    Text('Lihat Semua', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFAA4E39))),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 19, color: Color(0xFFAA4E39)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (limitedChats.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Belum ada pesan terbaru.', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: Colors.black)),
            )
          else
            ...limitedChats.map(_buildMessageItem),
        ],
      ),
    );
  }

  Widget _buildMessageItem(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final patientName = (data['userName'] ?? data['name'] ?? 'Pasien').toString();
    final message = (data['lastMessage'] ?? '').toString().trim();
    final status = (data['status'] ?? '').toString().toLowerCase();
    final value = data['unreadForDoctor'];
    final unreadCount = value is int ? value : value is num ? value.toInt() : int.tryParse(value?.toString() ?? '0') ?? 0;
    final patient = {...data, 'consultationId': document.id, 'userName': patientName};

    return GestureDetector(
      onTap: () => _openPatientChat(patient),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEFE7E3), width: 1))),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Color(0xFFFFE5D8), shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 31, color: Color(0xFFAA4E39)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (unreadCount > 0)
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFFD9E1), shape: BoxShape.circle))
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active' ? const Color(0xFFFFE5D8) : status == 'completed' ? const Color(0xFFECECEC) : const Color(0xFFFFEEE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == 'active' ? 'Aktif' : status == 'booked' ? 'Terjadwal' : 'Selesai',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
