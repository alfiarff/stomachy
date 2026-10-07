import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'home_screen.dart';

import 'screening_screen.dart';

import 'doctor_screen.dart';

import 'edukasi_screen.dart';

import 'profile_screen.dart';

import '../widgets/bottom_navigation.dart';

class ConsultationHistoryScreen extends StatefulWidget {

  const ConsultationHistoryScreen({super.key});

  @override

  State<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();

}

class _ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {

  static const Color backgroundColor = Color(0xFFFFF5EF);

  static const Color brown = Color(0xFFB05039);

  void _onNavigationTap(int index) {

    if (index == 4) return;

    final Widget page;

    if (index == 0) {

      page = const HomeScreen();

    } else if (index == 1) {

      page = const ScreeningScreen();

    } else if (index == 2) {

      page = const DoctorScreen();

    } else {

      page = const EdukasiScreen();

    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));

  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _historyStream() {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance.collection('consultations').where('userId', isEqualTo: user.uid).snapshots();

  }

  DateTime? _date(dynamic value) {

    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    return null;

  }

  String _formatDate(dynamic value) {

    final d = _date(value);

    if (d == null) return '-';

    final day = d.day.toString().padLeft(2, '0');

    final month = d.month.toString().padLeft(2, '0');

    final year = d.year.toString();

    final hour = d.hour.toString().padLeft(2, '0');

    final minute = d.minute.toString().padLeft(2, '0');

    return '$year-$month-$day • $hour.$minute WIB';

  }

  String _consultationDate(Map<String, dynamic> data) {

    final timestamp = data['consultationTimestamp'];

    if (timestamp is Timestamp) return _formatDate(timestamp);

    final day = (data['consultationDay'] ?? '').toString();

    final time = (data['consultationTime'] ?? '').toString();

    if (day.isNotEmpty && time.isNotEmpty) return '$day • $time WIB';

    if (time.isNotEmpty) return time;

    return _formatDate(data['createdAt']);

  }

  String _doctorName(Map<String, dynamic> data) {

    final name = (data['doctorName'] ?? data['name'] ?? 'Dokter').toString().trim();

    return name.startsWith('dr.') ? name : 'dr. $name';

  }

  String _specialty(Map<String, dynamic> data) {

    return (data['specialty'] ?? data['specialization'] ?? 'Dokter Umum').toString();

  }

  String _doctorImage(Map<String, dynamic> data) {

    return (data['doctorImage'] ?? data['doctorPhotoBase64'] ?? data['photoBase64'] ?? data['doctorPhotoUrl'] ?? data['photoUrl'] ?? data['image'] ?? '').toString();

  }

  Widget _fallbackAvatar({double size = 50}) {

    return Container(

      width: size,

      height: size,

      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF0E7E1)),

      child: Icon(Icons.person_rounded, size: size * .56, color: brown),

    );

  }

  Widget _avatar(Map<String, dynamic> data) {

    final raw = _doctorImage(data);

    if (raw.startsWith('http')) {

      return Container(

        width: 50,

        height: 50,

        clipBehavior: Clip.antiAlias,

        decoration: const BoxDecoration(shape: BoxShape.circle),

        child: Image.network(raw, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackAvatar()),

      );

    }

    if (raw.isNotEmpty) {

      try {

        return Container(

          width: 50,

          height: 50,

          clipBehavior: Clip.antiAlias,

          decoration: const BoxDecoration(shape: BoxShape.circle),

          child: Image.memory(base64Decode(raw), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackAvatar()),

        );

      } catch (_) {}

    }

    return _fallbackAvatar();

  }

  void _openHistoryChat(String id, Map<String, dynamic> data) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => ConsultationHistoryChatScreen(

          consultationId: id,

          doctorName: _doctorName(data),

          specialty: _specialty(data),

          doctorImage: _doctorImage(data),

          consultationDate: _consultationDate(data),

        ),

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,

      body: SafeArea(

        child: Column(

          children: [

            _buildHeader(),

            Expanded(

              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                stream: _historyStream(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return const Center(child: CircularProgressIndicator(color: brown, strokeWidth: 2));

                  }

                  if (snapshot.hasError) {

                    return _message('Riwayat chat gagal dimuat.', 'Periksa koneksi internet lalu coba lagi.');

                  }

                  final docs = (snapshot.data?.docs ?? []).where((doc) {

                    final status = (doc.data()['status'] ?? '').toString().toLowerCase();

                    return status == 'completed' || status == 'selesai' || status == 'done';

                  }).toList();

                  docs.sort((a, b) {

                    final ad = _date(a.data()['consultationTimestamp']) ?? _date(a.data()['updatedAt']) ?? _date(a.data()['createdAt']);

                    final bd = _date(b.data()['consultationTimestamp']) ?? _date(b.data()['updatedAt']) ?? _date(b.data()['createdAt']);

                    if (ad == null || bd == null) return 0;

                    return bd.compareTo(ad);

                  });

                  if (docs.isEmpty) {

                    return _message('Belum ada riwayat chat', 'Konsultasi yang sudah selesai akan muncul di sini.');

                  }

                  return ListView.separated(

                    physics: const ClampingScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),

                    itemCount: docs.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 14),

                    itemBuilder: (context, index) {

                      final doc = docs[index];

                      return _historyCard(doc.id, doc.data());

                    },

                  );

                },

              ),

            ),

          ],

        ),

      ),

      bottomNavigationBar: AppBottomNavigation(selectedIndex: 4, onItemSelected: _onNavigationTap),

    );

  }

  Widget _buildHeader() {

    return SizedBox(

      height: 58,

      child: Row(

        children: [

          GestureDetector(

            onTap: () => Navigator.pop(context),

            child: const SizedBox(

              width: 55,

              height: 58,

              child: Align(

                alignment: Alignment.center,

                child: Icon(Icons.arrow_back_rounded, size: 31, color: Colors.black),

              ),

            ),

          ),

          const Expanded(

            child: Center(

              child: Text(

                'Riwayat Chat',

                style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),

              ),

            ),

          ),

          const SizedBox(width: 55),

        ],

      ),

    );

  }

    Widget _historyCard(String id, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _openHistoryChat(id, data),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _avatar(data),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _doctorName(data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _specialty(data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_consultationDate(data)} • Selesai',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right_rounded,
              size: 23,
              color: brown,
            ),
          ],
        ),
      ),
    );
  }

