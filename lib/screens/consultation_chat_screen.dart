import 'package:flutter/material.dart';

import 'consultation_complete_screen.dart';

class ConsultationChatScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String doctorImage;
  final String selectedTime;
  final String rating;
  final String reviews;

  const ConsultationChatScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.doctorImage,
    required this.selectedTime,
    required this.rating,
    required this.reviews,
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

  final List<ChatMessage> messages = [
    ChatMessage(
      text: 'Selamat pagi, ada yang bisa saya bantu hari ini?',
      isDoctor: true,
      time: '10:00',
    ),
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ===============================================================
  // KIRIM PESAN
  // ===============================================================

  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isDoctor: false,
          time: _currentTime(),
        ),
      );
    });

    messageController.clear();

    _scrollToBottom();

    Future.delayed(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) {
          return;
        }

        String reply;

        if (messages.length == 2) {
          reply =
              'Baik, sudah berapa lama Anda mengalami keluhan ini?';
        } else if (messages.length == 4) {
          reply =
              'Apakah ada keluhan seperti mual, nyeri saat menelan, atau batuk?';
        } else if (messages.length == 6) {
          reply =
              'Berdasarkan keluhan Anda, saya sarankan untuk menjaga pola makan dan menghindari makanan yang dapat memicu keluhan.';
        } else {
          reply =
              'Baik, terima kasih sudah menjelaskan keluhan Anda. Apakah ada keluhan lain yang ingin disampaikan?';
        }

        setState(() {
          messages.add(
            ChatMessage(
              text: reply,
              isDoctor: true,
              time: _currentTime(),
            ),
          );
        });

        _scrollToBottom();
      },
    );
  }

  // ===============================================================
  // WAKTU SEKARANG
  // ===============================================================

  String _currentTime() {
    final now = DateTime.now();

    final hour =
        now.hour.toString().padLeft(2, '0');

    final minute =
        now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ===============================================================
  // SCROLL KE PESAN TERAKHIR
  // ===============================================================

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!scrollController.hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ===============================================================
  // KONFIRMASI AKHIRI KONSULTASI
  // ===============================================================

  void _showFinishConfirmation() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Akhiri Konsultasi?',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF493028),
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin mengakhiri konsultasi dengan dokter?',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF493C37),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF77716E),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _finishConsultation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB65339),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Akhiri Konsultasi',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // PINDAH KE HALAMAN KONSULTASI SELESAI
  // ===============================================================

  void _finishConsultation() {
    FocusScope.of(context).unfocus();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ConsultationCompleteScreen(
            doctorName: widget.doctorName,
            specialty: widget.specialty,
            selectedTime: widget.selectedTime,
          );
        },
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            _buildHeader(),

            // =====================================================
            // DOCTOR CARD
            // =====================================================

            _buildDoctorCard(),

            const SizedBox(height: 16),

            // =====================================================
            // PRIVACY WARNING
            // =====================================================

            _buildPrivacyWarning(),

            const SizedBox(height: 12),

            // =====================================================
            // HARI INI
            // =====================================================

            _buildTodayLabel(),

            const SizedBox(height: 12),

            // =====================================================
            // CHAT
            // =====================================================

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  10,
                  0,
                  10,
                  8,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(
                    messages[index],
                  );
                },
              ),
            ),

            // =====================================================
            // INPUT CHAT
            // =====================================================

            _buildMessageInput(),

            // =====================================================
            // CATATAN
            // =====================================================

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
          // =========================================================
          // TOMBOL KEMBALI
          // =========================================================

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

          // =========================================================
          // JUDUL
          // =========================================================

          Expanded(
            child: Center(
              child: Text(
                'Konsultasi dengan Dokter',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // =========================================================
          // TOMBOL AKHIRI
          // =========================================================

          SizedBox(
            width: 75,
            child: TextButton(
              onPressed: _showFinishConfirmation,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
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
  // DOCTOR CARD
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE76F51),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          // FOTO DOKTER

          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDE5DF),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              widget.doctorImage,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.person_rounded,
                  size: 42,
                  color: Color(0xFFB65339),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          // INFORMASI DOKTER

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF211914),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.specialty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF18C85A),
                  ),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFC107),
                    ),

                    const SizedBox(width: 2),

                    Text(
                      '${widget.rating} (${widget.reviews} ulasan)',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
        borderRadius: BorderRadius.circular(10),
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
  // TODAY LABEL
  // ===============================================================

  Widget _buildTodayLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8DC),
        borderRadius: BorderRadius.circular(12),
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF493028),
        ),
      ),
    );
  }

  // ===============================================================
  // CHAT BUBBLE
  // ===============================================================

  Widget _buildChatBubble(
    ChatMessage message,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: message.isDoctor
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isDoctor) ...[
            _buildSmallDoctorImage(),

            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 310,
              ),
              padding: const EdgeInsets.fromLTRB(
                13,
                9,
                10,
                6,
              ),
              decoration: BoxDecoration(
                color: message.isDoctor
                    ? const Color(0xFFFFFCFA)
                    : const Color(0xFFFFE7D8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    message.isDoctor ? 4 : 18,
                  ),
                  bottomRight: Radius.circular(
                    message.isDoctor ? 18 : 4,
                  ),
                ),
                border: message.isDoctor
                    ? Border.all(
                        color: const Color(0xFFE76F51),
                        width: 0.8,
                      )
                    : null,
                boxShadow: message.isDoctor
                    ? []
                    : const [
                        BoxShadow(
                          color: Color(0x28000000),
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.text,
                      style: const TextStyle(
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
                        message.time,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                        ),
                      ),

                      if (!message.isDoctor) ...[
                        const SizedBox(width: 3),

                        const Icon(
                          Icons.done_all_rounded,
                          size: 12,
                          color: Color(0xFFB65339),
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
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEDE5DF),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        widget.doctorImage,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.person_rounded,
            size: 25,
            color: Color(0xFFB65339),
          );
        },
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
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          // TOMBOL +

          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
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

          // TEXT FIELD

          Expanded(
            child: TextField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                _sendMessage();
              },
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                filled: true,
                fillColor: const Color(0xFFFFFCFA),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 7),

          // TOMBOL KIRIM

          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFB65339),
                shape: BoxShape.circle,
              ),
              child: const Icon(
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
  // MEDICAL NOTE
  // ===============================================================

  Widget _buildMedicalNote() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D8),
        borderRadius: BorderRadius.circular(10),
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
}

// ===============================================================
// MODEL CHAT
// ===============================================================

class ChatMessage {
  final String text;
  final bool isDoctor;
  final String time;

  ChatMessage({
    required this.text,
    required this.isDoctor,
    required this.time,
  });
}