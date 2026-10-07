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

  static const Color backgroundColor =

      Color(0xFFFFF5EF);

  static const Color brown =

      Color(0xFFB65339);

  static const Color softOrange =

      Color(0xFFFFE3D1);

  bool _isSending = false;

  String get _consultationId =>

      (widget.patient['consultationId'] ?? '')

          .toString();

  String get _patientId =>

      (widget.patient['userId'] ?? '')

          .toString();

  String get _patientName {

    final String name =

        (widget.patient['userName'] ??

                widget.patient['name'] ??

                'Pasien')

            .toString()

            .trim();

    return name.isEmpty

        ? 'Pasien'

        : name;

  }

  String get _consultationDay =>

      (widget.patient['consultationDay'] ?? '')

          .toString();

  String get _consultationTime =>

      (widget.patient['consultationTime'] ?? '')

          .toString();

  String get _status =>

      (widget.patient['status'] ?? '')

          .toString()

          .toLowerCase();

  bool get _isActive =>

      _status == 'active';

  bool get _isCompleted =>

      _status == 'completed';

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance

        .addPostFrameCallback((_) {

      if (_isActive) {

        _markAsRead();

      }

    });

  }

  @override

  void dispose() {

    _messageController.dispose();

    _scrollController.dispose();

    super.dispose();

  }

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

  Future<void> _markAsRead() async {

    if (!_isActive ||

        _consultationId.isEmpty) {

      return;

    }

    try {

      await FirebaseFirestore.instance

          .collection('consultations')

          .doc(_consultationId)

          .set(

        {

          'unreadForDoctor': 0,

          'lastReadByDoctorAt':

              FieldValue.serverTimestamp(),

        },

        SetOptions(merge: true),

      );

    } catch (_) {}

  }

  Future<List<Map<String, dynamic>>>

      _loadPreviousConsultations() async {

    final User? doctor =

        FirebaseAuth.instance.currentUser;

    if (doctor == null ||

        _patientId.isEmpty) {

      return [];

    }

    try {

      // Hanya where doctorId.

      // Jadi tidak membutuhkan composite index.

      final snapshot =

          await FirebaseFirestore.instance

              .collection('consultations')

              .where(

                'doctorId',

                isEqualTo: doctor.uid,

              )

              .get();

      final List<Map<String, dynamic>>

          result = [];

      for (final document

          in snapshot.docs) {

        if (document.id ==

            _consultationId) {

          continue;

        }

        final data =

            document.data();

        final String userId =

            (data['userId'] ?? '')

                .toString();

        final String status =

            (data['status'] ?? '')

                .toString()

                .toLowerCase();

        final String lastMessage =

            (data['lastMessage'] ?? '')

                .toString()

                .trim();

        if (userId != _patientId) {

          continue;

        }

        if (status != 'completed') {

          continue;

        }

        if (lastMessage.isEmpty) {

          continue;

        }

        result.add({

          ...data,

          'consultationId':

              document.id,

        });

      }

      result.sort((a, b) {

        final Timestamp? aTime =

            _timestamp(

                  a['updatedAt'],

                ) ??

                _timestamp(

                  a['createdAt'],

                ) ??

                _timestamp(

                  a['consultationTimestamp'],

                );

        final Timestamp? bTime =

            _timestamp(

                  b['updatedAt'],

                ) ??

                _timestamp(

                  b['createdAt'],

                ) ??

                _timestamp(

                  b['consultationTimestamp'],

                );

        if (aTime == null &&

            bTime == null) {

          return 0;

        }

        if (aTime == null) {

          return 1;

        }

        if (bTime == null) {

          return -1;

        }

        return bTime.compareTo(

          aTime,

        );

      });

      return result;

    } catch (_) {

      return [];

    }

  }

  Timestamp? _timestamp(

    dynamic value,

  ) {

    if (value is Timestamp) {

      return value;

    }

    return null;

  }

  void _openPreviousChat(

    Map<String, dynamic> consultation,

  ) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            DoctorPatientChatScreen(

          patient: consultation,

        ),

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:

          backgroundColor,

      body: SafeArea(

        child: Column(

          children: [

            _buildHeader(),

            _buildPatientCard(),

            const SizedBox(height: 12),

            if (_isActive) ...[

              _buildStatusCard(),

              const SizedBox(height: 10),

            ],

            _buildPreviousHistoryButton(),

            const SizedBox(height: 10),

            _buildPrivacyWarning(),

            const SizedBox(height: 10),

            Expanded(

              child: StreamBuilder<

                  QuerySnapshot<

                      Map<String, dynamic>>>(

                stream: _messageStream(),

                builder: (

                  context,

                  snapshot,

                ) {

                  if (_consultationId

                      .isEmpty) {

                    return _buildError(

                      'ID konsultasi tidak ditemukan.',

                    );

                  }

                  if (snapshot

                          .connectionState ==

                      ConnectionState.waiting) {

                    return const Center(

                      child:

                          CircularProgressIndicator(

                        color: brown,

                        strokeWidth: 2.5,

                      ),

                    );

                  }

                  if (snapshot.hasError) {

                    return _buildError(

                      'Chat gagal dimuat.',

                    );

                  }

                  final messages =

                      snapshot.data?.docs ??

                          [];

                  if (_isActive) {

                    WidgetsBinding.instance

                        .addPostFrameCallback(

                      (_) {

                        _markAsRead();

                      },

                    );

                  }

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

                    itemCount:

                        messages.length,

                    itemBuilder:

                        (context, index) {

                      return _buildChatBubble(

                        messages[index]

                            .data(),

                      );

                    },

                  );

                },

              ),

            ),

            if (_isActive)

              _buildMessageInput(),

            if (_isCompleted)

              _buildReadOnlyNotice(),

            if (_isActive)

              _buildMedicalNote(),

            const SizedBox(height: 5),

          ],

        ),

      ),

    );

  }

  Widget _buildHeader() {

    return SizedBox(

      height: 58,

      child: Row(

        children: [

          GestureDetector(

            onTap: () =>

                Navigator.pop(context),

            child: const SizedBox(

              width: 55,

              height: 55,

              child: Center(

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

                _isCompleted

                    ? 'Riwayat Chat'

                    : 'Chat dengan Pasien',

                textAlign:

                    TextAlign.center,

                style:

                    const TextStyle(

                  fontFamily: 'Fredoka',

                  fontSize: 22,

                  fontWeight:

                      FontWeight.w700,

                  color: Colors.black,

                ),

              ),

            ),

          ),

          if (_isActive)

            SizedBox(

              width: 75,

              child: TextButton(

                onPressed:

                    _showFinishConfirmation,

                child:

                    const Text(

                  'Akhiri',

                  style:

                      TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 11,

                    fontWeight:

                        FontWeight.w700,

                    color: brown,

                  ),

                ),

              ),

            )

          else

            const SizedBox(

              width: 75,

            ),

        ],

      ),

    );

  }

  Widget _buildPatientCard() {

    return Container(

      margin:

          const EdgeInsets.symmetric(

        horizontal: 27,

      ),

      padding:

          const EdgeInsets.fromLTRB(

        12,

        10,

        12,

        10,

      ),

      decoration:

          BoxDecoration(

        color: Colors.white,

        borderRadius:

            BorderRadius.circular(

          20,

        ),

      ),

      child: Row(

        children: [

          Container(

            width: 62,

            height: 62,

            decoration:

                const BoxDecoration(

              shape: BoxShape.circle,

              color: softOrange,

            ),

            child: const Icon(

              Icons.person_rounded,

              size: 42,

              color: brown,

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

                  style:

                      const TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 12,

                    fontWeight:

                        FontWeight.w800,

                    color:

                        Colors.black,

                  ),

                ),

                const SizedBox(height: 2),

                const Text(

                  'Pasien',

                  style:

                      TextStyle(

                    fontFamily: 'Nunito',

                    fontSize: 12,

                    color:

                        Colors.black,

                  ),

                ),

                if (_consultationDay

                        .isNotEmpty ||

                    _consultationTime

                        .isNotEmpty) ...[

                  const SizedBox(height: 3),

                  Text(

                    _consultationDay

                            .isNotEmpty

                        ? 'Jadwal: $_consultationDay${_consultationTime.isNotEmpty ? ', $_consultationTime' : ''}'

                        : 'Jadwal: $_consultationTime',

                    maxLines: 1,

                    overflow:

                        TextOverflow.ellipsis,

                    style:

                        const TextStyle(

                      fontFamily:

                          'Nunito',

                      fontSize: 9,

                      color:

                          Colors.black,

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

  Widget _buildStatusCard() {

    final bool completed =

        _isCompleted;

    return Container(

      margin:

          const EdgeInsets.symmetric(

        horizontal: 27,

      ),

      padding:

          const EdgeInsets.symmetric(

        horizontal: 13,

        vertical: 9,

      ),

      decoration:

          BoxDecoration(

        color: Colors.white,

        borderRadius:

            BorderRadius.circular(

          13,

        ),

        boxShadow: [

          BoxShadow(

            color:

                Colors.black.withOpacity(

              0.05,

            ),

            blurRadius: 5,

            offset:

                const Offset(0, 2),

          ),

        ],

      ),

      child: Row(

        children: [

          Icon(

            completed

                ? Icons.history_rounded

                : Icons.chat_rounded,

            size: 19,

            color: brown,

          ),

          const SizedBox(width: 9),

          Expanded(

            child: Column(

              crossAxisAlignment:

                  CrossAxisAlignment.start,

              children: [

                Text(

                  completed

                      ? 'Konsultasi Selesai'

                      : 'Konsultasi Aktif',

                  style:

                      TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 11,

                    fontWeight:

                        FontWeight.w800,

                    color: completed

                        ? Colors.black

                        : const Color(

                            0xFF188447,

                          ),

                  ),

                ),

                const SizedBox(height: 2),

                Text(

                  completed

                      ? 'Riwayat chat dapat dilihat tetapi tidak dapat dilanjutkan.'

                      : 'Kamu dapat membalas pesan pasien.',

                  style:

                      const TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 9.5,

                    color:

                        Colors.black,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildPreviousHistoryButton() {

    return FutureBuilder<

        List<Map<String, dynamic>>>(

      future:

          _loadPreviousConsultations(),

      builder:

          (context, snapshot) {

        final int count =

            snapshot.data?.length ??

                0;

        if (count == 0) {

          return const SizedBox

              .shrink();

        }

        return GestureDetector(

          onTap: () {

            _showPreviousHistory(

              snapshot.data ?? [],

            );

          },

          child: Container(

            margin:

                const EdgeInsets.symmetric(

              horizontal: 27,

            ),

            padding:

                const EdgeInsets.symmetric(

              horizontal: 13,

              vertical: 10,

            ),

            decoration:

                BoxDecoration(

              color: Colors.white,

              borderRadius:

                  BorderRadius.circular(

                13,

              ),

              boxShadow: [

                BoxShadow(

                  color:

                      Colors.black.withOpacity(

                    0.05,

                  ),

                  blurRadius: 5,

                  offset:

                      const Offset(0, 2),

                ),

              ],

            ),

            child: Row(

              children: [

                const Icon(

                  Icons.history_rounded,

                  size: 19,

                  color: brown,

                ),

                const SizedBox(width: 9),

                const Expanded(

                  child: Text(

                    'Riwayat Konsultasi Sebelumnya',

                    style:

                        TextStyle(

                      fontFamily:

                          'Nunito',

                      fontSize: 10.5,

                      fontWeight:

                          FontWeight.w700,

                      color:

                          Colors.black,

                    ),

                  ),

                ),

                Text(

                  '$count',

                  style:

                      const TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 10,

                    fontWeight:

                        FontWeight.w800,

                    color: brown,

                  ),

                ),

                const SizedBox(width: 4),

                const Icon(

                  Icons

                      .chevron_right_rounded,

                  size: 20,

                  color: brown,

                ),

              ],

            ),

          ),

        );

      },

    );

  }

  void _showPreviousHistory(

    List<Map<String, dynamic>> items,

  ) {

    showModalBottomSheet(

      context: context,

      backgroundColor:

          Colors.transparent,

      isScrollControlled: true,

      builder: (sheetContext) {

        return Container(

          constraints:

              BoxConstraints(

            maxHeight:

                MediaQuery.of(

                      sheetContext,

                    )

                    .size

                    .height *

                    0.72,

          ),

          padding:

              const EdgeInsets.fromLTRB(

            20,

            16,

            20,

            20,

          ),

          decoration:

              const BoxDecoration(

            color: backgroundColor,

            borderRadius:

                BorderRadius.vertical(

              top: Radius.circular(24),

            ),

          ),

          child: Column(

            children: [

              Container(

                width: 42,

                height: 4,

                decoration:

                    BoxDecoration(

                  color:

                      Colors.black26,

                  borderRadius:

                      BorderRadius.circular(

                    4,

                  ),

                ),

              ),

              const SizedBox(height: 14),

              const Text(

                'Riwayat Konsultasi',

                style:

                    TextStyle(

                  fontFamily:

                      'Fredoka',

                  fontSize: 20,

                  fontWeight:

                      FontWeight.w700,

                  color:

                      Colors.black,

                ),

              ),

              const SizedBox(height: 14),

              Expanded(

                child: ListView.separated(

                  physics:

                      const BouncingScrollPhysics(),

                  itemCount:

                      items.length,

                  separatorBuilder:

                      (_, __) =>

                          const SizedBox(

                    height: 10,

                  ),

                  itemBuilder:

                      (context, index) {

                    final item =

                        items[index];

                    final String day =

                        (item['consultationDay'] ??

                                '')

                            .toString();

                    final String time =

                        (item['consultationTime'] ??

                                '')

                            .toString();

                    final String message =

                        (item['lastMessage'] ??

                                '')

                            .toString();

                    return GestureDetector(

                      onTap: () {

                        Navigator.pop(

                          sheetContext,

                        );

                        _openPreviousChat(

                          item,

                        );

                      },

                      child: Container(

                        padding:

                            const EdgeInsets.all(

                          13,

                        ),

                        decoration:

                            BoxDecoration(

                          color:

                              Colors.white,

                          borderRadius:

                              BorderRadius.circular(

                            15,

                          ),

                        ),

                        child: Row(

                          children: [

                            const Icon(

                              Icons

                                  .history_rounded,

                              color: brown,

                              size: 22,

                            ),

                            const SizedBox(

                              width: 10,

                            ),

                            Expanded(

                              child:

                                  Column(

                                crossAxisAlignment:

                                    CrossAxisAlignment

                                        .start,

                                children: [

                                  Text(

                                    day.isNotEmpty

                                        ? day

                                        : 'Konsultasi selesai',

                                    style:

                                        const TextStyle(

                                      fontFamily:

                                          'Nunito',

                                      fontSize:

                                          11,

                                      fontWeight:

                                          FontWeight

                                              .w800,

                                      color:

                                          Colors.black,

                                    ),

                                  ),

                                  if (time.isNotEmpty)

                                    Text(

                                      time,

                                      style:

                                          const TextStyle(

                                        fontFamily:

                                            'Nunito',

                                        fontSize:

                                            9,

                                        color:

                                            Colors.black,

                                      ),

                                    ),

                                  const SizedBox(

                                    height: 3,

                                  ),

                                  Text(

                                    message,

                                    maxLines:

                                        1,

                                    overflow:

                                        TextOverflow

                                            .ellipsis,

                                    style:

                                        const TextStyle(

                                      fontFamily:

                                          'Nunito',

                                      fontSize:

                                          9,

                                      color:

                                          Colors.black,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                            const Icon(

                              Icons

                                  .chevron_right_rounded,

                              color: brown,

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                ),

              ),

            ],

          ),

        );

      },

    );

  }

  Widget _buildPrivacyWarning() {

    return Container(

      margin:

          const EdgeInsets.symmetric(

        horizontal: 28,

      ),

      padding:

          const EdgeInsets.symmetric(

        horizontal: 12,

        vertical: 7,

      ),

      decoration:

          BoxDecoration(

        color: softOrange,

        borderRadius:

            BorderRadius.circular(

          10,

        ),

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

              style:

                  TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 9.5,

                height: 1.3,

                color:

                    Colors.black,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildEmptyChat() {

    return Center(

      child: Padding(

        padding:

            const EdgeInsets.all(30),

        child: Column(

          mainAxisAlignment:

              MainAxisAlignment.center,

          children: [

            Container(

              width: 72,

              height: 72,

              decoration:

                  const BoxDecoration(

                color: softOrange,

                shape:

                    BoxShape.circle,

              ),

              child: const Icon(

                Icons

                    .chat_bubble_outline_rounded,

                size: 35,

                color: brown,

              ),

            ),

            const SizedBox(height: 14),

            Text(

              _isCompleted

                  ? 'Tidak Ada Pesan'

                  : 'Mulai Percakapan',

              style:

                  const TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 14,

                fontWeight:

                    FontWeight.w800,

                color:

                    Colors.black,

              ),

            ),

            const SizedBox(height: 6),

            Text(

              _isCompleted

                  ? 'Tidak ada pesan pada konsultasi ini.'

                  : 'Kirim pesan untuk memulai konsultasi dengan pasien.',

              textAlign:

                  TextAlign.center,

              style:

                  const TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 11,

                height: 1.4,

                color:

                    Colors.black,

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildChatBubble(

    Map<String, dynamic> message,

  ) {

    final User? currentUser =

        FirebaseAuth.instance

            .currentUser;

    final String senderId =

        (message['senderId'] ?? '')

            .toString();

    final String role =

        (message['senderRole'] ?? '')

            .toString()

            .toLowerCase();

    final bool isDoctor =

        currentUser != null &&

            senderId ==

                currentUser.uid;

    final bool doctorMessage =

        role == 'doctor' ||

            isDoctor;

    final String text =

        (message['message'] ?? '')

            .toString();

    final String time =

        _formatTime(

      message['createdAt'],

    );

    return Padding(

      padding:

          const EdgeInsets.only(

        bottom: 14,

      ),

      child: Row(

        mainAxisAlignment:

            doctorMessage

                ? MainAxisAlignment.end

                : MainAxisAlignment.start,

        crossAxisAlignment:

            CrossAxisAlignment.end,

        children: [

          if (!doctorMessage) ...[

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

              decoration:

                  BoxDecoration(

                color: doctorMessage

                    ? const Color(

                        0xFFFFE7D8,

                      )

                    : Colors.white,

                borderRadius:

                    BorderRadius.only(

                  topLeft:

                      const Radius.circular(

                    18,

                  ),

                  topRight:

                      const Radius.circular(

                    18,

                  ),

                  bottomLeft:

                      Radius.circular(

                    doctorMessage

                        ? 18

                        : 4,

                  ),

                  bottomRight:

                      Radius.circular(

                    doctorMessage

                        ? 4

                        : 18,

                  ),

                ),

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

                            Colors.black,

                      ),

                    ),

                  ),

                  const SizedBox(

                    height: 2,

                  ),

                  Row(

                    mainAxisSize:

                        MainAxisSize.min,

                    children: [

                      Text(

                        time,

                        style:

                            const TextStyle(

                          fontFamily:

                              'Nunito',

                          fontSize: 8,

                          color:

                              Colors.black,

                        ),

                      ),

                      if (doctorMessage) ...[

                        const SizedBox(

                          width: 3,

                        ),

                        const Icon(

                          Icons

                              .done_all_rounded,

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

  Widget _buildSmallPatientImage() {

    return Container(

      width: 36,

      height: 36,

      decoration:

          const BoxDecoration(

        shape: BoxShape.circle,

        color: softOrange,

      ),

      child: const Icon(

        Icons.person_rounded,

        size: 25,

        color: brown,

      ),

    );

  }

  Widget _buildMessageInput() {

    return Container(

      margin:

          const EdgeInsets.fromLTRB(

        9,

        0,

        9,

        8,

      ),

      padding:

          const EdgeInsets.symmetric(

        horizontal: 8,

        vertical: 7,

      ),

      decoration:

          BoxDecoration(

        color: const Color(

          0xFFEFD1BC,

        ),

        borderRadius:

            BorderRadius.circular(

          13,

        ),

      ),

      child: Row(

        children: [

          Container(

            width: 32,

            height: 32,

            decoration:

                const BoxDecoration(

              color: Colors.white,

              shape:

                  BoxShape.circle,

            ),

            child: const Icon(

              Icons.add_rounded,

              size: 22,

              color: brown,

            ),

          ),

          const SizedBox(width: 7),

          Expanded(

            child: TextField(

              controller:

                  _messageController,

              textInputAction:

                  TextInputAction.send,

              onSubmitted: (_) =>

                  _sendMessage(),

              decoration:

                  InputDecoration(

                hintText:

                    'Ketik pesan...',

                hintStyle:

                    const TextStyle(

                  fontFamily:

                      'Nunito',

                  fontSize: 11,

                  color:

                      Colors.black,

                ),

                filled: true,

                fillColor:

                    Colors.white,

                border:

                    OutlineInputBorder(

                  borderRadius:

                      BorderRadius.circular(

                    18,

                  ),

                  borderSide:

                      BorderSide.none,

                ),

                contentPadding:

                    const EdgeInsets

                        .symmetric(

                  horizontal: 12,

                  vertical: 8,

                ),

              ),

              style:

                  const TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 12,

                color:

                    Colors.black,

              ),

            ),

          ),

          const SizedBox(width: 7),

          GestureDetector(

            onTap: _isSending

                ? null

                : _sendMessage,

            child: Container(

              width: 34,

              height: 34,

              decoration:

                  const BoxDecoration(

                color: brown,

                shape:

                    BoxShape.circle,

              ),

              child: _isSending

                  ? const Padding(

                      padding:

                          EdgeInsets.all(

                        9,

                      ),

                      child:

                          CircularProgressIndicator(

                        strokeWidth: 2,

                        color:

                            Colors.white,

                      ),

                    )

                  : const Icon(

                      Icons

                          .send_rounded,

                      color:

                          Colors.white,

                      size: 19,

                    ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildReadOnlyNotice() {

    return Container(

      margin:

          const EdgeInsets.fromLTRB(

        9,

        0,

        9,

        8,

      ),

      padding:

          const EdgeInsets.symmetric(

        horizontal: 12,

        vertical: 9,

      ),

      decoration:

          BoxDecoration(

        color: Colors.white,

        borderRadius:

            BorderRadius.circular(

          13,

        ),

      ),

      child: const Row(

        mainAxisAlignment:

            MainAxisAlignment.center,

        children: [

          Icon(

            Icons.lock_outline_rounded,

            size: 16,

            color: brown,

          ),

          SizedBox(width: 7),

          Text(

            'Konsultasi sudah selesai. Chat hanya dapat dilihat.',

            textAlign:

                TextAlign.center,

            style:

                TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 9.5,

              fontWeight:

                  FontWeight.w700,

              color:

                  Colors.black,

            ),

          ),

        ],

      ),

    );

  }

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

      decoration:

          BoxDecoration(

        color: softOrange,

        borderRadius:

            BorderRadius.circular(

          10,

        ),

      ),

      child: const Row(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          Icon(

            Icons.info_outline_rounded,

            size: 18,

            color: brown,

          ),

          SizedBox(width: 7),

          Expanded(

            child: Text(

              'Catatan: Saran ini bukan pengganti pemeriksaan langsung. Segera periksa ke fasilitas kesehatan terdekat jika keluhan memburuk.',

              style:

                  TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 8.5,

                height: 1.35,

                color:

                    Colors.black,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Future<void> _sendMessage() async {

    final String message =

        _messageController.text.trim();

    if (message.isEmpty ||

        _isSending ||

        !_isActive) {

      return;

    }

    final User? doctor =

        FirebaseAuth.instance

            .currentUser;

    if (doctor == null ||

        _consultationId.isEmpty) {

      return;

    }

    setState(() {

      _isSending = true;

    });

    try {

      final reference =

          FirebaseFirestore.instance

              .collection(

                'consultations',

              )

              .doc(

                _consultationId,

              );

      await reference

          .collection('messages')

          .add({

        'senderId':

            doctor.uid,

        'senderRole':

            'doctor',

        'message':

            message,

        'createdAt':

            FieldValue

                .serverTimestamp(),

      });

      await reference.set(

        {

          'updatedAt':

              FieldValue

                  .serverTimestamp(),

          'lastMessage':

              message,

          'lastSenderId':

              doctor.uid,

          'unreadForUser':

              FieldValue

                  .increment(1),

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

      if (!mounted) return;

      ScaffoldMessenger.of(context)

          .showSnackBar(

        const SnackBar(

          content: Text(

            'Pesan gagal dikirim.',

            style: TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 11,

            ),

          ),

          behavior:

              SnackBarBehavior

                  .floating,

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

  void _showFinishConfirmation() {

    showDialog(

      context: context,

      builder: (dialogContext) {

        return AlertDialog(

          backgroundColor:

              Colors.white,

          shape:

              RoundedRectangleBorder(

            borderRadius:

                BorderRadius.circular(

              20,

            ),

          ),

          title: const Text(

            'Akhiri Konsultasi?',

            style:

                TextStyle(

              fontFamily:

                  'Fredoka',

              fontSize: 20,

              fontWeight:

                  FontWeight.w700,

              color:

                  Colors.black,

            ),

          ),

          content: const Text(

            'Apakah kamu yakin ingin mengakhiri konsultasi dengan pasien?',

            style:

                TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 13,

              color:

                  Colors.black,

            ),

          ),

          actions: [

            TextButton(

              onPressed: () =>

                  Navigator.pop(

                dialogContext,

              ),

              child:

                  const Text(

                'Batal',

                style:

                    TextStyle(

                  fontFamily:

                      'Nunito',

                  fontSize: 13,

                  fontWeight:

                      FontWeight.w700,

                  color:

                      Colors.black,

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

                  ElevatedButton

                      .styleFrom(

                backgroundColor:

                    brown,

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

              child:

                  const Text(

                'Akhiri Konsultasi',

                style:

                    TextStyle(

                  fontFamily:

                      'Nunito',

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

  Future<void>

      _finishConsultation() async {

    try {

      if (_consultationId

          .isNotEmpty) {

        await FirebaseFirestore

            .instance

            .collection(

              'consultations',

            )

            .doc(

              _consultationId,

            )

            .set(

          {

            'status':

                'completed',

            'updatedAt':

                FieldValue

                    .serverTimestamp(),

          },

          SetOptions(

            merge: true,

          ),

        );

      }

    } catch (_) {}

    if (!mounted) return;

    Navigator.pop(context);

  }

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

      curve:

          Curves.easeOut,

    );

  }

  String _formatTime(

    dynamic timestamp,

  ) {

    if (timestamp

        is! Timestamp) {

      return '';

    }

    final date =

        timestamp.toDate();

    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  }

  Widget _buildError(

    String message,

  ) {

    return Center(

      child: Column(

        mainAxisAlignment:

            MainAxisAlignment.center,

        children: [

          const Icon(

            Icons

                .error_outline_rounded,

            size: 45,

            color: brown,

          ),

          const SizedBox(

            height: 12,

          ),

          const Text(

            'Chat gagal dimuat.',

            style:

                TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 13,

              fontWeight:

                  FontWeight.w700,

              color:

                  Colors.black,

            ),

          ),

          const SizedBox(

            height: 6,

          ),

          Text(

            message,

            style:

                const TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 10,

              color:

                  Colors.black,

            ),

          ),

        ],

      ),

    );

  }

}