Widget _message(String title, String subtitle) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(30),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const Icon(Icons.history_rounded, size: 50, color: brown),

            const SizedBox(height: 12),

            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),

            const SizedBox(height: 6),

            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: Colors.black)),

          ],

        ),

      ),

    );

  }

}

class ConsultationHistoryChatScreen extends StatefulWidget {

  final String consultationId;

  final String doctorName;

  final String specialty;

  final String doctorImage;

  final String consultationDate;

  const ConsultationHistoryChatScreen({

    super.key,

    required this.consultationId,

    required this.doctorName,

    required this.specialty,

    required this.doctorImage,

    required this.consultationDate,

  });

  @override

  State<ConsultationHistoryChatScreen> createState() => _ConsultationHistoryChatScreenState();

}

class _ConsultationHistoryChatScreenState extends State<ConsultationHistoryChatScreen> {

  static const Color backgroundColor = Color(0xFFFFF5EF);

  static const Color brown = Color(0xFFB05039);

  static const Color softOrange = Color(0xFFFFE3D1);

  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot<Map<String, dynamic>>> _messageStream() {

    return FirebaseFirestore.instance.collection('consultations').doc(widget.consultationId).collection('messages').orderBy('createdAt').snapshots();

  }

  Widget _avatar() {

    final raw = widget.doctorImage;

    if (raw.startsWith('http')) {

      return Container(width: 48, height: 48, clipBehavior: Clip.antiAlias, decoration: const BoxDecoration(shape: BoxShape.circle), child: Image.network(raw, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()));

    }

    if (raw.isNotEmpty) {

      try {

        return Container(width: 48, height: 48, clipBehavior: Clip.antiAlias, decoration: const BoxDecoration(shape: BoxShape.circle), child: Image.memory(base64Decode(raw), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()));

      } catch (_) {}

    }

    return _fallback();

  }

