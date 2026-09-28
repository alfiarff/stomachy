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
  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF7F2);

  final Color primaryBrown =
      const Color(0xFFB65339);

  final Color titleBrown =
      const Color(0xFF5A2017);

  final Color patientBubbleColor =
      const Color(0xFFFFE7D8);

  final Color securityBackground =
      const Color(0xFFFFE8D9);

  final Color inputBackground =
      const Color(0xFFF7DCCA);

  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // ===============================================================
  // DATA PESAN
  // ===============================================================

  final List<Map<String, dynamic>> messages = [
    {
      'text':
          'Selamat pagi, ada yang bisa saya bantu hari ini?',
      'isDoctor': true,
      'time': '10:00',
    },
    {
      'text':
          'Pagi dok, saya sering merasa panas di dada dan asam naik ke tenggorokan.',
      'isDoctor': false,
      'time': '10:13',
    },
    {
      'text':
          'Baik, sudah berapa lama Anda mengalami keluhan ini?',
      'isDoctor': true,
      'time': '10:14',
    },
    {
      'text':
          'Sudah sekitar 2 minggu terakhir dok, terutama setelah makan.',
      'isDoctor': false,
      'time': '10:14',
    },
    {
      'text':
          'Apakah ada keluhan seperti mual, nyeri saat menelan, atau batuk?',
      'isDoctor': true,
      'time': '10:15',
    },
    {
      'text':
          'Kadang mual dan sering sendawa dok.',
      'isDoctor': false,
      'time': '10:15',
    },
    {
      'text':
          'Baik, terima kasih informasinya. Saya sarankan untuk mengatur pola makan, menghindari makanan pedas dan berlemak, serta jangan langsung berbaring setelah makan.',
      'isDoctor': true,
      'time': '10:16',
    },
  ];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ===============================================================
  // KIRIM PESAN
  // ===============================================================

  void _sendMessage() {
    final String text =
        _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        'text': text,
        'isDoctor': true,
        'time': _currentTime(),
      });
    });

    _messageController.clear();

    _scrollToBottom();
  }

  // ===============================================================
  // WAKTU SEKARANG
  // ===============================================================

  String _currentTime() {
    final DateTime now =
        DateTime.now();

    final String hour =
        now.hour.toString().padLeft(2, '0');

    final String minute =
        now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ===============================================================
  // SCROLL KE BAWAH
  // ===============================================================

  void _scrollToBottom() {
    Future.delayed(
      const Duration(
        milliseconds: 100,
      ),
      () {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 350,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> patient =
        widget.patient;

    return Scaffold(
      backgroundColor:
          backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // =======================================================
            // HEADER
            // =======================================================

            _buildHeader(),

            // =======================================================
            // IDENTITAS PASIEN
            // =======================================================

            _buildPatientHeader(patient),

            const SizedBox(
              height: 12,
            ),

            // =======================================================
            // CHAT
            // =======================================================

            Expanded(
              child: ListView.builder(
                controller:
                    _scrollController,
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  27,
                  4,
                  27,
                  10,
                ),
                itemCount:
                    messages.length + 2,
                itemBuilder:
                    (context, index) {
                  // -----------------------------------------------
                  // KEAMANAN
                  // -----------------------------------------------

                  if (index == 0) {
                    return _buildSecurityNotice();
                  }

                  // -----------------------------------------------
                  // HARI INI
                  // -----------------------------------------------

                  if (index == 1) {
                    return _buildDateDivider();
                  }

                  // -----------------------------------------------
                  // PESAN
                  // -----------------------------------------------

                  final int messageIndex =
                      index - 2;

                  return _buildMessageBubble(
                    messages[messageIndex],
                  );
                },
              ),
            ),

            // =======================================================
            // INPUT + CATATAN
            // =======================================================

            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        28,
        7,
        28,
        5,
      ),
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            // -------------------------------------------------------
            // BACK
            // -------------------------------------------------------

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  const SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    size: 25,
                    color:
                        Color(0xFFB65339),
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------
            // TITLE
            // -------------------------------------------------------

            const Expanded(
              child: Center(
                child: Text(
                  'Konsultasi dengan Pasien',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF5A2017),
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 40,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // IDENTITAS PASIEN
  // ===============================================================

  Widget _buildPatientHeader(
    Map<String, dynamic> patient,
  ) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 27,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.035,
            ),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------
          // AVATAR
          // ---------------------------------------------------------

          _buildLargeAvatar(patient),

          const SizedBox(
            width: 16,
          ),

          // ---------------------------------------------------------
          // DATA PASIEN
          // ---------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  patient['name']
                      .toString(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF5A2017),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Row(
                  children: [
                    Text(
                      '${patient['age']} Tahun',
                      style:
                          const TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                        color:
                            Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Container(
                      width: 4,
                      height: 4,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFF777777),
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Flexible(
                      child: Text(
                        patient['gender']
                            .toString(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w500,
                          color:
                              Color(0xFF777777),
                        ),
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
  // AVATAR BESAR
  // ===============================================================

  Widget _buildLargeAvatar(
    Map<String, dynamic> patient,
  ) {
    final dynamic avatarImage =
        patient['avatarImage'];

    if (avatarImage is String &&
        avatarImage.trim().isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          avatarImage,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _buildIconAvatar(
              patient,
              72,
              46,
            );
          },
        ),
      );
    }

    return _buildIconAvatar(
      patient,
      72,
      46,
    );
  }

  // ===============================================================
  // AVATAR ICON
  // ===============================================================

  Widget _buildIconAvatar(
    Map<String, dynamic> patient,
    double size,
    double iconSize,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        color:
            patient['avatarColor'],
        shape:
            BoxShape.circle,
      ),
      child: Icon(
        patient['avatarIcon'],
        size: iconSize,
        color:
            patient['avatarIconColor'],
      ),
    );
  }

  // ===============================================================
  // SECURITY NOTICE
  // ===============================================================

  Widget _buildSecurityNotice() {
    return Container(
      margin:
          const EdgeInsets.only(
        top: 0,
        bottom: 15,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            securityBackground,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFFE0CC),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.lock_rounded,
              size: 22,
              color:
                  Color(0xFFB65339),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Text(
              'Jangan bagikan informasi pribadi atau kode OTP kepada siapapun.',
              style:
                  TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 11.5,
                height: 1.35,
                fontWeight:
                    FontWeight.w500,
                color:
                    Color(0xFF382620),
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

  Widget _buildDateDivider() {
    return Center(
      child: Container(
        margin:
            const EdgeInsets.only(
          top: 1,
          bottom: 18,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFFFFEDE4),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child:
            const Text(
          'Hari Ini',
          style:
              TextStyle(
            fontFamily:
                'Nunito',
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
            color:
                Color(0xFF5A2017),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CHAT BUBBLE
  // ===============================================================

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
  ) {
    final bool isDoctor =
        message['isDoctor'] == true;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment:
            isDoctor
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          // ---------------------------------------------------------
          // AVATAR PASIEN
          // ---------------------------------------------------------

          if (!isDoctor) ...[
            _buildSmallAvatar(
              widget.patient,
            ),

            const SizedBox(
              width: 8,
            ),
          ],

          // ---------------------------------------------------------
          // BUBBLE
          // ---------------------------------------------------------

          Flexible(
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 330,
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                11,
                11,
                7,
              ),
              decoration:
                  BoxDecoration(
                color: isDoctor
                    ? Colors.white
                    : patientBubbleColor,
                borderRadius:
                    BorderRadius.only(
                  topLeft:
                      const Radius.circular(
                    20,
                  ),
                  topRight:
                      const Radius.circular(
                    20,
                  ),
                  bottomLeft:
                      Radius.circular(
                    isDoctor ? 20 : 5,
                  ),
                  bottomRight:
                      Radius.circular(
                    isDoctor ? 5 : 20,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.025,
                    ),
                    blurRadius: 5,
                    offset:
                        const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  // -------------------------------------------------
                  // TEKS
                  // -------------------------------------------------

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      message['text']
                          .toString(),
                      style:
                          const TextStyle(
                        fontFamily:
                            'Nunito',
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight:
                            FontWeight.w400,
                        color:
                            Color(0xFF2F211D),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  // -------------------------------------------------
                  // WAKTU
                  // -------------------------------------------------

                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        message['time']
                            .toString(),
                        style:
                            const TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w500,
                          color:
                              Color(0xFF777777),
                        ),
                      ),

                      // ------------------------------------------------
                      // DOUBLE CHECK
                      // ------------------------------------------------

                      if (isDoctor) ...[
                        const SizedBox(
                          width: 4,
                        ),
                        const Icon(
                          Icons
                              .done_all_rounded,
                          size: 13,
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
  // AVATAR KECIL DI CHAT
  // ===============================================================

  Widget _buildSmallAvatar(
    Map<String, dynamic> patient,
  ) {
    final dynamic avatarImage =
        patient['avatarImage'];

    if (avatarImage is String &&
        avatarImage.trim().isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          avatarImage,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _buildIconAvatar(
              patient,
              35,
              23,
            );
          },
        ),
      );
    }

    return _buildIconAvatar(
      patient,
      35,
      23,
    );
  }

  // ===============================================================
  // BAGIAN BAWAH
  // ===============================================================

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        // -----------------------------------------------------------
        // INPUT PESAN
        // -----------------------------------------------------------

        _buildMessageInput(),

        const SizedBox(
          height: 7,
        ),

        // -----------------------------------------------------------
        // CATATAN
        // -----------------------------------------------------------

        _buildSafetyNote(),

        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  // ===============================================================
  // INPUT PESAN
  // ===============================================================

  Widget _buildMessageInput() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        27,
        4,
        27,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            inputBackground,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------
          // PLUS
          // ---------------------------------------------------------

          Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(
              color:
                  Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child:
                IconButton(
              padding:
                  EdgeInsets.zero,
              onPressed: () {},
              icon:
                  const Icon(
                Icons.add_rounded,
                size: 29,
                color:
                    Color(0xFFB65339),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ---------------------------------------------------------
          // TEXT FIELD
          // ---------------------------------------------------------

          Expanded(
            child: Container(
              constraints:
                  const BoxConstraints(
                minHeight: 42,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child:
                  TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 3,
                textInputAction:
                    TextInputAction.send,
                onSubmitted:
                    (_) {
                  _sendMessage();
                },
                textAlignVertical:
                    TextAlignVertical.center,
                style:
                    const TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  color:
                      Color(0xFF2F211D),
                ),
                decoration:
                    const InputDecoration(
                  border:
                      InputBorder.none,
                  hintText:
                      'Ketik pesan...',
                  hintStyle:
                      TextStyle(
                    fontFamily:
                        'Nunito',
                    fontSize: 11.5,
                    color:
                        Color(0xFF9A9A9A),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ---------------------------------------------------------
          // KIRIM
          // ---------------------------------------------------------

          GestureDetector(
            onTap:
                _sendMessage,
            child:
                Container(
              width: 42,
              height: 42,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFB65339),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.send_rounded,
                size: 20,
                color:
                    Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CATATAN KEAMANAN
  // ===============================================================

  Widget _buildSafetyNote() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 27,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFEEE4),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFFF7F1),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.info_outline_rounded,
              size: 21,
              color:
                  Color(0xFFB65339),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Expanded(
            child: Text(
              'Catatan: Saran ini bukan pengganti pemeriksaan langsung.\nSegera periksa ke fasilitas kesehatan terdekat jika keluhan memburuk.',
              style:
                  TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 10.5,
                height: 1.35,
                fontWeight:
                    FontWeight.w500,
                color:
                    Color(0xFF5A4038),
              ),
            ),
          ),
        ],
      ),
    );
  }
}