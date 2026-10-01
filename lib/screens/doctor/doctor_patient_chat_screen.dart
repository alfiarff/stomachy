import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorPatientChatScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const DoctorPatientChatScreen({
    super.key,
    required this.patient,
  });

  @override
  State<DoctorPatientChatScreen> createState() =>
      _DoctorPatientChatScreenState();
}

class _DoctorPatientChatScreenState
    extends State<DoctorPatientChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _isSending = false;

  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  final Color primaryBrown =
      const Color(0xFFB65339);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ===============================================================
  // DATA PASIEN
  // ===============================================================

  String get _patientName {
    final String name =
        (widget.patient['userName'] ??
                widget.patient['name'] ??
                'Pasien')
            .toString()
            .trim();

    return name.isEmpty ? 'Pasien' : name;
  }

  String get _consultationId {
    return (widget.patient['consultationId'] ?? '')
        .toString();
  }

  String get _consultationDay {
    return (widget.patient['consultationDay'] ?? '')
        .toString();
  }

  String get _consultationTime {
    return (widget.patient['consultationTime'] ?? '')
        .toString();
  }

  // ===============================================================
  // STREAM PESAN
  // ===============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _messageStream() {
    if (_consultationId.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('consultations')
        .doc(_consultationId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            _buildPatientCard(),

            const SizedBox(height: 16),

            _buildPrivacyWarning(),

            const SizedBox(height: 12),

            _buildTodayLabel(),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream: _messageStream(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (_consultationId.isEmpty) {
                    return _buildError(
                      'ID konsultasi tidak ditemukan.',
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: Color(0xFFB65339),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(
                      'Chat gagal dimuat.',
                    );
                  }

                  final List<
                          QueryDocumentSnapshot<
                              Map<String, dynamic>>>
                      messages =
                      snapshot.data?.docs ?? [];

                  WidgetsBinding.instance
                      .addPostFrameCallback(
                    (_) {
                      _scrollToBottom();
                    },
                  );

                  if (messages.isEmpty) {
                    return _buildEmptyChat();
                  }

                  return ListView.builder(
                    controller:
                        _scrollController,
                    padding:
                        const EdgeInsets.fromLTRB(
                      10,
                      0,
                      10,
                      8,
                    ),
                    physics:
                        const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder:
                        (context, index) {
                      final Map<String, dynamic>
                          message =
                          messages[index].data();

                      return _buildChatBubble(
                        message,
                      );
                    },
                  );
                },
              ),
            ),

            _buildMessageInput(),

            _buildMedicalNote(),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 55,
              height: 55,
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Chat dengan Pasien',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 75,
            child: TextButton(
              onPressed:
                  _showFinishConfirmation,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
              ),
              child: const Text(
                'Akhiri',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB65339),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PATIENT CARD
  // TANPA RATING DAN ULASAN
  // ===============================================================

  Widget _buildPatientCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 27,
      ),
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE3D1),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 42,
              color: Color(0xFFB65339),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _patientName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color: Color(0xFF211914),
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Pasien',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Online',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF18C85A),
                  ),
                ),

                if (_consultationTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _consultationDay.isNotEmpty
                        ? 'Jadwal: $_consultationDay, $_consultationTime'
                        : 'Jadwal: $_consultationTime',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      color: Color(0xFF77716E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PRIVACY WARNING
  // ===============================================================

  Widget _buildPrivacyWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8DC),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 17,
            color: Color(0xFFB65339),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Jangan bagikan informasi pribadi atau kode OTP kepada siapapun.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9.5,
                height: 1.3,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HARI INI
  // ===============================================================

  Widget _buildTodayLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8DC),
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Hari Ini',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF493028),
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY CHAT
  // ===============================================================

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  const BoxDecoration(
                color: Color(0xFFFFE3D1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 35,
                color: Color(0xFFB65339),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Mulai Percakapan',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
                color: Color(0xFF30221E),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Kirim pesan untuk memulai\n'
              'konsultasi dengan pasien.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF77716E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // CHAT BUBBLE
  // PASIEN KIRI
  // DOKTER KANAN
  // TANPA BORDER
  // ===============================================================

  Widget _buildChatBubble(
    Map<String, dynamic> message,
  ) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    final String senderId =
        (message['senderId'] ?? '')
            .toString();

    final String senderRole =
        (message['senderRole'] ?? '')
            .toString()
            .toLowerCase();

    final bool isMine =
        currentUser != null &&
            senderId == currentUser.uid;

    final bool isDoctorMessage =
        senderRole == 'doctor' || isMine;

    final String text =
        (message['message'] ?? '')
            .toString();

    final String time =
        _formatTime(
      message['createdAt'],
    );

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isDoctorMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          if (!isDoctorMessage) ...[
            _buildSmallPatientImage(),

            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 310,
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                13,
                9,
                10,
                6,
              ),
              decoration: BoxDecoration(
                color: isDoctorMessage
                    ? const Color(0xFFFFE7D8)
                    : const Color(0xFFFFFCFA),
                borderRadius:
                    BorderRadius.only(
                  topLeft:
                      const Radius.circular(18),
                  topRight:
                      const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(
                    isDoctorMessage
                        ? 18
                        : 4,
                  ),
                  bottomRight:
                      Radius.circular(
                    isDoctorMessage
                        ? 4
                        : 18,
                  ),
                ),
                boxShadow:
                    isDoctorMessage
                        ? const [
                            BoxShadow(
                              color:
                                  Color(0x28000000),
                              blurRadius: 4,
                              offset:
                                  Offset(0, 3),
                            ),
                          ]
                        : [],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      text,
                      style:
                          const TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize: 12,
                        height: 1.35,
                        color:
                            Color(0xFF211914),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 8,
                          color:
                              Colors.grey[600],
                        ),
                      ),

                      if (isDoctorMessage) ...[
                        const SizedBox(width: 3),

                        const Icon(
                          Icons.done_all_rounded,
                          size: 12,
                          color:
                              Color(0xFFB65339),
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

  // ===============================================================
  // FOTO PASIEN KECIL
  // ===============================================================

  Widget _buildSmallPatientImage() {
    return Container(
      width: 36,
      height: 36,
      decoration:
          const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFE3D1),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 25,
        color: Color(0xFFB65339),
      ),
    );
  }

  // ===============================================================
  // INPUT CHAT
  // ===============================================================

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        9,
        0,
        9,
        8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFD1BC),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                const BoxDecoration(
              color: Color(0xFFFFFCFA),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Color(0xFFE76F51),
              ),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: TextField(
              controller:
                  _messageController,
              textInputAction:
                  TextInputAction.send,
              onSubmitted: (_) {
                _sendMessage();
              },
              decoration:
                  InputDecoration(
                hintText:
                    'Ketik pesan...',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                filled: true,
                fillColor:
                    const Color(0xFFFFFCFA),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide:
                      BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 7),

          GestureDetector(
            onTap:
                _isSending
                    ? null
                    : _sendMessage,
            child: Container(
              width: 34,
              height: 34,
              decoration:
                  const BoxDecoration(
                color: Color(0xFFB65339),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding:
                          EdgeInsets.all(9),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CATATAN
  // ===============================================================

  Widget _buildMedicalNote() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D8),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFFB65339),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              'Catatan: Saran ini bukan pengganti pemeriksaan langsung. '
              'Segera periksa ke fasilitas kesehatan terdekat jika keluhan memburuk.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 8.5,
                height: 1.35,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // KIRIM PESAN
  // ===============================================================

  Future<void> _sendMessage() async {
    final String message =
        _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final User? doctor =
        FirebaseAuth.instance.currentUser;

    if (doctor == null) {
      return;
    }

    if (_consultationId.isEmpty) {
      _showMessage(
        'ID konsultasi tidak ditemukan.',
      );
      return;
    }

    if (_isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final DocumentReference<
          Map<String, dynamic>>
          consultationReference =
          FirebaseFirestore.instance
              .collection('consultations')
              .doc(_consultationId);

      await consultationReference
          .collection('messages')
          .add({
        'senderId': doctor.uid,
        'senderRole': 'doctor',
        'message': message,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      await consultationReference.set(
        {
          'updatedAt':
              FieldValue.serverTimestamp(),
          'lastMessage': message,
          'lastSenderId': doctor.uid,
        },
        SetOptions(
          merge: true,
        ),
      );

      _messageController.clear();

      await Future.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      _scrollToBottom();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Pesan gagal dikirim.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ===============================================================
  // AKHIRI KONSULTASI
  // ===============================================================

  void _showFinishConfirmation() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFFFFCFA),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Akhiri Konsultasi?',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight:
                  FontWeight.w700,
              color: Color(0xFF493028),
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin mengakhiri konsultasi dengan pasien?',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF493C37),
            ),
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF77716E),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _finishConsultation();
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFB65339),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              child: const Text(
                'Akhiri Konsultasi',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // SELESAI
  // ===============================================================

  Future<void> _finishConsultation() async {
    FocusScope.of(context).unfocus();

    try {
      if (_consultationId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('consultations')
            .doc(_consultationId)
            .set(
          {
            'status': 'completed',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  // ===============================================================
  // SCROLL
  // ===============================================================

  void _scrollToBottom() {
    if (!_scrollController
        .hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController
          .position
          .maxScrollExtent,
      duration:
          const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeOut,
    );
  }

  // ===============================================================
  // FORMAT WAKTU
  // ===============================================================

  String _formatTime(
    dynamic timestamp,
  ) {
    if (timestamp is! Timestamp) {
      return '';
    }

    final DateTime date =
        timestamp.toDate();

    final String hour =
        date.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    return '$hour:$minute';
  }

  // ===============================================================
  // ERROR
  // ===============================================================

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Color(0xFFB65339),
            ),

            const SizedBox(height: 12),

            const Text(
              'Chat gagal dimuat.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}