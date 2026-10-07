import 'dart:convert';

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ConsultationChatScreen extends StatefulWidget {

  final String consultationId;

  final String doctorName;

  final String specialty;

  final String doctorImage;

  final String selectedTime;

  const ConsultationChatScreen({

    super.key,

    required this.consultationId,

    required this.doctorName,

    required this.specialty,

    required this.doctorImage,

    required this.selectedTime,

  });

  @override

  State<ConsultationChatScreen> createState() =>

      _ConsultationChatScreenState();

}

class _ConsultationChatScreenState

    extends State<ConsultationChatScreen> {

  final TextEditingController messageController =

      TextEditingController();

  final ScrollController scrollController =

      ScrollController();

  bool _isSending = false;

  int _lastMessageCount = -1;

  bool _hasLoadedMessages = false;
  bool _isCompleted = false;
  bool _statusLoaded = false;
  String _consultationDateText = '';

  final Color backgroundColor =

      const Color(0xFFFFF5EF);

  final Color primaryBrown =

      const Color(0xFFB65339);
  @override
  void initState() {
    super.initState();
    _markAsRead();
    _loadConsultationStatus();
  }

  Future<void> _markAsRead() async {
    try {
      await FirebaseFirestore.instance.collection('consultations').doc(widget.consultationId).set({'unreadForUser': 0, 'lastReadByUserAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<bool> _isChatActive() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('consultations').doc(widget.consultationId).get();
      return (doc.data()?['status'] ?? '').toString().toLowerCase() == 'active';
    } catch (_) {
      return false;
    }
  }
  Future<void> _loadConsultationStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .get();

      if (!mounted) return;

      final status =
          (doc.data()?['status'] ?? '').toString().toLowerCase();

      final ts = doc.data()?['consultationTimestamp'];
      String dateText = '';
      if (ts is Timestamp) {
        final d = ts.toDate();
        final date = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final time = widget.selectedTime.trim().replaceAll(' WIB', '');
        if (time.isNotEmpty) {
          dateText = '$date • $time WIB';
        }
      }

      setState(() {
        _isCompleted = status == 'completed';
        _consultationDateText = dateText;
        _statusLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusLoaded = true;
        });
      }
    }
  }


  @override
  void dispose() {

    messageController.dispose();

    scrollController.dispose();

    super.dispose();

  }

  // ===============================================================

  // STREAM PESAN

  // ===============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>

      _messageStream() {

    return FirebaseFirestore.instance

        .collection('consultations')

        .doc(widget.consultationId)

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

            _buildDoctorCard(),

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

                  if (snapshot.connectionState ==

                      ConnectionState.waiting) {

                    return const Center(

                      child:

                          CircularProgressIndicator(

                        color:

                            Color(0xFFB65339),

                      ),

                    );

                  }

                  if (snapshot.hasError) {

                    return _buildError();

                  }

                  final List<

                          QueryDocumentSnapshot<

                              Map<String,

                                  dynamic>>>

                      messages =

                      snapshot.data?.docs ?? [];

                  final int currentMessageCount = messages.length;

                  final bool shouldScroll =

                      !_hasLoadedMessages ||

                      currentMessageCount > _lastMessageCount;

                  if (shouldScroll) {

                    WidgetsBinding.instance

                        .addPostFrameCallback((_) {

                      if (!mounted ||

                          !scrollController.hasClients) {

                        return;

                      }

                      _scrollToBottom();

                    });

                  }

                  _lastMessageCount = currentMessageCount;

                  _hasLoadedMessages = true;

                  if (messages.isEmpty) {

                    return _buildEmptyChat();

                  }

                  return ListView.builder(

                    controller:

                        scrollController,

                    padding:

                        const EdgeInsets.fromLTRB(

                      10,

                      0,

                      10,

                      8,

                    ),

                    physics:

                        const ClampingScrollPhysics(),

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

            if (_statusLoaded && _isCompleted)
              _buildReadOnlyNotice()
            else ...[
              _buildMessageInput(),
              _buildMedicalNote(),
              const SizedBox(height: 5),
            ],

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
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: const SizedBox(width: 55, height: 55, child: Align(alignment: Alignment.center, child: Icon(Icons.arrow_back_rounded, size: 29, color: Colors.black)))),
        Expanded(child: Center(child: Text(_isCompleted ? 'Riwayat Chat' : 'Konsultasi dengan Dokter', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF171310))))),
        const SizedBox(width: 55),
      ]),
    );
  }

  String _displayDoctorName() {
    final name = widget.doctorName.trim();
    if (name.isEmpty) return 'dr. Dokter';
    if (name.toLowerCase().startsWith('dr.')) return name;
    return 'dr. $name';
  }

  // ===============================================================

  // DOCTOR CARD

  // TANPA RATING DAN ULASAN

  // ===============================================================

  Widget _buildDoctorCard() {

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

          _buildDoctorImage(),

          const SizedBox(width: 14),

          Expanded(

            child: Column(

              crossAxisAlignment:

                  CrossAxisAlignment.start,

              children: [

                Text(

                  _displayDoctorName(),

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

                Text(

                  widget.specialty,

                  maxLines: 1,

                  overflow:

                      TextOverflow.ellipsis,

                  style: const TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 12,

                    color: Colors.black,

                  ),

                ),

                const SizedBox(height: 2),
                Text(
                  _consultationDateText.isNotEmpty
                      ? _consultationDateText
                      : (widget.selectedTime.isNotEmpty
                          ? widget.selectedTime.trim().replaceAll(' WIB', '') + ' WIB'
                          : 'Konsultasi Aktif'),
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

  // ===============================================================

  // FOTO DOKTER

  // ===============================================================

  Widget _buildDoctorImage() {

    final String image =

        widget.doctorImage.trim();

    if (image.isEmpty) {

      return _fallbackDoctorImage();

    }

    if (image.startsWith('http')) {

      return Container(

        width: 62,

        height: 62,

        decoration:

            const BoxDecoration(

          shape: BoxShape.circle,

          color: Color(0xFFEDE5DF),

        ),

        clipBehavior:

            Clip.antiAlias,

        child: Image.network(

          image,

          fit: BoxFit.cover,

          errorBuilder:

              (context, error, stackTrace) {

            return _fallbackDoctorIcon();

          },

        ),

      );

    }

    try {

      final Uint8List bytes =

          base64Decode(image);

      if (bytes.isEmpty) {

        return _fallbackDoctorImage();

      }

      return Container(

        width: 62,

        height: 62,

        decoration:

            const BoxDecoration(

          shape: BoxShape.circle,

          color: Color(0xFFEDE5DF),

        ),

        clipBehavior:

            Clip.antiAlias,

        child: Image.memory(

          bytes,

          fit: BoxFit.cover,

          errorBuilder:

              (context, error, stackTrace) {

            return _fallbackDoctorIcon();

          },

        ),

      );

    } catch (_) {

      return _fallbackDoctorImage();

    }

  }

  Widget _fallbackDoctorImage() {

    return Container(

      width: 62,

      height: 62,

      decoration:

          const BoxDecoration(

        shape: BoxShape.circle,

        color: Color(0xFFEDE5DF),

      ),

      child: _fallbackDoctorIcon(),

    );

  }

  Widget _fallbackDoctorIcon() {

    return const Icon(

      Icons.person_rounded,

      size: 42,

      color: Color(0xFFB65339),

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

        color: const Color(0xFFFFE4D3),

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

                fontSize: 11,

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

          fontSize: 11,

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

              'Mulai Konsultasi',

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

              'konsultasi dengan dokter.',

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

    final bool isMine =

        currentUser != null &&

            senderId == currentUser.uid;

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

        mainAxisAlignment: isMine

            ? MainAxisAlignment.end

            : MainAxisAlignment.start,

        crossAxisAlignment:

            CrossAxisAlignment.end,

        children: [

          if (!isMine) ...[

            _buildSmallDoctorImage(),

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

                color: isMine

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

                    isMine ? 18 : 4,

                  ),

                  bottomRight:

                      Radius.circular(

                    isMine ? 4 : 18,

                  ),

                ),

                boxShadow: isMine

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

                      style: const TextStyle(

                        fontFamily: 'Nunito',

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

                          fontFamily: 'Nunito',

                          fontSize: 8,

                          color:

                              Colors.grey[600],

                        ),

                      ),

                      if (isMine) ...[

                        const SizedBox(

                          width: 3,

                        ),

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

  // FOTO DOKTER KECIL

  // ===============================================================

  Widget _buildSmallDoctorImage() {

    final String image =

        widget.doctorImage.trim();

    if (image.startsWith('http')) {

      return Container(

        width: 36,

        height: 36,

        decoration:

            const BoxDecoration(

          shape: BoxShape.circle,

          color: Color(0xFFEDE5DF),

        ),

        clipBehavior:

            Clip.antiAlias,

        child: Image.network(

          image,

          fit: BoxFit.cover,

          errorBuilder:

              (context, error, stackTrace) {

            return _smallDoctorFallback();

          },

        ),

      );

    }

    try {

      if (image.isNotEmpty) {

        return Container(

          width: 36,

          height: 36,

          decoration:

              const BoxDecoration(

            shape: BoxShape.circle,

            color: Color(0xFFEDE5DF),

          ),

          clipBehavior:

              Clip.antiAlias,

          child: Image.memory(

            base64Decode(image),

            fit: BoxFit.cover,

            errorBuilder:

                (context, error, stackTrace) {

              return _smallDoctorFallback();

            },

          ),

        );

      }

    } catch (_) {}

    return _smallDoctorFallback();

  }

  Widget _smallDoctorFallback() {

    return Container(

      width: 36,

      height: 36,

      decoration:

          const BoxDecoration(

        shape: BoxShape.circle,

        color: Color(0xFFEDE5DF),

      ),

      child: const Icon(

        Icons.person_rounded,

        size: 25,

        color: Color(0xFFB65339),

      ),

    );

  }

  // ===============================================================

  // MESSAGE INPUT

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

                  messageController,

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
  // READ ONLY NOTICE
  // ===============================================================

  Widget _buildReadOnlyNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(9, 0, 9, 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
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
            color: Color(0xFFB65339),
          ),
          SizedBox(width: 7),
          Text(
            'Konsultasi sudah selesai. Chat hanya dapat dilihat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================

  // MEDICAL NOTE

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

  // SEND MESSAGE

  // ===============================================================

  Future<void> _sendMessage() async {

    final String message =

        messageController.text.trim();

    if (message.isEmpty) {

      return;

    }

    final User? user =

        FirebaseAuth.instance.currentUser;

    if (user == null || _isSending) {
      return;
    }
    if (!await _isChatActive()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum waktunya konsultasi.')));
      return;
    }
    setState(() => _isSending = true);

    try {

      final DocumentReference<

          Map<String, dynamic>>

          consultationReference =

          FirebaseFirestore.instance

              .collection('consultations')

              .doc(widget.consultationId);

      await consultationReference

          .collection('messages')

          .add({

        'senderId': user.uid,

        'senderRole': 'user',

        'message': message,

        'createdAt':

            FieldValue.serverTimestamp(),

      });

      await consultationReference.set(

        {

          'updatedAt':

              FieldValue.serverTimestamp(),

          'lastMessage': message,

          'lastSenderId': user.uid,

          'unreadForDoctor':

              FieldValue.increment(1),

        },

        SetOptions(merge: true),

      );

      messageController.clear();

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

  // ===============================================================

  // SCROLL

  // ===============================================================

  void _scrollToBottom() {

    if (!scrollController.hasClients) {

      return;

    }

    final double maxScroll =

        scrollController.position.maxScrollExtent;

    scrollController.jumpTo(maxScroll);

  }

  // ===============================================================

  // FORMAT WAKTU

  // ===============================================================

  String _formatTime(dynamic timestamp) {

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

  Widget _buildError() {

    return const Center(

      child: Text(

        'Chat gagal dimuat.',

        style: TextStyle(

          fontFamily: 'Nunito',

          fontSize: 13,

          fontWeight: FontWeight.w700,

        ),

      ),

    );

  }

}