  Widget _fallback() {

    return Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF0E7E1)), child: const Icon(Icons.person_rounded, size: 30, color: brown));

  }

  String _time(dynamic value) {

    if (value is! Timestamp) return '';

    final d = value.toDate();

    return '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

  }

  @override

  void dispose() {

    _scrollController.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,

      body: SafeArea(

        child: Column(

          children: [

            _header(),

            _doctorInfo(),

            const SizedBox(height: 10),

            _buildPrivacyWarning(),

            const SizedBox(height: 10),

            Expanded(

              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                stream: _messageStream(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return const Center(child: CircularProgressIndicator(color: brown, strokeWidth: 2));

                  }

                  if (snapshot.hasError) {

                    return const Center(child: Text('Riwayat chat gagal dimuat.', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: Colors.black)));

                  }

                  final messages = snapshot.data?.docs ?? [];

                  if (messages.isEmpty) {

                    return const Center(child: Text('Belum ada pesan dalam konsultasi ini.', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: Colors.black)));

                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {

                    if (_scrollController.hasClients) {

                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

                    }

                  });

                  return ListView.builder(

                    controller: _scrollController,

                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),

                    itemCount: messages.length,

                    itemBuilder: (_, index) => _bubble(messages[index].data()),

                  );

                },

              ),

            ),

            _readOnlyNote(),

          ],

        ),

      ),

    );

  }

  Widget _header() {

    return SizedBox(

      height: 58,

      child: Row(

        children: [

          GestureDetector(

            onTap: () => Navigator.pop(context),

            child: const SizedBox(width: 55, height: 58, child: Align(alignment: Alignment.center, child: Icon(Icons.arrow_back_rounded, size: 31, color: Colors.black))),

          ),

          const Expanded(child: Center(child: Text('Riwayat Chat', style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black)))),

          const SizedBox(width: 55),

        ],

      ),

    );

  }

  Widget _doctorInfo() {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 27),

      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

      ),

      child: Row(

        children: [

          _avatarLarge(),

          const SizedBox(width: 14),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  widget.doctorName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 12,

                    fontWeight: FontWeight.w800,

                    color: Colors.black,

                  ),

                ),

                const SizedBox(height: 2),

                Text(

                  widget.specialty,

                  style: const TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 12,

                    color: Colors.black,

                  ),

                ),

                const SizedBox(height: 3),

                Text(

                  widget.consultationDate,

                  style: const TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 10,

                    color: Color(0xFF77716E),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget _avatarLarge() {

    final raw = widget.doctorImage;

    if (raw.startsWith('http')) {

      return Container(

        width: 62,

        height: 62,

        clipBehavior: Clip.antiAlias,

        decoration: const BoxDecoration(shape: BoxShape.circle),

        child: Image.network(

          raw,

          fit: BoxFit.cover,

          errorBuilder: (_, __, ___) => _fallbackLargeAvatar(),

        ),

      );

    }

    if (raw.isNotEmpty) {

      try {

        return Container(

          width: 62,

          height: 62,

          clipBehavior: Clip.antiAlias,

          decoration: const BoxDecoration(shape: BoxShape.circle),

          child: Image.memory(

            base64Decode(raw),

            fit: BoxFit.cover,

            errorBuilder: (_, __, ___) => _fallbackLargeAvatar(),

          ),

        );

      } catch (_) {}

    }

    return _fallbackLargeAvatar();

  }

  Widget _fallbackLargeAvatar() {

    return Container(

      width: 62,

      height: 62,

      decoration: const BoxDecoration(

        shape: BoxShape.circle,

        color: softOrange,

      ),

      child: const Icon(

        Icons.person_rounded,

        size: 42,

        color: brown,

      ),

    );

  }

  Widget _buildPrivacyWarning() {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 28),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(

        color: softOrange,

        borderRadius: BorderRadius.circular(10),

      ),

      child: const Row(

        children: [

          Icon(

            Icons.lock_outline_rounded,

            size: 17,

            color: brown,

          ),

          SizedBox(width: 10),

          Expanded(

            child: Text(

              'Jangan bagikan informasi pribadi atau kode OTP kepada siapapun.',

              style: TextStyle(

                fontFamily: 'Nunito',

                fontSize: 9.5,

                height: 1.3,

                color: Colors.black,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _bubble(Map<String, dynamic> data) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final senderId = (data['senderId'] ?? data['uid'] ?? '').toString();
    final role = (data['senderRole'] ?? '').toString().toLowerCase();

    // Di role USER:
    // - pesan pasien/user = kanan + brown
    // - pesan dokter = kiri + putih
    final bool patientMessage =
        role == 'patient' ||
        role == 'user' ||
        role == 'pasien' ||
        (senderId.isNotEmpty && senderId == currentUid);

    final text =
        (data['text'] ?? data['message'] ?? data['content'] ?? '')
            .toString();
    final time = _time(data['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: patientMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pesan dokter berada di kiri dan memakai avatar dokter.
          if (!patientMessage) ...[
            _buildSmallDoctorImage(),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 310),
              padding: const EdgeInsets.fromLTRB(13, 9, 10, 6),
              decoration: BoxDecoration(
                color: patientMessage
                    ? const Color(0xFFFFE7D8)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    patientMessage ? 18 : 4,
                  ),
                  bottomRight: Radius.circular(
                    patientMessage ? 4 : 18,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF211914),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 8,
                          color: Color(0xFF77716E),
                        ),
                      ),
                      if (patientMessage) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 12,
                          color: brown,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDoctorImage() {
    final raw = widget.doctorImage;

    if (raw.startsWith('http')) {
      return Container(
        width: 36,
        height: 36,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.network(
          raw,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackSmallDoctorImage(),
        ),
      );
    }

    if (raw.isNotEmpty) {
      try {
        return Container(
          width: 36,
          height: 36,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.memory(
            base64Decode(raw),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackSmallDoctorImage(),
          ),
        );
      } catch (_) {}
    }

    return _fallbackSmallDoctorImage();
  }

  Widget _fallbackSmallDoctorImage() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFE3D1),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 25,
        color: brown,
      ),
    );
  }

  Widget _readOnlyNote() {

    return Container(

      margin: const EdgeInsets.fromLTRB(9, 0, 9, 8),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(13),

      ),

      child: const Row(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(

            Icons.lock_outline_rounded,

            size: 16,

            color: brown,

          ),

          SizedBox(width: 7),

          Flexible(

            child: Text(

              'Konsultasi sudah selesai. Chat hanya dapat dilihat.',

              textAlign: TextAlign.center,

              style: TextStyle(

                fontFamily: 'Nunito',

                fontSize: 9.5,

                fontWeight: FontWeight.w700,

                color: Colors.black,

              ),

            ),

          ),

        ],

      ),

    );

  }
}
